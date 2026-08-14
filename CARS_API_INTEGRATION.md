# توصيف ربط واجهة السيارات (Cars API) — لتطبيق الفلاتر

> هذا الملف موجّه لي (Claude) داخل مشروع الفرونت-إند (Flutter) لأربط شاشات السيارات
> بالـ Back-end. اقرأه بالكامل قبل البدء بأي ربط. كل ما يخص السيارات موجود هنا:
> الـ routes، شكل الطلب والرد، الأخطاء، الصلاحيات، ونماذج Dart المقترحة.

---

## 0) الخلاصة السريعة (TL;DR)

- كل الطلبات محميّة بـ **Sanctum Bearer Token** يُؤخذ من ردّ تسجيل الدخول.
- الـ Base URL: `https://<host>/api`  (كل مسارات هذا الملف تبدأ بـ `/api/cars/...`).
- التطبيق يخدم نوعَي مستخدم فقط: **العميل الفردي `customer_personal`** و**عميل الشركة `customer_company`**.
- هذان الدوران **لا يرسلان `customer_id` أبداً** — الـ Back-end يستخدم هوية المستخدم من التوكن تلقائياً.
- المسارات ذات `{customer_id?}` أو `/all` مخصّصة للأدمن/سوبر أدمن فقط، وليست لشاشات هذا التطبيق.
- كل رد يأتي داخل **غلاف موحّد (envelope)** واحد: `{ status, data, message, status_code, timestamp }`.
- ⚠️ ملاحظتان مهمتان جداً في التصميم:
  - **التعديل يتم عبر `POST`** وليس `PUT/PATCH` (بسبب رفع الصورة multipart).
  - **الحذف يتم عبر `GET`** وليس `DELETE` (تصميم الـ Back-end هكذا فعلاً).

---

## 1) الإعداد العام (Base client)

### 1.1 الترويسات (Headers) في كل طلب
```
Accept: application/json          // إلزامي — يجبر السيرفر على إرجاع أخطاء JSON بدل صفحات HTML
Authorization: Bearer <token>     // في كل طلبات السيارات (كلها محميّة)
Content-Type: application/json    // للطلبات بدون ملفات (GET لا يحتاجه)
```
عند رفع صورة (إنشاء/تعديل السيارة) لا تضع `Content-Type` يدوياً؛ اترك مكتبة الـ HTTP
(dio / http) تضبط `multipart/form-data` مع boundary تلقائياً.

### 1.2 مصدر التوكن
التوكن يأتي من `POST /api/auth/login`. شكل ردّه:
```json
{
  "status": 1,
  "data": {
    "id": 5,
    "name": "Omar",
    "email": "omar@example.com",
    "phone": "0999...",
    "image_url": null,
    "is_active": true,
    "role": "customer_personal",
    "token": "12|abcdef....."
  },
  "message": "Logged in successfully",
  "status_code": 200,
  "timestamp": "2026-08-03T10:00:00+00:00"
}
```
- خزّن `data.token` في secure storage وأرسله في `Authorization`.
- الحقل `data.role` يحدّد أي نوع مستخدم أمامك (`customer_personal` أو `customer_company`) —
  استعمله لإظهار/إخفاء عناصر واجهة مثل زر الأسطول (fleet) لعميل الشركة.

---

## 2) غلاف الرد الموحّد (Response Envelope)

كل الردود — نجاح أو فشل — بنفس الشكل:
```json
{
  "status": 1,                 // 1 = نجاح، 0 = فشل
  "data": {...} | [...] | [],  // المحتوى الفعلي
  "message": "نص للمستخدم",
  "status_code": 200,
  "timestamp": "2026-08-03T10:00:00+00:00"
}
```
قاعدة عملية في الفلاتر:
- انظر أولاً إلى `status` (1/0) أو إلى HTTP status code.
- عند النجاح: اقرأ `data`.
- عند الفشل: اعرض `message` للمستخدم، واقرأ `data` لتفاصيل الأخطاء (خصوصاً أخطاء التحقق 422).

### شكل `data` حسب نوع العملية
- **قائمة** (indexClient): `data` = مصفوفة كائنات سيارة `[ {...}, {...} ]` (بدون ترقيم صفحات).
- **عنصر واحد** (show / store / update): `data` = كائن سيارة واحد `{...}`.
- **حذف** (destroy): `data` = `[]` مصفوفة فارغة.

