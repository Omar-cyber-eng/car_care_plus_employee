# دليل تطبيق الورشة والموظف — المرجع الشامل (كل الـ APIs + الفلو + ملاحظات الفرونت)

> **تطبيق منفصل لثلاثة أدوار فقط:** `workshop` (ورشة) · `employee_washer` (غسّال) · `employee_mechanic` (ميكانيكي).
> ⛔ **الأدمن والسوبر أدمن خارج هذا التطبيق كلياً** (لوحة منفصلة). لا يوجد "موظف admin" في تطبيقك — نوع
> `admin` هو مدير فرع ويعمل على لوحة الأدمن.
> Base URL: `/api` · كل الطلبات محميّة بـ `Authorization: Bearer <token>` + `Accept: application/json`.
> كل رد بالغلاف الموحّد: `{ status, data, message, status_code, timestamp }` (`status`: 1 نجاح / 0 فشل).

هذا الملف مُعاد كتابته بالكامل بعد فحص الروتس والصلاحيات الحالية (آخر تحديثات: enums، firebase، spare parts، car history).

---

# 1) الدخول والهوية

| العملية | المسار | ملاحظات |
|---|---|---|
| دخول | `POST /api/auth/login` | يرجع المستخدم + `token` (إن كان الحساب نشطاً) |
| خروج | `POST /api/auth/logout` | |

- ميّز الدور من `data.role`: `workshop` / `employee_washer` / `employee_mechanic`.
- **الورشة تسجّل نفسها** (`POST /api/auth/register/workshop`) وتنتظر اعتماد السوبر أدمن → لا token، `is_active=false`.
  الحقول: `name, email, phone?, password(+confirmation), image_url?` + `workshop_name, workshop_name_ar, workshop_address, workshop_city, latitude, longitude`.
- **الموظف (غسّال/ميكانيكي) لا يسجّل نفسه** — ينشئه السوبر أدمن؛ في تطبيقك يسجّل الدخول فقط.
- ⚠️ حساب غير نشط (ورشة لم تُعتمد) → **403 "Your account is inactive."** → اعرض "قيد المراجعة".

**حسابات تجريبية جاهزة** (كلمة المرور `password123`): `washer@system.com` · `mechanic@system.com` · `workshop@system.com`.

---

# 2) مرجع سريع: من يصل ماذا (مصفوفة الصلاحيات)

✅ = متاح · ❌ = يرجع 403. مبني على صلاحيات الأدوار الفعلية.

| الميزة / المسار | غسّال | ميكانيكي | ورشة |
|---|:---:|:---:|:---:|
| `GET /bookings` (قائمتي، مُصفّاة) | ✅ | ✅ | ✅ |
| `GET /bookings/{id}` | ✅ | ✅ | ✅ |
| `POST /bookings/{id}/start` · `/complete` · (update) | ✅ | ✅ | ✅ |
| `bookings/{id}/status-history · price-items · sub-services · materials` (GET) | ✅ | ✅ | ❌ |
| `GET/POST bookings/{id}/maintenance-detail` | ❌ | ✅ | ✅ |
| `GET/POST bookings/{id}/road-detail` | ❌ | ✅ | ✅ |
| `GET/POST bookings/{id}/towing-detail` (+`/destination`) | ❌ | ✅ | ❌ |
| `POST /payments/{paymentId}/confirm-cash` | ✅ | ✅ | ❌ |
| `GET /payments/{id}` | ✅ | ✅ | ❌ |
| `spare-part-requests` (create + list + show) | ❌ | ✅ | ❌ |
| `employee-reports` (create) | ✅ | ✅ | ❌ |
| `employee-reports` (list + show) | ✅ | ✅ | ✅ |
| `POST /gps-logs` (إرسال) | ✅ | ✅ | ❌ |
| `GET /gps-logs` (قراءة) | ❌ | ❌ | ❌ |
| `GET /suggested-problems` | ❌ | ✅ | ❌ |
| `GET /workshops/my` · `{id}` · `POST /workshops/{id}` | — | — | ✅ |
| `GET /workshops/cars/{car}/history` | ❌ | ❌ | ✅ |
| `GET /workshops/nearby` | ✅ | ✅ | ✅ |
| `GET /indexClient` · `/show/{id}` (سيارات/سيارة) | ✅ | ✅ | جزئياً¹ |
| الكتالوج (`categories/services/sub-services/car-types/car-brands/materials`) | ✅ | ✅ | ✅ |
| `GET /enums` · `profile/*` | ✅ | ✅ | ✅ |

