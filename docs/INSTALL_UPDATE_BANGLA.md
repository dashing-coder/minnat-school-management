# CampusSphere ERP — Laravel ইনস্টল ও আপডেট (বাংলা)

**সতর্কতা:** এটি Laravel/PHP/MySQL সোর্স কোডের একটি বর্ধিত ডেভেলপমেন্ট সংস্করণ। সব ১৮টি ফেজ production-tested সম্পূর্ণ নয়। বাস্তব শিক্ষার্থীর তথ্য নিয়ে ব্যবহার করার আগে QA প্রয়োজন।

## আপনার আগের লগইন চালু থাকলে

1. Laravel Project folder এবং MySQL database **ব্যাকআপ** নিন।
2. `CampusSphere_ERP_Expanded_PATCH_ONLY.zip` খুলে ফাইলগুলো সতর্কভাবে merge করুন। সরাসরি পুরোনো প্রোজেক্ট overwrite করবেন না।
3. আগের `.env` পরিবর্তন করবেন না। বিশেষভাবে `SESSION_DRIVER=file`, `CACHE_STORE=file` রাখুন।
4. প্রোজেক্ট ফোল্ডারে Command Prompt/PowerShell চালু করে লিখুন:

```powershell
php artisan config:clear
php artisan migrate:status
php artisan sms:qa
php artisan route:list
```

5. Test database-এ Module ও workflow পরীক্ষা করুন। আপনার `admin.school@example.test` ব্যবহারকারীর পুরোনো কার্যকর পাসওয়ার্ডই থাকবে; পাসওয়ার্ড আবার reset করার প্রয়োজন নেই।

## একদম নতুন Installation হলে

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
```

এরপর `.env` ফাইলে MySQL নাম/ইউজার/পাসওয়ার্ড এবং নিজের port দিন (আপনার আগের MySQL port ছিল 3307)। একটি **খালি** database তৈরি করে চালান:

```powershell
php artisan migrate
```

ডেমো ডেটা চাইলে `.env` ফাইলে `SMS_ALLOW_DEMO_SEED=true` লিখে:

```powershell
php artisan db:seed --class=SmsFullDemoSeeder
```

স্ক্রিনে দেখানো **random login password সংরক্ষণ করুন**। শেষে `SMS_ALLOW_DEMO_SEED=false` করুন।

```powershell
php artisan serve
```

ব্রাউজারে খুলুন: `http://127.0.0.1:8000/login`

## নতুন ফিচার

২০টি Modules, ৫০টি master-data create/edit register, ২৭টি guided operational workflows, ৮টি reports, User & Role management (local demo), Certificate Verification, এবং PHP syntax/fixture QA।

**এখনও বাকি:** live payment gateway, SMS, biometric, পুরো payroll, mobile app, board integrations, UAT, security penetration testing এবং production Go-Live।
