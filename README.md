# Chat & Dating V1.0

تطبيق دردشة وتعارف متعدد المنصات مبني على Flutter + Supabase.

## المنصات
- Android
- iOS
- Web

## المزايا
- تسجيل/دخول بالبريد وكلمة المرور
- ملف شخصي: الاسم، العمر، الجنس، الدولة، النبذة، الصورة
- اكتشاف المستخدمين حسب الجنس والدولة
- إعجاب و Match
- دردشة خاصة Realtime
- بحث فوري عن أشخاص يبحثون بنفس الوقت
- حظر وإبلاغ
- إشعارات داخل التطبيق
- Dark / Light / System
- تصميم RTL عربي

## التشغيل
1. ثبّت Flutter.
2. أنشئ مشروع Flutter فارغ أو انسخ هذه الملفات فوق مشروع Flutter جديد.
3. أضف الحزم الموجودة في `pubspec.yaml`.
4. أنشئ مشروع Supabase.
5. نفّذ `supabase/schema.sql` في SQL Editor.
6. أنشئ ملف `.env` من `.env.example` وضع:
   SUPABASE_URL=...
   SUPABASE_ANON_KEY=...
7. شغّل:
   flutter pub get
   flutter run

> ملاحظة: ملفات Android/iOS الأصلية المولدة بواسطة Flutter ليست مضمنة لتقليل حجم الحزمة. استخدم `flutter create .` داخل المجلد بعد فك الضغط إذا احتجت ملفات المنصات.
