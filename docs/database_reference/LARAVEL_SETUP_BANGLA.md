# School / College / Madrasha ERP — Laravel Database Setup (বাংলা)

**এই ZIP-এ Laravel + MySQL database foundation এবং তিনটি প্রতিষ্ঠানের ডেমো ডাটা আছে। এটি সম্পূর্ণ ERP application নয়।**

## পদ্ধতি ১ — Laravel দিয়ে (প্রস্তাবিত)

১. আপনার লোকাল কম্পিউটারে PHP, Composer, MySQL 8+ এবং Laravel project প্রস্তুত করুন।

২. MySQL-এ একটি **নতুন খালি database** তৈরি করুন, যেমন `sms_erp_local`।

৩. ZIP থেকে `database/migrations/` ও `database/seeders/` ফোল্ডারের ফাইলগুলো Laravel project-এর একই ফোল্ডারে কপি করুন। Laravel project-এর ডিফল্ট `users` migration রাখুন।

৪. `.env` ফাইলে আপনার লোকাল MySQL তথ্য বসান:

```dotenv
APP_ENV=local
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sms_erp_local
DB_USERNAME=your_local_user
DB_PASSWORD=your_local_password
SMS_ALLOW_DEMO_SEED=true
```

৫. Laravel project folder থেকে Terminal/CMD খুলে চালান:

```bash
php artisan migrate
php artisan db:seed --class=SmsFullDemoSeeder
```

৬. Terminal-এ যে **random demo password** দেখা যাবে তা সংরক্ষণ করুন। তারপর `.env` থেকে `SMS_ALLOW_DEMO_SEED=true` সরিয়ে দিন।

**সতর্কতা:** ডেমো ডাটা শুধুমাত্র লোকাল/টেস্টিং database-এর জন্য। আগে থেকে ব্যবহৃত স্কুলের database-এ চালাবেন না। `SmsPermissionSeeder` আলাদাভাবে আগে চালানোর প্রয়োজন নেই, কারণ `SmsFullDemoSeeder`-এ ৩৮টি permissions অন্তর্ভুক্ত আছে।

## পদ্ধতি ২ — phpMyAdmin-এ সরাসরি .sql Import

১. নতুন খালি database তৈরি করুন।

২. `database/sql/SMS_ERP_MYSQL8_FULL_DEMO.sql` নির্বাচন করে Import করুন।

৩. Laravel integration-এর জন্য **পদ্ধতি ১** ব্যবহার করা ভালো। SQL দিয়ে Import করলে Laravel-এর `migrations` history তৈরি হয় না; এরপর সেই database-এ নতুন Laravel project-এর `php artisan migrate` সরাসরি চালালে existing table conflict হতে পারে।

## ডেমো ডাটা

- Demo Sunrise School
- Demo Horizon College
- Demo Noorul Huda Madrasha

ডেমোতে ছাত্র/ছাত্রী, শিক্ষক, অভিভাবক, ভর্তি, ফি, আংশিক পেমেন্ট, লেজার, পরীক্ষা, হাজিরা, হিফজ প্রগ্রেস, লাইব্রেরি, হোস্টেল এবং অন্যান্য মডিউলের নমুনা তথ্য রয়েছে। সব তথ্য কাল্পনিক।

**Production-এর আগে:** Laravel controllers, API, authorization, business services, payment integration, official reporting এবং পূর্ণ security/QA তৈরি করতে হবে।
