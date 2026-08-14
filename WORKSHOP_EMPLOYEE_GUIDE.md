# دليل تطبيق الورشة والموظف (تطبيق منفصل) — الباك-إند والمسارات والتدفّق

> **هذا التطبيق منفصل عن تطبيق العميل، ومخصّص لثلاثة أدوار فقط:**
> `workshop` (مالك ورشة) · `employee_washer` (غسّال) · `employee_mechanic` (ميكانيكي).
>
> ⛔ **الأدمن والسوبر أدمن لا دخل لهما بهذا التطبيق** — لهما لوحة تحكّم منفصلة (Dashboard).
> كل ما يخص assign / المخزون / المحافظ / إدارة العملاء = لوحة الأدمن، **ليست هنا**.
>
> كل الردود بالغلاف الموحّد `{status,data,message,status_code,timestamp}`، ومحميّة بـ Bearer token.

---

# 0) ⚠️ توضيح حاسم: "الأدمن" مقابل "الموظف من نوع admin" — **هما نفس الشيء**

هذا مصدر اللبس، وإليك الحقيقة من الكود بدقة:

- في النظام **دور admin واحد فقط**، ومعناه: **مدير فرع** (Branch Manager).
- عندما ينشئ السوبر أدمن موظفاً، يختار `type` من: `washer` / `mechanic` / **`admin`**.
- الـ enum `EmployeeType` يربط كل نوع بدور (role):
  - `washer` → دور `employee_washer`
  - `mechanic` → دور `employee_mechanic`
  - `admin` → دور **`admin`** (وليس دوراً باسم "employee_admin" — لا وجود لهذا).
- عند اختيار `type=admin`، الكود:
  1. يُسند للمستخدم دور **`admin`** (Spatie role).
  2. يُنشئ له سجل `employees` بنوع `admin` (لهذا يبدو "موظفاً").
  3. يعيّنه مديراً للفرع (`branches.admin_id = user->id`).

**الخلاصة:** «الموظف من نوع admin» و«الأدمن الذي تحت السوبر أدمن» = **كيان واحد تماماً**، وهو **مدير الفرع**.
لا يوجد دوران منفصلان. ومدير الفرع هذا **مُستبعَد من تطبيقك** (يعمل على لوحة الأدمن).

| النوع عند الإنشاء | الدور الناتج | داخل هذا التطبيق؟ |
|---|---|---|
| `washer` | `employee_washer` | ✅ نعم |
| `mechanic` | `employee_mechanic` | ✅ نعم |
| `admin` | `admin` (مدير فرع) | ❌ لا (لوحة الأدمن) |
| — | `workshop` (يسجّل نفسه) | ✅ نعم |

> إذاً تطبيقك = **workshop + washer + mechanic** فقط. تجاهل أي شيء يخص `admin`/`super_admin`.

---

# 1) الدخول والهوية (مشترك للأدوار الثلاثة)

- **الدخول:** `POST /api/auth/login` → يرجع المستخدم + `token` (إن كان الحساب نشطاً).
- **الخروج:** `POST /api/auth/logout`.
- ميّز الدور من `data.role`:
  ```dart
  // 'workshop' | 'employee_washer' | 'employee_mechanic'
  final role = user.role;
  ```
- **الورشة تسجّل نفسها** (وتنتظر اعتماد السوبر أدمن) — انظر القسم 2.
- **الموظف (washer/mechanic) لا يسجّل نفسه** — ينشئه السوبر أدمن، ثم يسجّل الدخول بحسابه. لا شاشة تسجيل للموظف.
- ⚠️ لو الحساب `is_active=false` (ورشة لم تُعتمد بعد) → معظم المسارات تحجبه بـ **403 "Your account is inactive."** — عالجها كحالة "قيد المراجعة".

---

# 2) الورشة (Workshop)

## 2.1 التسجيل والاعتماد
- `POST /api/auth/register/workshop` — تسجيل معلّق (لا token، `is_active=false`, `status=pending`).
- **الحقول:** بيانات المستخدم (`name`, `email`, `phone?`, `password`+`password_confirmation`, `image_url?`)
  + بيانات الورشة: `workshop_name`, `workshop_name_ar`, `workshop_address`, `workshop_city`,
  `latitude`, `longitude` (الإحداثيات إلزامية).
