# تطبيق «أين هم» للآيفون (WhereAreThey iOS App)

تطبيق native مخصص لأجهزة آيفون (iOS) مبني بأحدث تقنيات أبل **Swift 5** و **SwiftUI** ومتصل مباشرة بـ REST APIs للمنصة الوطنية للبحث عن المفقودين.

---

## 🛠️ هيكلية المشروع (Project Architecture):

- `WhereAreTheyApp.swift`: نقطة انطلاق التطبيق وضبط الاتجاه العربي (RTL) والثيم المظلم.
- `Services/APIService.swift`: محرك الاتصالات بالشبكة باستخدام `async/await` و `URLSession`.
- `Models/Notice.swift`: نماذج البيانات (البلاغات، الإفادات، بوابة الأسرة، إحصائيات المنصة).
- `ViewModels/`:
  - `NoticesViewModel.swift`: إدارة قائمة البلاغات والتصفية والبحث الحية.
  - `FamilyPortalViewModel.swift`: استعلام وتتبع تحديثات بلاغات العائلات.
  - `StatsViewModel.swift`: إحصائيات ومؤشرات استجابة المنصة.
- `Views/`:
  - `Main/MainTabView.swift`: شريط التنقل الرئيسي (الرئيسية، الخريطة، بوابة الأسرة، الإحصائيات).
  - `Notices/NoticeListView.swift`: شاشة التصفح والفلترة والبحث.
  - `Notices/NoticeCardView.swift`: بطاقات البلاغات الزجاجية الفاخرة.
  - `Notices/NoticeDetailView.swift`: شاشة التفاصيل الكاملة والملف الطبي وزر الاتصال بالطوارئ 1515.
  - `Map/IntelMapView.swift`: خريطة البلاغات الميدانية الحية عبر **MapKit**.
  - `Tips/SubmitTipView.swift`: شاشة إرسال الإفادات والمشاهدات الميدانية بشكل سرّي ومجهول.
  - `FamilyPortal/FamilyPortalView.swift`: بوابة الأسرة الخاصة برقم البلاغ الموحد.
  - `Stats/StatsView.swift`: لوحة المؤشرات الإحصائية الحية 2x2.

---

## 🚀 كيفية فتح المشروع في Xcode:

1. افتح برنامج **Xcode** على جهاز ماك (Mac).
2. اختر **Create a new Xcode project** -> **App** (SwiftUI).
3. اختر اسم المشروع: `WhereAreTheyiOS` والـ Bundle Identifier: `com.ainhum.WhereAreThey`.
4. اسحب مجلد `WhereAreTheyiOS` إلى المشروع.
5. يمكنك التشغيل المباشر على المحاكي (iOS Simulator) أو جهاز الآيفون الحقيقي!
