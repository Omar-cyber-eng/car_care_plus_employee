# GUIDE_W_E_Last — مسارات مكمّلة لتطبيق الورشة/الموظف + فلوها

> ملحق أخير لدليل الورشة/الموظف. يصف المسارات التي أدرجتها هنا (الإشعارات، تفاصيل الطلب الميدانية،
> قطع الغيار، وجهة السحب) **مع فلوها** ليربطها الفرونت بشكل صحيح.
> الأدوار: `workshop` · `employee_washer` · `employee_mechanic`. Base URL `/api` · Bearer token · الغلاف الموحّد.

---

# 1) 🆕 الإشعارات داخل التطبيق (In-App Notifications)

**جديد ومهم:** صار للإشعارات مسارات فعلية، و**الأدوار الثلاثة تملك** `show.notifications` + `edit.notification_status`.
هذه تقرأ إشعارات المستخدم المخزّنة (التي يكتبها `InAppChannel`) — **Scoping تلقائي**: كل مستخدم يرى إشعاراته فقط.

| العملية | المسار | ملاحظات |
|---|---|---|
| قائمتي | `GET /api/notifications` | الأحدث أولاً · **مُرقّم صفحات** (`?per_page=15`) · `?unread=1` للغير مقروء فقط |
| **عدّاد غير المقروء** | `GET /api/notifications/unread-count` | يرجع `{ "unread_count": N }` — لشارة الجرس |
| تفاصيل | `GET /api/notifications/{id}` | إشعار واحد |
| **تعليم الكل مقروء** | `POST /api/notifications/read-all` | بلا body |
| تعليم واحد مقروء | `POST /api/notifications/{id}/read` | بلا body · 403 إن لم يكن لك |

**شكل الإشعار (NotificationResource):**
```json
{
  "id": 10, "title": "تم إسناد طلب جديد", "body": "الطلب #40 أُسند إليك",
  "type": "info",                 // info | warning | success | error
  "reference_type": "order",      // نوع الكيان المرتبط (قد يكون null)
  "reference_id": 40,             // معرّفه (استعمله للانتقال لتفاصيل الطلب)
  "is_read": false, "read_at": null,
  "sent_via": ["in_app"],         // القنوات المُرسَل بها
  "created_at": "2026-08-17T..."
}
```

**الفلو في الواجهة:**
1. عند فتح التطبيق/دورياً: نادِ `unread-count` لتحديث شارة الجرس.
2. شاشة الإشعارات: `GET /notifications` (أو `?unread=1`).
3. عند الضغط على إشعار: `POST /notifications/{id}/read` ثم انتقل حسب `reference_type`+`reference_id`
   (مثلاً `order` → افتح `GET /bookings/{reference_id}`).
4. زر "تعليم الكل": `POST /notifications/read-all`.

> ⚠️ ملاحظة عن الـ Push: هذه الإشعارات **in-app** (تُجلب بالاستطلاع/عند الفتح). دفع FCM الفوري
> ما زال غير مفعّل (لا endpoint لتسجيل device token) — فاعتمد `unread-count` كاستطلاع خفيف حتى يُفعّل الـ push.

---

# 2) تفاصيل الطلب الميدانية (صيانة / طريق / سحب)

سلوك مشترك: **`GET`** يرجع التفصيل أو **`null`** (إن لم يُنشأ) بـ 200. **`POST`** = upsert (إنشاء/تعديل، حقول جزئية).

| المسار | الغسّال | الميكانيكي | الورشة |
|---|:---:|:---:|:---:|
| `GET bookings/{id}/maintenance-detail` | ❌ | ✅ | ✅ |
| `POST bookings/{id}/maintenance-detail` | ❌ | ✅ | ✅ |
| `GET bookings/{id}/road-detail` | ❌ | ✅ | ✅ |
| `POST bookings/{id}/road-detail` | ❌ | ✅ | ✅ |
| `GET bookings/{id}/towing-detail` | ❌ | ✅ | ❌ |
| `POST bookings/{id}/towing-detail` | ❌ | ✅ | ❌ |