---

## 3) نوعا المستخدم والصلاحيات

| العملية | الراوت | صلاحية مطلوبة | `customer_personal` | `customer_company` |
|---|---|---|:---:|:---:|
| عرض سياراتي | `GET /cars/indexClient` | `show.client.cars` | ✅ | ✅ |
| إضافة سيارة | `POST /cars` | `add.car` | ✅ | ✅ |
| عرض سيارة | `GET /cars/show/{id}` | `show.car` | ✅ | ✅ |
| تعديل سيارة | `POST /cars/update/{id}` | `edit.car` | ✅ | ✅ |
| حذف سيارة | `GET /cars/delete/{id}` | `delete.car` | ✅ | ✅ |
| كل السيارات (لوحة تحكم) | `GET /cars/all` | `show.cars` | ❌ | ❌ |

خلاصة: **الدوال الخمس الأولى فقط** تخص هذا التطبيق. الراوت `/cars/all` وأي استدعاء بـ
`customer_id` يعودان للأدمن وسيُرجعان **403** إن ناداهما العميل، فلا تربطهما في شاشات العميل.

بالإضافة إلى قيود الصلاحيات، الـ Back-end يفرض **ملكية السيارة** في طبقة الخدمة:
- **التعديل:** يُسمح فقط لمالك السيارة (أو أدمن/سوبر أدمن). غير ذلك ⇒ `403` بنوع `CAR_UPDATE_UNAUTHORIZED`.
- **الحذف:** يُسمح فقط لمالك السيارة (أو سوبر أدمن). غير ذلك ⇒ `403` بنوع `CAR_DELETE_UNAUTHORIZED`.
عملياً: العميل يستطيع تعديل/حذف سياراته هو فقط. صمّم الواجهة على هذا الأساس.

---

## 4) الحقول (Schema) لكائن السيارة

### 4.1 شكل كائن السيارة في الردود (CarResource)
```json
{
  "id": 12,
  "user_id": 5,
  "brand_id": 3,
  "car_type_id": 2,
  "branch_id": 1,
  "plate_number": "ABC-1234",
  "model": "Corolla",
  "year": 2021,
  "color": "White",
  "fuel_type": "petrol",              // enum نصّي
  "cylinders": 4,                     // قد يكون null
  "mileage": 55000,                   // قد يكون null
  "image_url": "https://host/storage/cars/xyz.jpg",  // رابط كامل أو null
  "is_active": true,
  "owner":  { ... } | null,           // يظهر فقط عند تحميله (انظر 4.3)
  "car_type": { ... } | null,         // يظهر فقط عند تحميله
  "branch": { "id":1, "name":"...", "name_ar":"...", "city":"..." } | null,
  "created_at": "2026-08-01",         // تاريخ فقط (YYYY-MM-DD)
  "updated_at": "2026-08-02"
}
```

### 4.2 قِيَم `fuel_type` المسموحة (enum)
```
petrol | diesel | electric | hybrid
```
استعملها كقيمة ثابتة في قائمة منسدلة (Dropdown). القيمة المُرسَلة والمُستقبَلة هي النص الإنجليزي أعلاه.

### 4.3 العلاقات المضمّنة (متى تظهر؟)
مهم لتفادي أخطاء null في الفلاتر — العلاقات لا تُحمّل دائماً:
- `GET /cars/show/{id}` ⇒ يحمّل `owner` + `car_type` + `branch`.
- `GET /cars/indexClient` ⇒ يحمّل `car_type` فقط (بدون owner و branch).
- `POST /cars` (إنشاء) و`POST /cars/update/{id}` (تعديل) ⇒ **لا يحمّلان أي علاقة**؛ العنصر المُعاد
  يحوي المفاتيح (`brand_id`, `car_type_id`, `branch_id`) فقط دون كائنات `car_type`/`branch`/`owner`.

القاعدة: عامِل `owner`, `car_type`, `branch` دائماً كحقول **قابلة أن تكون null** في موديل Dart.

---

## 5) تفاصيل كل Endpoint