¹ الورشة تملك `show.car` (تفاصيل سيارة `GET /show/{id}`) لكن **لا** `show.client.cars` (قائمة `/indexClient`).

---

# 3) فلو الطلب (Order Lifecycle) — جوهر التطبيق

```
pending → assigned → in_progress → completed        (+ cancelled)
```

| الانتقال | المسار | body | مَن + الشرط |
|---|---|---|---|
| إسناد لموظف | `POST /bookings/{id}/assign` | — | ⛔ **الأدمن فقط** (خارج تطبيقك). يحتاج `pending` |
| **بدء** | `POST /bookings/{id}/start` | لا | الموظف/الورشة. يحتاج الحالة **`assigned`** |
| **إنهاء** | `POST /bookings/{id}/complete` | لا | الموظف/الورشة. يحتاج الحالة **`in_progress`** |

- الانتقالات **مرتّبة وإجبارية ومحروسة** (قفزة/رجوع → خطأ). كلٌّ يرجع `OrderResource` بعد التحديث.
- ⚠️ **الإسناد خارج نطاق تطبيقك:** الطلبات تصل الموظف **بعد** إسناد الأدمن؛ تطبيقك يبدأ من `assigned`.
- **Scoping تلقائي** (لا ترسل أي فلتر هوية): الموظف يرى `employee_id = أنا`، والورشة ترى `workshop_id = ورشتي`.
- ⚠️ **قائمة `GET /bookings` مُرقّمة صفحات:** العناصر في `data.data`، ومعلومات الصفحات في `data.meta`.

## 3.1 علاقة الدفع بالفلو — **مساران مستقلّان، لا ترتيب بينهما**
- حالة الطلب (`assigned→in_progress→completed`) **مرتّبة**.
- تأكيد الدفع النقدي **مستقلّ تماماً**: يشترط فقط دفعة `cash` حالتها `pending` — **لا يشترط اكتمال الطلب**.
- يمكن تأكيد النقد أثناء `in_progress` أو بعد `completed` — لا فرق.
- 👈 في الواجهة: اجعل زرّي (start/complete) و(تأكيد النقد) **مستقلّين**، كلٌّ بشرطه.

---

# 4) شكل الطلب (OrderResource) — الأهم للفرونت

العلاقات المُحمّلة تلقائياً في `/bookings` و`/bookings/{id}`:
`customer, car, branch, workshop, employee.user, service, category, priceItems, subServices.subService, materials.material, payments, userPackage.package`.

```json
{
  "id": 12, "booking_group_id": "uuid-...",
  "customer_id": 5, "customer": { "id":5, "name":"أحمد", "phone":"05..." },
  "car_id": 8, "car": { "model":"Corolla", "plate_number":"ABC-1234", "car_type": {...} },
  "branch_id": 1, "branch": {...},
  "workshop_id": null, "workshop": {...}|null,
  "employee_id": 9, "employee": { "type":"washer", "rating_avg":"5.00", "user": {...} },
  "service_id": 1, "service": { "name":"Exterior Wash", "name_ar":"غسيل خارجي", "base_price":"50.00", "duration_minutes":30 },
  "category_id": 1, "category": { "name":"Car Wash", "name_ar":"غسيل سيارات" },
  "booking_type": true,          // ⚠️ true=فوري / false=مجدول (ليس نوع الخدمة)
  "is_vip": false,
  "status": "assigned",          // pending|assigned|in_progress|completed|cancelled
  "scheduled_at": "...", "started_at": null, "completed_at": null,
  "cancelled_at": null, "cancel_reason": null, "assigned_at": "...",
  "location_lat": "24.71", "location_lng": "46.67", "location_address": "...", "distance_km": "5.00",
  "discount_amount":"0.00", "service_price":"50.00", "sub_service_price":"0.00", "materials_price":"0.00",
  "total_price":"50.00", "package_covered_amount":"0.00", "cash_due_amount":"50.00",
  "user_package_id": null, "user_package": null,
  "price_items":[...], "sub_services":[...], "materials":[...],
  "payments":[ { "id":31, "method":"cash", "status":"pending", "amount":"50.00" } ],
  "notes":"...", "created_at":"...", "updated_at":"..."
}
```