- **صيانة** (`maintenance-detail`): حقول POST `workshop_id?`, `notes?`. الرد: `{id, order_id, workshop_id, workshop?, notes, created_at}`.
- **طريق** (`road-detail`): حقول POST `problem_type_id?`, `car_type_size?` (sedan/suv/hatchback/pickup), `problem_description?`, `problem_image_url?`, `ai_diagnosis?`. (`ai_chat_log` عرض فقط.)
- **سحب** (`towing-detail`): انظر §4.

**الفلو:** الميكانيكي/الورشة يفتح الطلب → `GET` التفصيل (قد يكون null → نموذج فارغ) → يعبّئ ويرسل `POST` (مسار واحد للإنشاء والتعديل).

---

# 3) قطع الغيار — عرض (للميكانيكي)

| المسار | مَن |
|---|---|
| `GET /api/spare-part-requests` | الميكانيكي (`show.spare_part_requests`) — الغسّال/الورشة ❌ |
| `GET /api/spare-part-requests/{id}` | الميكانيكي |

- الإنشاء `POST /spare-part-requests` (ميكانيكي) موثّق في الدليل الأساسي؛ الاعتماد/الرفض من **العميل** لا منك.
- الرد: `{id, order_id, order?, employee_id, employee?, material_id, material?, quantity, specifications, status, notes, decided_at, ...}` — الحالة `pending|approved|rejected|ordered|received`.

**الفلو:** الميكانيكي يطلب قطعة على طلب مفتوح → يتابع حالتها هنا (`pending` حتى يبتّها العميل).

---

# 4) وجهة السحب — `towing-detail` + `/destination` (الميكانيكي فقط)

سلوكان منفصلان لتحديد وجهة نقل السيارة (السطحة):

| المسار | الحقول | الاستعمال |
|---|---|---|
| `POST bookings/{id}/towing-detail` | `car_type_size?`, `destination_lat?`, `destination_lng?`, `destination_address?`, `notes?` | upsert كامل لتفصيل السحب |
| `POST bookings/{id}/towing-detail/destination` | `destination_lat` + `destination_lng` (كلاهما **مطلوب**) | تحديث **الوجهة على الخريطة** فقط |

- الرد (`TowingDetailResource`): `{id, order_id, car_type_size, destination_lat, destination_lng, destination_address, notes, created_at}`.
- **الفلو:** الميكانيكي يفتح طلب سحب → يفتح الخريطة ويحدّد نقطة الوجهة → يرسل `/destination` بالإحداثيات
  (أو `towing-detail` كاملاً مع العنوان والملاحظات). ⚠️ الغسّال والورشة لا يصلان لتفاصيل السحب.

> تذكير: العميل يحدّد **عنوان** الوجهة نصّياً عند الحجز (`destination_address`)، والموظف الميكانيكي
> يثبّت **الإحداثيات الدقيقة** على الخريطة عبر `/destination`.

---

# 5) مسارات مساعدة أخرى في هذا المقطع
- `GET /api/users/{user}` (`show.profile`) — عرض ملف مستخدم (متاح عبر active.user).
- `GET /api/pricing-rules` · `/{id}` (`show.pricing_rules`) — قواعد التسعير (للغسّال/الميكانيكي؛ الورشة ❌).

---

# 6) خلاصة الفلو للفرونت
1. **الإشعارات** = مصدر التنبيه الآن: استطلِع `unread-count`، اعرض القائمة، علّم المقروء، وانتقل عبر `reference_type/id`.
2. **التفاصيل الميدانية**: `GET` (قد يكون null) ثم `POST` upsert — للميكانيكي (والورشة للصيانة/الطريق).
3. **السحب**: الميكانيكي يثبّت الوجهة عبر `/destination` (إحداثيات مطلوبة).
4. **قطع الغيار**: الميكانيكي ينشئ ويتابع؛ الاعتماد خارج تطبيقك.
5. الأخطاء موحّدة (401/403/404/422)؛ القوائم مُرقّمة صفحات؛ decimal كنصوص؛ العلاقات whenLoaded قد تكون null.