> جميع المسارات أدناه محميّة (تحتاج Bearer token) وتبدأ بـ `/api`.

### 5.1 عرض سياراتي — `GET /api/cars/indexClient`
- **مَن:** العميل الفردي وعميل الشركة.
- **لا ترسل `customer_id`** — لا في المسار ولا في الـ body. السيرفر يجلب سيارات المستخدم صاحب التوكن.
- **Body:** لا يوجد.
- **الرد (200):**
```json
{
  "status": 1,
  "data": [
    { "id": 12, "user_id": 5, "plate_number": "ABC-1234", "model": "Corolla",
      "year": 2021, "fuel_type": "petrol", "car_type": { ... }, "branch": null, ... }
  ],
  "message": "User cars retrieved successfully",
  "status_code": 200
}
```
- **ملاحظة:** لا يوجد pagination هنا — القائمة كاملة دفعة واحدة.

---

### 5.2 إضافة سيارة — `POST /api/cars`
- **مَن:** العميل الفردي وعميل الشركة. **لا ترسل `customer_id`**.
- **نوع المحتوى:** `multipart/form-data` (لأن هناك حقل صورة اختياري).
- **الحقول:**

| الحقل | إلزامي؟ | النوع / القيود |
|---|---|---|
| `brand_id` | ✅ | int — موجود في `car_brands` |
| `car_type_id` | ✅ | int — موجود في `car_types` |
| `branch_id` | ✅ | int — موجود في `branches` |
| `plate_number` | ✅ | string (≤255) — **فريد** عبر كل السيارات |
| `model` | ✅ | string (≤255) |
| `year` | ✅ | 4 أرقام، بين 1900 والسنة الحالية |
| `color` | ✅ | string (≤255) |
| `fuel_type` | ✅ | أحد: petrol/diesel/electric/hybrid |
| `cylinders` | ➖ | int 1..16 (اختياري) |
| `mileage` | ➖ | int ≥ 0 (اختياري) |
| `image` | ➖ | ملف صورة jpg/jpeg/png/webp، ≤ 2MB. **اسم الحقل `image` وليس `image_url`** |

- **مهم:** اسم حقل الصورة في الطلب هو **`image`**. السيرفر يخزّنها ويعيد `image_url` كرابط كامل في الرد.
- **الرد (200):** كائن السيارة المُنشأة (بدون علاقات محمّلة).
```json
{ "status": 1, "data": { "id": 30, "user_id": 5, "plate_number": "...", ... },
  "message": "Car added successfully", "status_code": 200 }
```
- لبناء نموذج الإضافة تحتاج قوائم منسدلة من endpoints أخرى (انظر القسم 7).

---

### 5.3 عرض سيارة واحدة — `GET /api/cars/show/{id}`
- **مَن:** الجميع (بما فيهم العميل). `{id}` = معرّف السيارة.
- **Body:** لا يوجد.
- **الرد (200):** كائن سيارة **مع** `owner` + `car_type` + `branch` محمّلة.
- **404** إن لم يوجد المعرّف.

---

### 5.4 تعديل سيارة — `POST /api/cars/update/{id}`
- ⚠️ **الطريقة `POST`** (ليست PUT/PATCH). `{id}` = معرّف السيارة.
- **مَن:** مالك السيارة فقط (أو أدمن). خلاف ذلك ⇒ 403.
- **نوع المحتوى:** `multipart/form-data` عند إرسال صورة، وإلا يكفي form-data عادي.
- **كل الحقول اختيارية (`sometimes`)** — أرسل فقط ما تغيّر. نفس قيود الإنشاء لكل حقل، بالإضافة إلى:
  - `is_active` (اختياري): boolean.
  - `plate_number`: يبقى **فريداً** لكن يتجاهل السيارة الحالية عند فحص التكرار.
  - `image`: نفس اسم الحقل `image`، اختياري؛ إرساله يستبدل الصورة.
- **الرد (200):** كائن السيارة بعد التحديث (بدون علاقات محمّلة).
```json
{ "status": 1, "data": { "id": 12, ... }, "message": "Car updated successfully", "status_code": 200 }
```
- ملاحظة فلاتر: بما أن الرد لا يحمل `car_type`/`branch`، إن كنت تعرض بطاقة تفصيلية بعد التعديل
  فأعد جلب `GET /cars/show/{id}` أو ادمج التغييرات محلياً.