## 4.1 ⭐ كيف تميّز نوع الخدمة؟
**لا يوجد حقل `service_kind`** — يُشتقّ من **`category.name`** (الإنجليزي ثابت عبر البيئات، لا تعتمد على `category_id`):

| `category.name` | النوع | يخصّ |
|---|---|---|
| `Car Wash` | غسيل | الغسّال |
| `Maintenance` | صيانة | الميكانيكي/الورشة |
| `Roadside Assistance` | مساعدة على الطريق | الميكانيكي |

- **السحب (towing)** ليس تصنيفاً مستقلاً — حالة داخل Roadside، تعرفها بوجود `towing-detail` (يرجع null إن لا سحب).
- ⚠️ تفاصيل صيانة/طريق/سحب **ليست ضمن التحميل التلقائي** — اجلبها بمساراتها (القسم 6).

## 4.2 الدفع داخل الطلب
طريقة/حالة الدفع من مصفوفة **`payments[]`** (لكل عنصر `method` + `status` + `amount` + `id`)، وليست حقلاً مباشراً.
- **`method`:** cash · card · wallet · point · package
- **`status`:** pending · paid · failed · refunded
- زر "تأكيد النقد" يظهر عند وجود دفعة `method=cash`,`status=pending`. الحقلان `cash_due_amount`/`package_covered_amount` مساعدان.

---

# 5) الدفع النقدي — `confirm-cash`

| المسار | body | مَن + الشرط |
|---|---|---|
| `POST /api/payments/{paymentId}/confirm-cash` | لا | غسّال/ميكانيكي. الدفعة `method=cash` و`status=pending` |
| `GET /api/payments/{id}` | — | غسّال/ميكانيكي (عرض دفعة) |

- ⚠️ المعرّف = **`payment.id`** (من `order.payments[].id`)، وليس معرّف الطلب.
- يرجع `PaymentResource`: `id, payment_number, type, method, status, amount, points_used`. بعد النجاح → `status=paid`.
- ⛔ الورشة لا تملك تأكيد النقد.

---

# 6) التفاصيل الميدانية (ميكانيكي/ورشة)

سلوك مشترك: **`GET`** يرجع التفصيل أو `null` (إن لم يُنشأ) بـ 200. **`POST`** = upsert (إنشاء أو تعديل، حقول جزئية).

## 6.1 صيانة — `maintenance-detail` (ميكانيكي + ورشة)
- الرد: `{ id, order_id, workshop_id, workshop?, notes, created_at }`.
- حقول POST: `workshop_id?`، `notes?` (≤5000).

## 6.2 مساعدة على الطريق — `road-detail` (ميكانيكي + ورشة)
- الرد: `{ id, order_id, problem_type_id, problem_type?, car_type_size, problem_description, problem_image_url, ai_diagnosis, ai_chat_log, created_at }`.
- حقول POST: `problem_type_id?`، `car_type_size?` (sedan/suv/hatchback/pickup)، `problem_description?`، `problem_image_url?` (URL)، `ai_diagnosis?`.
- ⚠️ `ai_chat_log` عرض فقط. أنواع المشاكل للميكانيكي من `/suggested-problems`.

## 6.3 سحب — `towing-detail` (ميكانيكي فقط)
- الرد: `{ id, order_id, car_type_size, destination_lat, destination_lng, destination_address, notes, created_at }`.
- `POST /bookings/{id}/towing-detail` — حقول: `car_type_size?`, `destination_lat?`, `destination_lng?`, `destination_address?`, `notes?`.
- 🆕 `POST /bookings/{id}/towing-detail/destination` — تحديث الوجهة فقط: `destination_lat` + `destination_lng` (كلاهما مطلوب).

---

# 7) قطع الغيار — `spare-part-requests` (ميكانيكي فقط)

**الفلو:** الميكانيكي يطلب قطعة على طلب مفتوح → **العميل يعتمد/يرفض** (لوحة العميل، خارج تطبيقك).