- بعد التسجيل: شاشة "طلبك قيد المراجعة". السوبر أدمن يعتمد (من لوحته)، ثم يصبح الحساب نشطاً ويدخل.

## 2.2 كيان الورشة (WorkshopResource)
```json
{
  "id": 4, "name": "Speed Fix", "name_ar": "الإصلاح السريع",
  "address": "...", "city": "Riyadh",
  "latitude": "24.7136000", "longitude": "46.6753000",
  "status": "approved",        // pending|approved|rejected|active|inactive|suspended
  "rating_avg": "4.50",
  "distance_km": 3.2,          // فقط في نتائج nearby
  "owner": { ... } | null,
  "created_at": "2026-08-01"
}
```

## 2.3 مسارات الورشة المتاحة لدور `workshop`
| العملية | المسار | ملاحظات |
|---|---|---|
| **ملف ورشتي** | `GET /api/workshops/my` | ⭐ الأساس |
| عرض ورشة | `GET /api/workshops/{id}` | ورشته فقط (وإلا 403) |
| تعديل ورشتي | `POST /api/workshops/{id}` | المالك ورشته فقط |
| قائمة الورش | `GET /api/workshops` | متاح (`show.workshops`) لكن نادراً ما تحتاجه |

> ⛔ **ليست للورشة:** إنشاء ورشة (`POST /workshops` سوبر أدمن)، حذف (سوبر أدمن).

## 2.4 ما تراه الورشة من الطلبات (Scoping)
الورشة ترى **الطلبات المرتبطة بورشتها** فقط: `orders.workshop_id = ورشتي`
(يُضبط `workshop_id` عندما يختار العميل هذه الورشة عبر `/workshops/nearby` أثناء الحجز).

---

# 3) الموظف: الغسّال (washer) والميكانيكي (mechanic)

## 3.1 الإنشاء
- ينشئهم السوبر أدمن فقط عبر `POST /api/admin/employees` (من لوحته) — **لا يخص تطبيقك**.
- بياناتهم: `name`, `email`, `phone`, `password`, `branch_id`, `type` (`washer`/`mechanic`).
- في تطبيقك: يسجّلون الدخول فقط عبر `login`.

## 3.2 كيان الموظف (EmployeeResource)
```json
{ "id": 9, "branch_id": 1, "type": "washer", "is_active": true,
  "rating_avg": "4.20", "user": { ... } | null }
```

## 3.3 ما يراه الموظف من الطلبات (Scoping)
الموظف يرى **الطلبات المسندة إليه فقط**: `orders.employee_id = أنا`.

## 3.4 الفرق بين الغسّال والميكانيكي
- **الغسّال:** خدمات الغسيل. يعرض/يبدأ/ينهي طلباته، يدير سجلّات مواد الطلب، يؤكّد الدفع النقدي، ينشئ تقارير.
- **الميكانيكي:** كل ما سبق + تفاصيل الصيانة والمساعدة على الطريق والسحب، المشاكل المقترحة،
  محادثة الذكاء الاصطناعي، طلبات قطع الغيار (بعض هذه بلا مسارات بعد — القسم 6).

---

# 4) تدفّق الطلب (Order Lifecycle) — قلب التطبيق

```
pending → assigned → in_progress → completed
```

| الانتقال | المسار | مَن يقوم به في تطبيقك |
|---|---|---|
| assign (إسناد لموظف) | `POST /api/bookings/{id}/assign` | ⛔ **الأدمن/السوبر أدمن فقط** (خارج تطبيقك) |
| **start** (بدء) | `POST /api/bookings/{id}/start` | ✅ الموظف/الورشة (`edit.order`) — ينقل assigned→in_progress |
| **complete** (إنهاء) | `POST /api/bookings/{id}/complete` | ✅ الموظف/الورشة — ينقل in_progress→completed |
| تعديل الطلب | `POST /api/bookings/{id}` | ✅ الموظف/الورشة (`edit.order`) |

