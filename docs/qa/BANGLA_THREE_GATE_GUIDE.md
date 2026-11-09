# CampusSphere ERP — Laravel QA, Browser QA ও Pilot UAT (বাংলা)

**সতর্কতা:** আপনার চালু `scm-system` ডাটাবেজে `migrate:fresh`, `db:wipe`, `RefreshDatabase` টেস্ট বা ডেমো সিডার চালাবেন না। আগে সম্পূর্ণ ব্যাকআপ নিন।

**১) আলাদা স্টেজিং:** একটি `campussphere_staging` ডাটাবেজে কাজের ডাটাবেজের কপি রাখুন। আপনার স্টেজিং Laravel প্রজেক্টের `.env`-এ সেটি ব্যবহার করুন। `.env.testing`-এ আলাদা **খালি** `campussphere_test` ডাটাবেজ সেট করুন। XAMPP/MariaDB-র পোর্ট আপনার ক্ষেত্রে সাধারণত `3307`; নিজের সেটিং যাচাই করুন।

**২) Laravel/MySQL পরীক্ষা:** স্টেজিং প্রজেক্ট ফোল্ডারে PowerShell খুলুন এবং নিচের কমান্ডগুলো দিন:

```powershell
composer install
php artisan config:clear
php scripts/qa_runtime_preflight.php --mode=staging
php artisan migrate:status
php artisan sms:qa
php artisan sms:finance:reconcile --json
powershell -ExecutionPolicy Bypass -File .\scripts\Run-StagingQA-Safe.ps1 -RunDatabaseTests
```

শেষের টেস্টে `campussphere_test` ডাটাবেজের টেবিল পুনরায় তৈরি হতে পারে; স্টেজিং/লাইভ ডাটাবেজ নয়।

**৩) Browser QA:** একটি PowerShell-এ `php artisan serve --host=127.0.0.1 --port=8001` চালু রাখুন। আরেকটিতে:

```powershell
npm install
npx playwright install chromium
$env:QA_BASE_URL='http://127.0.0.1:8001'
$env:QA_ADMIN_EMAIL='admin.school@example.test'
$env:QA_ADMIN_PASSWORD='SchoolAdmin@2026'
npm run qa:browser
```

এগুলো শুধুমাত্র লোকাল **ডেমো** লগইনের জন্য। প্রকৃত উৎপাদন ব্যবস্থায় এই ফিক্সড পাসওয়ার্ড ব্যবহার করবেন না। টেস্টের লগ `qa-results/`-এ দেখুন; লগ বা `qa/.auth/` কাউকে পাঠাবেন না।

**৪) Pilot UAT:** `python scripts/qa_pilot_gate.py --init` চালান। `qa-results/pilot/cases.csv`-এ প্রতিষ্ঠানের দায়িত্বপ্রাপ্ত Admin, Teacher, Accountant, Parent ইত্যাদি **বাস্তবে পরীক্ষা করে** PASS/FAIL, প্রমাণ, নাম ও তারিখ লিখবেন। অনুমোদনকারী `signoff.json` সম্পূর্ণ করবেন। শেষে `python scripts/qa_pilot_gate.py --check` চালান। অনুমোদন ছাড়া এটি `BLOCKED` দেখাবে—এটি স্বাভাবিক ও নিরাপদ।

**এখনকার অবস্থা:** টেস্ট স্ক্রিপ্ট প্রস্তুত, কিন্তু আপনার Windows স্টেজিং সার্ভারে লাইভ টেস্ট বা প্রকৃত UAT এখনো সম্পন্ন হয়নি। কোন ব্যর্থতার আউটপুট এলে সেই তথ্য অনুসারে কোড ঠিক করতে হবে।
