<?php
// Public-facing sample school pages. No authentication, database writes or ERP routes are changed.
// Include at the END of your existing routes/web.php: require __DIR__.'/school_site.php';
use Illuminate\Support\Facades\Route;
Route::view('/school', 'school.home')->name('school.home');
Route::view('/school/about', 'school.about')->name('school.about');
Route::view('/school/academics', 'school.academics')->name('school.academics');
Route::view('/school/admissions', 'school.admissions')->name('school.admissions');
Route::view('/school/campus-life', 'school.campus_life')->name('school.campus_life');
Route::view('/school/contact', 'school.contact')->name('school.contact');