⚠️ **تبعية مهمة جداً:** خطوة **الإسناد (assign)** صلاحيتها للأدمن فقط ولا يوجد لها مسار في نطاق هذا التطبيق.
أي: **الطلبات تصل الموظف بعد أن يُسندها الأدمن من لوحته**. تطبيقك يبدأ من الطلبات التي حالتها `assigned`
فما بعد. (إن كان مطلوباً أن تُسند الورشة الطلبات لموظفيها مستقبلاً، فهذه ميزة غير موجودة بعد — راجع الباك.)

## 4.1 قائمة الطلبات وتفاصيلها (مشترك — مع Scoping تلقائي)
- `GET /api/bookings` — قائمة طلباتي (مُصفّاة تلقائياً: الموظف→المسندة له، الورشة→طلبات ورشتها). **مُرقّمة صفحات** (`data.data` + `data.meta`).
- `GET /api/bookings/{id}` — تفاصيل طلب.

## 4.2 تفاصيل الطلب الفرعية (⚠️ للموظف، **ليست للورشة**)
هذه صلاحياتها "للجميع عدا الورشة":
| المسار | الغسّال | الميكانيكي | الورشة |
|---|:---:|:---:|:---:|
| `GET /bookings/{id}/status-history` | ✅ | ✅ | ❌ |
| `GET /bookings/{id}/price-items` | ✅ | ✅ | ❌ |
| `GET /bookings/{id}/sub-services` | ✅ | ✅ | ❌ |
| `GET /bookings/{id}/materials` | ✅ | ✅ | ❌ |

## 4.3 التفاصيل الميدانية (صيانة/طريق/سحب)
| المسار | الغسّال | الميكانيكي | الورشة |
|---|:---:|:---:|:---:|
| `GET/POST /bookings/{id}/maintenance-detail` | ❌ | ✅ | ✅ |
| `GET/POST /bookings/{id}/road-detail` | ❌ | ✅ | ✅ |
| `GET/POST /bookings/{id}/towing-detail` | ❌ | ✅ | ❌ |

## 4.4 تفاصيل الصيانة/الطريق/السحب بالتفصيل (جوهر عمل الميكانيكي)

سلوك مشترك للثلاثة، مهم جداً:
- **`GET`** يجلب التفصيل الحالي، وقد يرجع **`data: null`** إذا لم يُنشأ بعد (200 وليس 404). عالج null بعرض نموذج فارغ.
- **`POST`** يعمل **upsert** (updateOrCreate على `order_id`): يُنشئ التفصيل إن لم يوجد، ويحدّثه إن وُجد.
  فمسار واحد يكفي للإنشاء والتعديل معاً — لا تحتاج تمييزهما.
- كل الحقول **اختيارية/جزئية** — أرسل ما تعبّئه فقط.
- الصلاحية للكتابة: الطلب يجب أن تملكه/تديره (الموظف المسنَد أو الورشة صاحبة الطلب)، وإلا 403.

### أ) تفاصيل الصيانة — `maintenance-detail` (ميكانيكي + ورشة)
**الرد (MaintenanceDetailResource):**
```json
{ "id": 3, "order_id": 33, "workshop_id": 4,
  "workshop": { ... } | null, "notes": "تم فحص المحرك...",
  "created_at": "2026-08-10T..." }
```
**حقول POST:** `workshop_id?` (int، ورشة موجودة)، `notes?` (نص ≤ 5000). بسيط: ملاحظات فنّية + ربط بورشة.

