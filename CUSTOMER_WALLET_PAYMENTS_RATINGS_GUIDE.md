# دليل الفرونت: النقاط · المحفظة · المدفوعات · التقييمات · الباقات المشتراة

> يغطّي هذا الملف التقاطعات المالية وما بعد الخدمة التي **تخص تطبيق العميل ولها مسارات فعلية**.
> كلها محميّة بـ Bearer token، وترجع بالغلاف الموحّد `{status,data,message,status_code,timestamp}`.
> قاعدة متكررة: **العميل لا يرسل `customer_id`** — الباك يأخذ هويته من التوكن (المعرّف للأدمن فقط).

الأقسام: 1) الباقات المشتراة (user-packages) · 2) المحفظة (wallet) · 3) النقاط (points)
· 4) المدفوعات (payments) · 5) التقييمات (ratings).

---

## 1) الباقات المشتراة — `user-packages`

الفرق عن `/packages`: الأخير **كتالوج** الباقات المتاحة؛ وهذا **ما اشتراه العميل فعلاً** (اشتراكاته).

### الحقول (UserPackageResource)
```json
{
  "id": 7,
  "user_id": 5,
  "package_id": 1,
  "package": { ... } | null,        // whenLoaded — تفاصيل الباقة الأصلية
  "start_date": "2026-08-01",
  "end_date": "2026-08-31",
  "remaining_count": 3,             // كم استخدام متبقٍّ
  "status": "active",               // active|expired|cancelled|suspended
  "created_at": "2026-08-01 10:00:00"
}
```

### المسارات
| العملية | المسار | ملاحظات |
|---|---|---|
| باقاتي | `GET /api/user-packages` | بلا `customer_id` — اشتراكات المستخدم الحالي |
| تفاصيل اشتراك | `GET /api/user-packages/show/{user_package}` | |
| **شراء باقة** | `POST /api/user-packages` | body: `{ "package_id": 1 }` (اختياري `status`) |
| تعديل | `POST /api/user-packages/update/{user_package}` | صلاحية `edit.user_package` |

### التدفّق
1. العميل يتصفّح `/packages` (الكتالوج، مع فلترة `is_company_package` حسب دوره).
2. يشتري: `POST /user-packages` بـ `package_id` → يُنشأ اشتراك بحالة `active` و`remaining_count` مبدئي.
3. عند الحجز يدفع بـ `payment_method: "package"` → يُخصم من `remaining_count`، ويصبح سعر الطلب 0
   (بند "Covered by Package" الذي رأيناه في تدفّق الحجز).
4. اعرض للعميل: الاشتراكات النشطة، المتبقّي، وتاريخ الانتهاء.

---

## 2) المحفظة — `wallet`

رصيد نقدي للعميل يُستخدم للدفع (`payment_method: "wallet"`) أو استرداد المبالغ.

### الحقول
**Wallet:** `id`, `user_id`, `balance`, `transactions[]` (whenLoaded), `created_at`, `updated_at`.
**WalletTransaction:**
```json
{
  "id": 12, "wallet_id": 3, "user_id": 5,
  "type": "debit",                 // credit (تغذية) | debit (خصم)
  "reason": "order_payment",       // order_payment | refund | topup | adjustment
  "amount": "50.00",
  "balance_before": "200.00",
  "balance_after": "150.00",
  "note": "...",
  "created_at": "2026-08-02T..."
}
```

### المسارات (الخاصة بالعميل)
| العملية | المسار | ملاحظات |
|---|---|---|
| **محفظتي** | `GET /api/wallets/my` | ⭐ رصيد المستخدم الحالي (صلاحية `show.wallet`) |
| حركات محفظتي | `GET /api/wallet-transactions` | بلا `customer_id` |
| تفاصيل حركة | `GET /api/wallet-transactions/show/{id}` | |

> ⚠️ `GET /api/wallets` و`/wallets/{customer_id}` و`/wallets/{id}/adjust` كلها **للأدمن** (تعديل الرصيد
> يدوياً = `adjust.wallet_balance` سوبر أدمن/أدمن). في تطبيق العميل استعمل **`/wallets/my`** فقط.

### التدفّق
- اعرض `balance` في شاشة المحفظة، وقائمة `wallet-transactions` كسجلّ حركات (credit أخضر / debit أحمر).
- الشحن (topup) والتعديل يتمّان من جهة الأدمن/بوابة الدفع؛ العميل يشاهد الأثر كحركة `credit`.

---

## 3) النقاط — `points`

نظام ولاء: نقاط تُكتسب وتُستبدل.

### الحقول
**Point (الرصيد):** `id`, `customer_id`, `balance`, `customer?`.
**PointsTransaction (حركة):**
```json
{
  "id": 9, "customer_id": 5,
  "type": "earn",                  // earn (كسب) | redeem (استبدال)
  "points": 20,
  "balance_before": 100, "balance_after": 120,
  "reference_type": "order", "reference_id": 33,
  "note": "...", "created_at": "2026-08-02 10:00:00"
}
```

### المسارات (الخاصة بالعميل)
| العملية | المسار | ملاحظات |
|---|---|---|
| **رصيد نقاطي** | `GET /api/points/show` | بلا `customer_id` |
| حركات النقاط | `GET /api/points/transactions` | بلا `customer_id` |
| تفاصيل حركة | `GET /api/points/transactions/show/{transaction}` | |

> `GET /api/points` (كل النقاط) و`POST /points/transactions/{customer_id}` (إضافة يدوية) = **للأدمن/سوبر أدمن**.

