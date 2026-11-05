# CampusSphere Laravel ERP — Sample Data ইনস্টলেশন (বাংলা)

আপনার Laravel ERP সাইট আগে থেকেই চালু আছে এবং `admin.school@example.test` দিয়ে লগইন করতে পারছেন। তাই **বিদ্যমান ডাটাবেজে SQL Import করবেন না**। নতুন **Additive Seeder** ব্যবহার করুন।

## আপনার চালু `scm-system` ডাটাবেজের জন্য

1. **প্রথমে phpMyAdmin থেকে `scm-system` ডাটাবেজের Backup (Export) নিন।** Laravel ফোল্ডারেরও Backup রাখুন।
2. ZIP থেকে `database/seeders/SmsExtendedDemoSeeder.php` ফাইলটি আপনার Laravel প্রজেক্টের `database/seeders/` ফোল্ডারে কপি করুন।
3. `.env` ফাইলে সাময়িকভাবে যোগ করুন:

```dotenv
APP_ENV=local
SMS_ALLOW_RICH_DEMO_SEED=true
```

4. Laravel-এর `artisan` ফাইল যে ফোল্ডারে আছে, সেখানে PowerShell খুলে চালান:

```powershell
php artisan config:clear
php artisan migrate:status
php artisan db:seed --class=SmsExtendedDemoSeeder
```

5. সফল হলে `.env` থেকে `SMS_ALLOW_RICH_DEMO_SEED=true` মুছে ফেলুন অথবা `false` করে দিন।
6. চালান: `php artisan sms:qa` এবং Dashboard, Student List, Attendance, Fee Invoice, Examination, Library, Hostel, Hifz ফিচারগুলো দেখুন।

**গুরুত্বপূর্ণ:** আগে থেকে থাকা Administrator email ও password **পরিবর্তন করা হয় না**। নতুন User account তৈরি হয় না; শিক্ষার্থীদের `user_id` থাকে `NULL` (অর্থাৎ ওয়েবসাইটে লগইনের জন্য আলাদা Student Account তৈরি হয় না)।

## নতুন খালি ডাটাবেজের জন্য

Laravel অ্যাপ ইনস্টল থাকা অবস্থায় প্রথমে `php artisan migrate`, পরে `SmsFullDemoSeeder`, সবশেষে `SmsExtendedDemoSeeder` চালান। দুটি Seeder চালাতে `.env`-এ তাদের আলাদা opt-in flag সক্রিয় করতে হয়; কাজ শেষে flag বন্ধ করুন।

## phpMyAdmin SQL Import কখন করবেন?

`database/sql/SMS_ERP_MYSQL8_FRESH_RICH_DEMO.sql` **শুধুমাত্র আলাদা নতুন, সম্পূর্ণ খালি ডাটাবেজে** Import করবেন। আপনার বর্তমানে চালু `scm-system` ডাটাবেজে Import করবেন না। তা করলে existing table conflict হবে। SQL Import-এর পরে Laravel migration history তৈরি হয় না, তাই একই ডাটাবেজে নতুন করে `php artisan migrate` চালাবেন না।

## নমুনা ডাটায় যা আছে

- ৩টি ডেমো প্রতিষ্ঠান: School, College, Madrasha।
- অতিরিক্ত ৭২ জন শিক্ষার্থী ও ৩৬ জন Guardian।
- ৩৬০টি অতিরিক্ত Student Attendance record।
- ৭২টি অতিরিক্ত Fee Invoice এবং ৪৮টি Payment।
- ১২০টি অতিরিক্ত balanced Ledger Journal (২৪০টি Journal Line)।
- Exam Marks, Results, Draft Payroll, Library, Hostel, Transport, Inventory, Donations, Scholarship, Hifz Progress।
- **মোট ১,৭২৩টি নতুন record**, আগের ৬০২টি মিলিয়ে **২,৩২৫টি fictional sample record**।

এই ডাটাগুলো শুধুমাত্র Testing / Development-এর জন্য। Laravel/MySQL-এ সরাসরি রান করে সম্পূর্ণ কার্যকারিতা যাচাই এখানে করা হয়নি।