### ب) تفاصيل المساعدة على الطريق — `road-detail` (ميكانيكي + ورشة)
هذا الأغنى، وغالباً **يكون منشأً مسبقاً** لأن العميل يملأه عند حجز المساعدة على الطريق؛ الميكانيكي **يُكمّله/يعدّله** (خصوصاً التشخيص).
**الرد (RoadAssistanceDetailResource):**
```json
{ "id": 5, "order_id": 40,
  "problem_type_id": 2, "problem_type": { ... } | null,
  "car_type_size": "suv",                 // sedan|suv|hatchback|pickup
  "problem_description": "البطارية فارغة",
  "problem_image_url": "https://...",
  "ai_diagnosis": "يُرجّح تلف البطارية",   // ⭐ حقل التشخيص الذي يكتبه الميكانيكي
  "ai_chat_log": [ ... ],                  // سجلّ محادثة الذكاء (عرض فقط هنا)
  "created_at": "2026-08-10T..." }
```
**حقول POST:** `problem_type_id?`، `car_type_size?` (enum: sedan/suv/hatchback/pickup)،
`problem_description?` (≤5000)، `problem_image_url?` (URL)، `ai_diagnosis?` (≤5000).
> ⚠️ `ai_chat_log` **عرض فقط** (ليس ضمن حقول POST). و`problem_type_id` عادةً مضبوط من إنشاء الحجز؛
> مصدر قائمة أنواع المشاكل للميكانيكي هو `/suggested-problems` (المتاح له)، لا `/problem-types`.

### ج) تفاصيل السحب — `towing-detail` (ميكانيكي فقط)
**الرد (TowingDetailResource):**
```json
{ "id": 2, "order_id": 40, "car_type_size": "pickup",
  "destination_lat": "24.77", "destination_lng": "46.68",
  "destination_address": "ورشة كذا - حي كذا", "notes": "...",
  "created_at": "2026-08-10T..." }
```
**حقول POST:** `car_type_size?` (enum)، `destination_lat?` (-90..90)، `destination_lng?` (-180..180)،
`destination_address?` (≤1000)، `notes?` (≤5000). أي: وجهة السحب على الخريطة + ملاحظات.

### مثال ربط (dio) — نمط GET ثم POST (upsert)
```dart
// تحميل التفصيل (قد يعود null)
final res = await dio.get('/bookings/$orderId/road-detail');
final detail = res.data['data']; // null إن لم يُنشأ بعد

// حفظ (إنشاء أو تعديل — نفس المسار)
await dio.post('/bookings/$orderId/road-detail', data: {
  'ai_diagnosis': diagnosisText,
  if (imageUrl != null) 'problem_image_url': imageUrl,
});
```

---

# 5) بقية المسارات المتاحة لكل دور (مرجع الربط)

### مشترك للأدوار الثلاثة
- **البروفايل:** `GET /api/profile/showProfile` · `POST /api/profile/updateProfile`
- **الكتالوج (قراءة):** `/categories`, `/services` (+`/categories/{id}/services`), `/sub-services`
  (+`/services/{id}/sub-services`), `/car-types`, `/car-brands`
- **المواد:** `GET /api/materials`, `/materials/{id}`
- **السيارة:** `GET /api/show/{id}` (تفاصيل سيارة الطلب)
- **التقييمات (عرض):** `GET /api/ratings`, `/ratings/{id}`
- **ورش قريبة:** `GET /api/workshops/nearby`

### الغسّال + الميكانيكي (وليس الورشة)
- **سيارات العميل:** `GET /api/indexClient` (`show.client.cars`)
- **الدفع النقدي:** `GET /api/payments/{id}` · `POST /api/payments/{id}/confirm-cash` (تأكيد استلام النقد ميدانياً)
- **قوائم مساعدة:** `/material-units`, `/pricing-rules`, `/pricing-rule-types`

### الميكانيكي فقط
- **المشاكل المقترحة:** `GET /api/suggested-problems`, `/suggested-problems/{id}`

### الورشة فقط
- مسارات الورشة (القسم 2.3) + التفاصيل الميدانية (صيانة/طريق).

> ⛔ لا يملك أي من الثلاثة: النقاط، المحافظ، الباقات، إدارة العملاء، الفروع (`/branches`)، الشركات،
> `/bookings/quote|confirm` (إنشاء الحجز للعميل)، assign، أو أي مسار إدارة (store/update/delete للكتالوج).

---

# 6) ⚠️ ميزات لها صلاحيات لكن **بلا مسارات بعد** (لا تبنِها الآن)