| العملية | المسار | مَن |
|---|---|---|
| إنشاء | `POST /api/spare-part-requests` | ميكانيكي (`create.spare_part_request`) |
| قائمة | `GET /api/spare-part-requests` | ميكانيكي (`show.spare_part_requests`) |
| تفاصيل | `GET /api/spare-part-requests/{id}` | ميكانيكي |
| اعتماد/رفض | `POST .../{id}/approve` \| `/reject` | ⛔ العميل فقط |

- حقول الإنشاء: `order_id`, `material_id` (من `/materials`), `quantity` (≥1), `specifications?`, `notes?`.
- قواعد: الطلب يجب أن يكون **مفتوحاً** (ليس completed/cancelled)؛ لا يُعاد البتّ في المبتوت.
- الرد: `{ id, order_id, order?, employee_id, employee?, material_id, material?, quantity, specifications, status, notes, decided_at, created_at, updated_at }` — الحالة: `pending|approved|rejected|ordered|received`.
- ⛔ الغسّال والورشة: لا صلاحية قطع غيار إطلاقاً.

---

# 8) تقارير الموظف — `employee-reports`

| العملية | المسار | مَن |
|---|---|---|
| إنشاء | `POST /api/employee-reports` | غسّال + ميكانيكي (`create.employee_report`) |
| قائمة (فلاتر `?order_id=&employee_id=&status=&per_page=`) | `GET /api/employee-reports` | غسّال + ميكانيكي + **ورشة** |
| تفاصيل | `GET /api/employee-reports/{id}` | نفس أعلاه |

- حقول الإنشاء: `order_id`, `problem_description`, `affected_parts[]?`, `images[]?` (روابط), `recommendation?`.
- الرد: `{ id, order_id, order?, employee_id, employee?, problem_description, affected_parts, images, recommendation, status, reviewed_at, created_at }`.
- الورشة **عرض فقط** (لا تنشئ).

---

# 9) سجلّات GPS — `gps-logs` (إرسال فقط)

| العملية | المسار | مَن |
|---|---|---|
| إرسال نقطة | `POST /api/gps-logs` | غسّال + ميكانيكي (`manage.gps_logs`) |
| قراءة | `GET /api/gps-logs`, `/{id}` | ⛔ لا أحد منهم (يحتاج `show.gps_logs`) |

- حقول: `latitude` (مطلوب), `longitude` (مطلوب), `order_id?`, `recorded_at?`.
- ⚠️ إرسال فقط — لا شاشة عرض. استعمله للبثّ أثناء تنفيذ الطلب.

---

# 10) الورشة — المسارات الخاصة

| العملية | المسار | ملاحظات |
|---|---|---|
| ملف ورشتي | `GET /api/workshops/my` | ⭐ |
| عرض ورشة | `GET /api/workshops/{id}` | ورشته فقط (وإلا 403) |
| تعديل ورشتي | `POST /api/workshops/{id}` | حقوله: `name, name_ar, address, city, latitude, longitude` (بلا بادئة `workshop_`، وبلا `status/rating_avg`) |
| 🆕 سِجِل صيانة سيارة | `GET /api/workshops/cars/{car}/history` | تاريخ صيانة/مساعدة سيارة زارت ورشته (`OrderResource[]`) |
| ورش قريبة | `GET /api/workshops/nearby` | `?latitude=&longitude=&radius_km=` (متاح للثلاثة) |

- كيان الورشة: `{ id, name, name_ar, address, city, latitude, longitude, status, rating_avg, distance_km?, owner?, created_at }`.
- الحالات: `pending|approved|rejected|active|inactive|suspended`.

---

# 11) قوائم مساعدة (قراءة، للثلاثة إلا المذكور)

- 🆕 **`GET /api/enums`** — كل الـ enums بقيمها ومسمّياتها المترجمة (بلا صلاحية، لأي مستخدم مسجّل).
  استعمله كمصدر واحد لقيم الحالات/الأنواع بدل كتابتها يدوياً.
