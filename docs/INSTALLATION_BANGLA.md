# CampusSphere Laravel ERP — বাংলা ইনস্টলেশন গাইড

এই ZIP-এ Laravel 12 + MySQL ব্যবহার করে একটি **ডেভেলপমেন্ট ওয়েবসাইট বেসলাইন** দেওয়া হয়েছে। এটি সম্পূর্ণ প্রোডাকশন ERP নয়।

## যা লাগবে

PHP 8.2 বা তার বেশি, Composer 2, MySQL 8 বা তার বেশি। কম্পিউটারে Composer-এর মাধ্যমে Laravel প্যাকেজ ইনস্টল করতে ইন্টারনেট প্রয়োজন হতে পারে।

## ধাপে ধাপে (Windows PowerShell)

১. ZIP Extract করে যে ফোল্ডারে **artisan** এবং **composer.json** আছে, সেখানে PowerShell খুলুন।

২. MySQL-এ নতুন খালি ডাটাবেস তৈরি করুন: `campussphere_local`

৩. নিচের কমান্ড চালান:

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
```

৪. `.env` ফাইলে `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` আপনার লোকাল MySQL অনুযায়ী ঠিক করুন। `APP_ENV=local` থাকবে।

৫. টেবিল তৈরি করুন:

```powershell
php artisan migrate
```

৬. নমুনা ডাটা বসাতে `.env`-এ অস্থায়ীভাবে `SMS_ALLOW_DEMO_SEED=true` দিয়ে চালান:

```powershell
php artisan db:seed --class=SmsFullDemoSeeder
```

**সতর্কতা:** টার্মিনালে দেখানো ডেমো ইমেইল ও পাসওয়ার্ড সংরক্ষণ করুন। পাসওয়ার্ডগুলো স্বয়ংক্রিয়ভাবে এলোমেলোভাবে তৈরি হয়। এই Seeder শুধু **খালি লোকাল ডাটাবেসে** চলবে। কাজ শেষ হলে `SMS_ALLOW_DEMO_SEED=false` করে দিন।

৭. ওয়েবসাইট চালু করুন:

```powershell
php artisan serve
```

ব্রাউজারে খুলুন: http://127.0.0.1:8000

## খুব গুরুত্বপূর্ণ

- Laravel migration ও sample SQL import **একসঙ্গে করবেন না**।
- ZIP-এ Laravel vendor dependencies অন্তর্ভুক্ত নেই; `composer install` করতে হবে।
- ২০টি মডিউলের ইন্টারফেস আছে, কিন্তু সব ব্যবসায়িক কাজের সম্পূর্ণ লজিক এখনো তৈরি হয়নি।
- প্রকৃত ছাত্র-ছাত্রী বা আর্থিক তথ্য এই আনটেস্টেড সিস্টেমে ব্যবহার করবেন না।
- প্রোডাকশনে যাওয়ার আগে role permission, payment, accounting ও security পরীক্ষা করতে হবে।