هذه معرّفة كصلاحيات للورشة/الموظف لكن **لا يوجد لها endpoints** في `routes/api.php` (تأكّدت بالفحص).
أي استدعاء لها غير ممكن حالياً — جهّز مكانها في الواجهة فقط، وانتظر ربط الباك:

| الميزة | الصلاحية (بلا مسار) | لمن |
|---|---|---|
| **إدارة موظفي الورشة** (إضافة/تعديل/عرض) | `add.employee`, `edit.employee`, `show.employees` | الورشة |
| **تقارير الموظف** (إنشاء/عرض) | `create.employee_report`, `show.employee_reports` | washer/mechanic/workshop |
| **طلبات قطع الغيار** (إنشاء/اعتماد/رفض) | `create/approve/reject.spare_part_request` | mechanic ينشئ، workshop يعتمد |
| **سجلّات GPS** | `manage.gps_logs` | washer/mechanic |
| **إدارة مواد الطلب** (كتابة) | `manage.order_materials` | washer/mechanic |
| **سِجِل صيانة السيارة للورشة** | `show.car_service_history` | workshop (المسار **معطّل/مُعلّق** في الروت) |
| **محادثة الذكاء الاصطناعي** | `manage.ai_chat` | mechanic |

> ملاحظة: هذا يعني أن جزءاً من "عمل الموظف الميداني" (التقارير، قطع الغيار، GPS، كتابة المواد)
> **غير جاهز على مستوى الـ API** — لا تعتمد عليه في الإصدار الأول، وأكّد مع فريق الباك موعد إتاحته.

---

# 7) خريطة الشاشات المقترحة لكل دور

### تطبيق الورشة (`workshop`)
1. تسجيل ورشة → شاشة "قيد المراجعة" → دخول بعد الاعتماد.
2. **ملف الورشة** (`/workshops/my` + تعديل).
3. **طلبات ورشتي** (`/bookings` مُصفّاة) → تفاصيل → بدء/إنهاء → تعبئة تفاصيل الصيانة/الطريق.
4. التقييمات (عرض)، الكتالوج (مرجع).
5. (لاحقاً عند توفّر الـ API) إدارة الفنّيين، اعتماد قطع الغيار، تقارير الموظفين.

### تطبيق الموظف (`washer` / `mechanic`)
1. دخول فقط (لا تسجيل).
2. **طلباتي المسندة** (`/bookings`) → تفاصيل الطلب + سجلّ الحالة + البنود + الخدمات الفرعية + المواد.
3. **بدء/إنهاء** الطلب.
4. الميكانيكي: تعبئة تفاصيل الصيانة/الطريق/السحب + المشاكل المقترحة.
5. **تأكيد الدفع النقدي** عند الاستلام (`confirm-cash`).
6. عرض سيارة العميل (`/show/{id}`, `/indexClient`).
7. (لاحقاً) تقارير الموظف، طلبات قطع الغيار، GPS، كتابة المواد.

---

# 8) قواعد ثابتة عند الربط

1. **الأدمن والسوبر أدمن خارج هذا التطبيق كلياً** — لا تبنِ لهما شيئاً، ولا "موظف admin".
2. **assign خارج نطاقك** — الطلبات تصل الموظف بعد إسناد الأدمن؛ تطبيقك يبدأ من `assigned`.
3. **Scoping تلقائي:** لا ترسل فلاتر هوية — الباك يصفّي (الموظف→المسند له، الورشة→ورشتها).
4. **قائمة الطلبات مُرقّمة صفحات** (`data.data` + `data.meta`).
5. **بعض ميزات الموظف بلا API بعد** (القسم 6) — لا تعتمد عليها.
6. **الأخطاء موحّدة:** 401 (توكن)، 403 (صلاحية/ملكية/حساب غير نشط)، 404، 422 (تحقّق مع `data` = خريطة حقول).
7. **decimal كنصوص** (`rating_avg`, الإحداثيات, الأسعار) — حوّلها لأرقام. والعلاقات `whenLoaded` قد تكون null.
