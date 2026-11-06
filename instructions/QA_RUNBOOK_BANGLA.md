# CampusSphere ERP — QA চালানোর বাংলা নির্দেশিকা

**আপনার বর্তমান `scm-system` ডাটাবেজ মুছে ফেলবেন না।** এটি Admin Login এবং Membership সহ কাজ করছে।

1. প্রথমে বর্তমান Laravel Project ও MariaDB Database-এর আলাদা **Backup** নিন।
2. আপলোড করা ZIP-এ `.env` ও `.git` আছে। এতে কনফিগারেশন ও সিক্রেট থাকতে পারে; কাউকে পাবলিকভাবে শেয়ার করবেন না।
3. বিদ্যমান ডাটাবেজে `SmsFullDemoSeeder` চালাবেন না—এটি খালি ডাটাবেজের জন্য। `SmsExtendedDemoSeeder`-এরও ৩টি demo institution ও আগের ছাত্র ডাটা দরকার, যা এই SQL dump-এ নেই।
4. phpMyAdmin-এ সঠিক `scm-system` Database সিলেক্ট করে **SQL** ট্যাবে `diagnostics/READ_ONLY_DATABASE_CHECKS.sql` ফাইলের SELECT Query গুলো চালান। এগুলো **কোনো Data পরিবর্তন করে না**।
5. Laravel Project-এর `artisan`-যুক্ত ফোল্ডারে CMD খুলুন এবং চালান:

```bash
php artisan config:clear
php artisan migrate:status
php artisan sms:qa --json
php artisan route:list
```

6. `php artisan test` কেবল আলাদা **Test Database**-এ চালান। `RefreshDatabase` থাকা test ভুল ডাটাবেজে চালালে ডাটা হারাতে পারেন।
7. Admin, Teacher, Accountant, Parent, Student ও restricted Campus user দিয়ে permission এবং access আলাদাভাবে পরীক্ষা করুন।
8. শিক্ষার্থী ভর্তি → ক্লাসে যুক্ত → হাজিরা → পরীক্ষা → ফি ইনভয়েস → পেমেন্ট → Ledger reconciliation—এই সম্পূর্ণ ফ্লো যাচাই করুন।

**বর্তমান ফলাফল:** Source code PHP Syntax Test পাস করেছে; কিন্তু Live MySQL/Browser/PHPUnit Test এখানে সম্পন্ন হয়নি। তাই পুরো ERP এখনই Production Ready ঘোষণা করা যাবে না।
