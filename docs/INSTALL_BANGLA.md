# CampusSphere — কেন সবসময় ডেটা Empty ছিল, এবং কীভাবে ঠিক করবেন

আপনার আপলোড করা `scm-system.sql` ফাইলে স্কুল অ্যাডমিন, স্কুল এবং Permissions আছে; কিন্তু Student, Fees, Exam, Attendance-এর নমুনা রেকর্ড নেই। Laravel-এর Source/PATCH ZIP শুধু কপি করলে ডেটাবেজে রেকর্ড **স্বয়ংক্রিয়ভাবে যোগ হয় না**। আপনাকে Seeder রান করতে হবে অথবা নতুন আলাদা ডেটাবেজে Demo SQL Import করতে হবে।

**সবচেয়ে নিরাপদ পদ্ধতি:** আগে `scm-system` ডেটাবেজ Backup/Export করুন; একটি LOCAL/STAGING কপি ব্যবহার করুন। ZIP Extract করে `database/seeders/` ফাইলগুলো Laravel প্রজেক্টে কপি করুন। `.env`-এ:

```env
APP_ENV=local
SMS_ALLOW_SCM_FULL_SAMPLE=true
SMS_ALLOW_RICH_DEMO_SEED=true
SMS_ALLOW_DEMO_REPAIR=true
CACHE_STORE=file
SESSION_DRIVER=file
```

Laravel প্রজেক্ট ফোল্ডারে CMD চালান:

```bash
php artisan config:clear
php artisan db:seed --class=SmsScmFullSampleSeeder
```

সফল হলে ৩টি Demo প্রতিষ্ঠান এবং মোট ৭৫ জন Demo Student সহ Attendance, Exam, Fees, Payment, Accounts, Library, Hifz ইত্যাদির নমুনা রেকর্ড আসবে। পরে তিনটি SMS_ALLOW পতাকা `false` করে `php artisan config:clear` চালান।

**আপনার লোকাল ডেমো লগইন**

- Email: `admin.school@example.test`
- Password: `SchoolAdmin@2026`

**গুরুত্বপূর্ণ:** এটা শুধুই Local Demo Password। Production চালু করার আগে বদলাতে হবে। বর্তমানে ডেটাবেজে সত্যিকারের শিক্ষার্থীর তথ্য থাকলে এই Seeder রান করবেন না। SQL ফাইলটি শুধু নতুন খালি ডেটাবেজে Import করা যাবে।