---

### 5.5 حذف سيارة — `GET /api/cars/delete/{id}`
- ⚠️ **الطريقة `GET`** (ليست DELETE). `{id}` = معرّف السيارة.
- **مَن:** مالك السيارة فقط (أو سوبر أدمن). خلاف ذلك ⇒ 403.
- **Body:** لا يوجد.
- **الرد (200):**
```json
{ "status": 1, "data": [], "message": "Car deleted successfully", "status_code": 200 }
```
- السيرفر يحذف أيضاً ملف الصورة المخزّن تلقائياً.

---

## 6) معالجة الأخطاء (موحّدة لكل المشروع)

كل الأخطاء تأتي بنفس الغلاف مع `status: 0`. عالِجها مركزياً في الـ HTTP interceptor:

| HTTP | المعنى | ماذا في الرد | تصرّف الفلاتر |
|---|---|---|---|
| **401** | غير مصادَق (توكن مفقود/منتهٍ) | `message: "Unauthenticated"` | سجّل خروج + أعد لشاشة الدخول |
| **403** | صلاحية ناقصة أو لست المالك | `message` توضيحي | اعرض تنبيه "غير مصرّح" |
| **404** | المورد غير موجود | `message: "Resource not found"` | اعرض "غير موجود" |
| **422** | فشل تحقّق المدخلات | `data` = خريطة أخطاء الحقول | اعرض الأخطاء تحت الحقول |
| **403 (خاص)** | تعديل/حذف سيارة لا تملكها | `message` مثل "You are not allowed to update this car." | تنبيه مخصّص |

### شكل خطأ التحقق (422)
```json
{
  "status": 0,
  "data": {
    "plate_number": ["The plate number has already been taken."],
    "year": ["The year must be 4 digits."]
  },
  "message": "The plate number has already been taken. (and 1 more error)",
  "status_code": 422
}
```
في الفلاتر: `data` هنا `Map<String, List<String>>` — اربط كل مفتاح بحقله في الفورم واعرض أول رسالة.

### حالة الحساب غير النشط
بعض المسارات تمرّ عبر ميدل وير التفعيل. إن كان `is_active = false` قد يعود **403** مع
`message: "Your account is inactive."` — عالجها كحالة "حساب معطّل".

---

## 7) Endpoints مساعدة لبناء فورم الإضافة/التعديل

لملء القوائم المنسدلة في فورم السيارة تحتاج (كلها محميّة بـ Bearer، والعميل يملك صلاحيتها):
- `GET /api/car-brands`  → لملء `brand_id` (صلاحية `show.car_brands`).
- `GET /api/car-types`   → لملء `car_type_id` (صلاحية `show.car_types`).
- `GET /api/branches`    → لملء `branch_id` (صلاحية `show.branches`).

`fuel_type` قائمة ثابتة محلياً: `petrol / diesel / electric / hybrid` (لا حاجة لـ endpoint).

> ملاحظة: تفاصيل هذه الثلاثة ليست ضمن نطاق هذا الملف (طلب المستخدم كان cars فقط)،
> لكنها مذكورة لأنها لازمة لإكمال فورم السيارة. اطلب توصيفها لاحقاً عند ربط الفورم فعلياً.

---

## 8) نماذج Dart مقترحة