- **الكتالوج:** `/categories` (+`/{id}/services`), `/services` (+`/{id}/sub-services`), `/sub-services`, `/car-types`, `/car-brands`.
- **المواد:** `/materials`, `/materials/{id}` (لاختيار `material_id` في قطع الغيار). `/material-units` (غسّال/ميكانيكي).
- **المشاكل المقترحة:** `/suggested-problems` (ميكانيكي فقط).
- **سيارات العميل:** `/indexClient` (غسّال/ميكانيكي) · `/show/{id}` (الثلاثة).
- **التقييمات:** `GET /ratings`, `/ratings/{id}` (عرض فقط للثلاثة).
- **البروفايل:** `GET /profile/showProfile` · `POST /profile/updateProfile`.

---

# 12) الإشعارات (Firebase / In-App) — الوضع الحالي بدقّة

النظام صار يُطلق إشعارات عبر أحداث/مستمعات:
- **عند الإسناد (`assigned`):** يُشعَر **الموظف المُسنَد** + العميل. ✅ (أي: نعم، يوجد إشعار إسناد للموظف الآن)
- عند `in_progress`/`completed`: العميل فقط. عند `cancelled`: العميل + الموظف.
- إشعارات أخرى: تأكيد الدفع النقدي، بتّ قطع الغيار (للميكانيكي)، تقييم جديد (للموظف والورشة).

⚠️ **لكن عملياً للفرونت — غير مكتمل بعد:**
1. **دفع FCM حالياً no-op:** قناة `FcmChannel` كتلة فارغة (TODO) — لا يُرسَل push فعلي حتى تُضبط بيانات Firebase في الباك.
2. **لا مسار لتسجيل توكن الجهاز** (device token) — التوكنات تُقرأ من جدول `device_tokens` لكن **لا endpoint** لإضافتها.
3. **لا مسار لجلب الإشعارات داخل التطبيق** (in-app) — لا يوجد `GET /notifications`.

👈 **الخلاصة:** اعتمد الآن على **polling** (`GET /bookings` دورياً/عند السحب للتحديث) لاكتشاف الطلبات الجديدة.
الـ push الفوري ينتظر من الباك: (أ) تفعيل FCM، (ب) endpoint لتسجيل device token، (ج) endpoint لقائمة الإشعارات.

---

# 13) البيانات التجريبية (Seed) — جاهزة

`php artisan migrate:fresh --seed` يوفّر (كلمة المرور `password123`):
- `washer@` : طلبات غسيل مسندة له (assigned/in_progress/completed) بعضها بدفعة نقدية `pending`.
- `mechanic@` : طلبات صيانة + طريق + **سحب**، لكلٍّ تفاصيله، وبعضها بدفعة نقدية `pending`.
- `workshop@` : ورشة "التميز" (Riyadh) + **3 طلبات** بـ `workshop_id` (assigned/in_progress/completed).

سيناريوهات: دورة الحياة (start→complete) · تأكيد النقد (خذ `payment.id` من `payments[]`) · شاشات الميكانيكي (road/towing-detail فيها بيانات) · تطبيق الورشة (`/workshops/my` + `/bookings`).

---

# 14) ملاحظات ثابتة + ما يحتاجه الفرونت

**قواعد ثابتة:**
1. لا ترسل `customer_id`/فلاتر هوية — الـ Scoping تلقائي.
2. القيم decimal (الأسعار/الإحداثيات/التقييم) ترجع **كنصوص** — حوّلها لأرقام.
3. العلاقات `whenLoaded` قد تكون null — عاملها كذلك.
4. الأخطاء موحّدة: 401 (توكن) · 403 (صلاحية/ملكية/حساب غير نشط) · 404 · 422 (`data` = خريطة حقول).
5. `confirm-cash` بمعرّف **الدفعة**، والتفاصيل الميدانية upsert بـ POST واحد.

**ما ينتظره الفرونت من الباك (غير جاهز بعد):**
- تفعيل **push (FCM)** + endpoint **تسجيل device token** + endpoint **قائمة الإشعارات**.
- (عند الحاجة) endpoints **إدارة موظفي الورشة** — الصلاحيات موجودة للورشة (`add/edit/show.employee`) لكن **لا مسارات**.
- كتابة **مواد الطلب** (`manage.order_materials`) — لا مسار (العرض فقط عبر `bookings/{id}/materials`).

**تنبيهات إزالة:** كيان **العقود (Contracts) حُذف** من الباك — أزِل أي أثر له.