### التدفّق
- اعرض `balance` في شاشة النقاط + سجلّ الحركات (earn/redeem).
- الدفع بالنقاط في الحجز عبر `payment_method: "point"` → يُنشئ حركة `redeem`.
- إكمال الطلبات يولّد حركات `earn` تلقائياً (حسب إعدادات النقاط في الباك).

---

## 4) المدفوعات — `payments`

سجلّ عمليات الدفع المرتبطة بالطلبات/الباقات/شحن المحفظة.

### الحقول (PaymentResource — مختصرة عمداً)
```json
{
  "id": 15,
  "payment_number": "PAY-2026-000015",
  "type": "order",                 // order | package | wallet_topup
  "method": "cash",                // cash|card|wallet|point|package
  "status": "paid",                // pending|paid|failed|refunded
  "amount": "120.50",
  "points_used": 0
}
```

### المسارات (الخاصة بالعميل)
| العملية | المسار | ملاحظات |
|---|---|---|
| مدفوعاتي | `GET /api/payments` | بلا `customer_id` |
| تفاصيل دفعة | `GET /api/payments/{id}` | |

> ⚠️ `POST /api/payments/{id}/confirm-cash` (تأكيد استلام النقد) صلاحيته `confirm.cash_payment` =
> **الموظف/الأدمن/السوبر أدمن** — **ليست للعميل**. لا تضع له هذا الزر.

### التدفّق (مهم لفهم مكان الدفع)
- **لا يوجد endpoint منفصل "ادفع الآن"** للعميل — الدفع **يُنشأ ضمنياً** عند `POST /bookings/confirm`
  (تأكيد الحجز) حسب `payment_method` المُرسل في `quote`. أي: المحرّك يسوّي الدفع تلقائياً عند التأكيد.
- بعدها العميل **يعرض** مدفوعاته عبر `GET /payments` و`/payments/{id}` كسجلّ.
- الدفع النقدي (`cash`) يبقى `pending` حتى يؤكّده الموظف ميدانياً (`confirm-cash`).

---

## 5) التقييمات — `ratings`

بعد اكتمال الخدمة، يقيّم العميل الخدمة والموظف والورشة.

### الحقول (RatingResource)
```json
{
  "id": 4, "order_id": 33,
  "customer_id": 5, "customer": { ... } | null,
  "employee_id": 9, "employee": { ... } | null,
  "service_rating": 5,             // 1..5 (إلزامي)
  "employee_rating": 4,            // 1..5 (اختياري)
  "workshop_rating": 5,            // 1..5 (اختياري)
  "comment": "خدمة ممتازة",
  "image_urls": [ "https://..." ],
  "created_at": "2026-08-02T..."
}
```

### المسارات
| العملية | المسار | صلاحية | ملاحظات |
|---|---|---|---|
| قائمة تقييماتي | `GET /api/ratings` | `show.ratings` | يقبل `?per_page=15` |
| تفاصيل تقييم | `GET /api/ratings/{id}` | `show.ratings` | |
| **إنشاء تقييم** | `POST /api/ratings` | `create.rating` | انظر الحقول أدناه |
| تعديل تقييم | `POST /api/ratings/{id}` | `create.rating` | |

### حقول إنشاء التقييم (CreateRatingRequest)
| الحقل | إلزامي | القيود |
|---|---|---|
| `order_id` | ✅ | موجود في orders |
| `service_rating` | ✅ | عدد صحيح 1..5 |
| `employee_rating` | ➖ | 1..5 |
| `workshop_rating` | ➖ | 1..5 |
| `comment` | ➖ | نص ≤ 2000 |
| `image_urls` | ➖ | مصفوفة روابط (URLs) |

### التدفّق
1. بعد أن يصبح الطلب `completed`، أظهر زر "قيّم الخدمة".
2. أرسل `POST /ratings` بـ `order_id` + التقييمات.
3. التقييم يرفع `rating_avg` للموظف/الورشة (يظهر لاحقاً في `/workshops/nearby` وتفاصيل الطلب).
4. ⚠️ `image_urls` هنا **روابط جاهزة** (لا رفع ملفات مباشر في هذا الطلب) — ارفع الصور أولاً إن توفّر
   مسار رفع، ثم مرّر روابطها. (لا يوجد رفع multipart في هذا الـ endpoint.)

---

## خلاصة سريعة — ما يخص تطبيق العميل وله مسارات

| المجال | مسار العميل الأساسي | إنشاء/فعل للعميل؟ |
|---|---|---|
| الباقات المشتراة | `GET /user-packages` | ✅ `POST /user-packages` (شراء) |
| المحفظة | `GET /wallets/my` + `/wallet-transactions` | ❌ (عرض فقط؛ الشحن من الأدمن/البوابة) |
| النقاط | `GET /points/show` + `/points/transactions` | ❌ (عرض فقط؛ تُدار تلقائياً) |
| المدفوعات | `GET /payments` + `/payments/{id}` | ❌ (تُنشأ ضمن confirm الحجز) |
| التقييمات | `GET /ratings` | ✅ `POST /ratings` (بعد الإكمال) |

**تنبيهات ثابتة:** لا ترسل `customer_id`؛ المبالغ decimal **كنصوص** (حوّلها لأرقام)؛ العلاقات
`whenLoaded` قد تكون null؛ الأخطاء موحّدة 401/403/404/422؛ تأكيد النقد (`confirm-cash`) والتعديلات
اليدوية للأدمن فقط.