```dart
/// غلاف الرد الموحّد
class ApiResponse<T> {
  final int status;        // 1 نجاح / 0 فشل
  final T? data;
  final String message;
  final int statusCode;

  ApiResponse({required this.status, this.data, required this.message, required this.statusCode});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? parse) {
    return ApiResponse(
      status: json['status'] as int,
      data: parse != null ? parse(json['data']) : json['data'] as T?,
      message: json['message']?.toString() ?? '',
      statusCode: json['status_code'] as int? ?? 0,
    );
  }
}

enum FuelType { petrol, diesel, electric, hybrid }

class CarType {
  final int id;
  final String? name;
  final String? nameAr;
  CarType({required this.id, this.name, this.nameAr});
  factory CarType.fromJson(Map<String, dynamic> j) =>
      CarType(id: j['id'], name: j['name'], nameAr: j['name_ar']);
}

class Branch {
  final int id;
  final String? name;
  final String? nameAr;
  final String? city;
  Branch({required this.id, this.name, this.nameAr, this.city});
  factory Branch.fromJson(Map<String, dynamic> j) =>
      Branch(id: j['id'], name: j['name'], nameAr: j['name_ar'], city: j['city']);
}

class Car {
  final int id;
  final int? userId;
  final int? brandId;
  final int? carTypeId;
  final int? branchId;
  final String? plateNumber;
  final String? model;
  final int? year;
  final String? color;
  final FuelType? fuelType;
  final int? cylinders;
  final int? mileage;
  final String? imageUrl;   // رابط كامل جاهز للعرض
  final bool isActive;
  final CarType? carType;   // قد يكون null (لا يُحمّل دائماً)
  final Branch? branch;     // قد يكون null
  // owner متروك حسب حاجتك

  Car({
    required this.id, this.userId, this.brandId, this.carTypeId, this.branchId,
    this.plateNumber, this.model, this.year, this.color, this.fuelType,
    this.cylinders, this.mileage, this.imageUrl, this.isActive = true,
    this.carType, this.branch,
  });

  factory Car.fromJson(Map<String, dynamic> j) => Car(
    id: j['id'],
    userId: j['user_id'],
    brandId: j['brand_id'],
    carTypeId: j['car_type_id'],
    branchId: j['branch_id'],
    plateNumber: j['plate_number'],
    model: j['model'],
    year: j['year'],
    color: j['color'],
    fuelType: j['fuel_type'] == null
        ? null
        : FuelType.values.firstWhere((e) => e.name == j['fuel_type']),
    cylinders: j['cylinders'],
    mileage: j['mileage'],
    imageUrl: j['image_url'],
    isActive: j['is_active'] == true,
    carType: j['car_type'] is Map ? CarType.fromJson(j['car_type']) : null,
    branch: j['branch'] is Map ? Branch.fromJson(j['branch']) : null,
  );
}
```

### مثال إرسال إنشاء سيارة (dio + multipart)
```dart
final form = FormData.fromMap({
  'brand_id': brandId,
  'car_type_id': carTypeId,
  'branch_id': branchId,
  'plate_number': plateNumber,
  'model': model,
  'year': year,
  'color': color,
  'fuel_type': fuelType.name,           // 'petrol' ...
  if (cylinders != null) 'cylinders': cylinders,
  if (mileage != null) 'mileage': mileage,
  if (imageFile != null)
    'image': await MultipartFile.fromFile(imageFile.path),  // اسم الحقل 'image'
});

final res = await dio.post('/cars', data: form); // بدون customer_id
```

### مثال تعديل (POST + الحقول المتغيّرة فقط)
```dart
final form = FormData.fromMap({
  if (newColor != null) 'color': newColor,
  if (newMileage != null) 'mileage': newMileage,
  if (imageFile != null) 'image': await MultipartFile.fromFile(imageFile.path),
});
final res = await dio.post('/cars/update/$carId', data: form); // POST وليس PUT
```

### مثال حذف (GET)
```dart
final res = await dio.get('/cars/delete/$carId'); // GET وليس DELETE
```

---

## 9) قائمة تحقّق قبل اعتبار الربط مكتملاً

- [ ] كل طلبات السيارات تُرسل `Authorization: Bearer <token>` و`Accept: application/json`.
- [ ] لا يُرسَل `customer_id` مطلقاً من شاشات العميل.
- [ ] الإنشاء والتعديل يستخدمان `multipart/form-data` واسم حقل الصورة `image`.
- [ ] التعديل عبر `POST /cars/update/{id}` والحذف عبر `GET /cars/delete/{id}`.
- [ ] معالج أخطاء مركزي يفكّ 401/403/404/422 من الغلاف الموحّد.
- [ ] موديل `Car` يتعامل مع `car_type`/`branch`/`owner` كقيم قد تكون null.
- [ ] `fuel_type` كقائمة ثابتة (petrol/diesel/electric/hybrid).
- [ ] بعد التعديل، إعادة جلب `show/{id}` إن احتجت العلاقات للعرض.
```
