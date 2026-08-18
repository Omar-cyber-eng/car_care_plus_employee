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





# 7) المدفوعات وقواعد التسعير — ربط كامل للورشة/الموظف

> ⚠️ **حدث تغيير مهم في الصلاحيات — اقرأ هذا القسم بدقّة قبل الربط.** خلاصة الوصول:
>
> | المسار | الغسّال | الميكانيكي | الورشة |
> |---|:---:|:---:|:---:|
> | `GET /payments` (قائمة) | ❌ | ❌ | ❌ |
> | `GET /payments/{id}` (تفاصيل) | ⚠️ عملياً ❌ | ⚠️ عملياً ❌ | ❌ |
> | `POST /payments/{id}/confirm-cash` | ✅ (طلبه المُسنَد) | ✅ (طلبه المُسنَد) | ❌ |
> | `GET /pricing-rules` · `/{id}` | ✅ | ✅ | ❌ |

## 7.1 المدفوعات — الموظف يؤكّد النقد فقط (لا قائمة ولا تفاصيل)

**التغيير:** الموظف **لا يملك `show.payments`** (الجمع) → قائمة `GET /payments` تُرجِع **403**.
ويملك `show.payment` (المفرد) لكن `GET /payments/{id}` **يرفضه منطق `assertCanView`** (لأن `payment.user_id`
هو **العميل الدافع** لا الموظف) → عملياً **لا يقدر يفتح دفعة عبر هذا المسار**. **الورشة بلا أي صلاحية دفع إطلاقاً.**

فالمسار الوحيد الفعلي للموظف هو **تأكيد النقد**:

### `POST /api/payments/{paymentId}/confirm-cash`
- **مَن:** الغسّال أو الميكانيكي، وبشرط أن يكون **الموظف المُسنَد لهذا الطلب** (`order.employee_id === موظفي`) — وإلا **403** "You are not allowed to confirm this payment".
- **الشرط على الدفعة:** `method = cash` و`status = pending` — وإلا 422.
- **body:** لا يوجد.
- **الرد:** `PaymentResource` بعد أن يصبح `status = paid`.

**⭐ من أين آتي بـ `paymentId`؟** ليس عبر `/payments` (ممنوع)، بل من **الطلب نفسه**:
`GET /api/bookings/{id}` يرجع الطلب ومعه مصفوفة `payments[]`، كل عنصر فيه `{ id, method, status, amount, ... }`.
خذ `id` الدفعة التي `method="cash"` و`status="pending"`.

**شكل PaymentResource:**
```json
{ "id": 31, "payment_number": "PAY-...", "type": "order",
  "method": "cash", "status": "pending",   // pending → paid بعد التأكيد
  "amount": "60.00", "points_used": 0 }
```
- قيم `method`: `cash|card|wallet|point|package` · `status`: `pending|paid|failed|refunded` · `type`: `order|package|wallet_topup`.

### الفلو الكامل لتأكيد النقد (Dart)
```dart
// 1) افتح تفاصيل الطلب (فيه payments[])
final order = (await dio.get('/bookings/$orderId')).data['data'];

// 2) جد الدفعة النقدية المعلّقة
final cash = (order['payments'] as List).firstWhere(
  (p) => p['method'] == 'cash' && p['status'] == 'pending',
  orElse: () => null,
);

// 3) أظهر زر "تأكيد استلام النقد" فقط إن وُجدت (cash != null)
if (cash != null) {
  await dio.post('/payments/${cash['id']}/confirm-cash'); // بلا body
  // بعد النجاح: الدفعة أصبحت paid — أعد جلب الطلب أو حدّث الحالة محلياً
}
```

**قواعد UX للفرونت:**
1. زر "تأكيد النقد" يظهر **فقط** إذا في `order.payments[]` دفعة `cash` + `pending`، **و**الطلب مُسنَد لك.
2. **مستقلّ عن حالة الطلب** — لا يشترط أن يكون الطلب `completed` (يمكن التأكيد أثناء `in_progress`).
3. لا تبنِ شاشة "قائمة مدفوعاتي" للموظف/الورشة — غير متاحة (403). المدفوعات تُعرض **ضمن تفاصيل الطلب** فقط.

## 7.2 قواعد التسعير — `pricing-rules` (مرجع، للغسّال/الميكانيكي فقط)

بيانات مرجعية للقراءة تشرح كيف تُحسب الأسعار (رسوم VIP، مسافة، توقيت...). **الورشة لا تملكها** (`show.pricing_rules`).

| المسار | مَن |
|---|---|
| `GET /api/pricing-rules` | الغسّال + الميكانيكي |
| `GET /api/pricing-rules/{id}` | الغسّال + الميكانيكي |

**شكل PricingRuleResource:**
```json
{ "id": 1, "pricing_rule_type_id": 10,
  "rule_type": { PricingRuleTypeResource }|null,
  "name": "VIP Surcharge", "name_ar": "رسوم VIP",
  "value": "20.00", "conditions": { ... }, "is_active": true }
```
- استعمالها اختياري (للعرض التوضيحي فقط). القوائم قد تكون غير مُرقّمة — تعامل معها كمصفوفة كاملة.
- `value`/الأسعار decimal **كنصوص**؛ `conditions` كائن JSON حرّ حسب نوع القاعدة.

## 7.3 خلاصة القسم 7
- **الموظف:** فعله الوحيد في الدفع = **`confirm-cash`** على طلبه المُسنَد (بمعرّف الدفعة من `order.payments[]`). لا قائمة ولا تفاصيل مباشرة.
- **الورشة:** **لا شيء** في الدفع ولا التسعير (403).
- **pricing-rules:** مرجع قراءة للغسّال/الميكانيكي فقط.
- الأخطاء موحّدة (403 صلاحية/ملكية · 422 دفعة غير نقدية أو غير معلّقة). decimal كنصوص. العلاقات whenLoaded قد تكون null.