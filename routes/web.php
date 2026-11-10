<?php
use App\Http\Controllers\{AuthController,InstitutionController,DashboardController,ModulesController,StudentController,AttendanceController,PortalController,RegisterEditorController,WorkflowController,CertificateVerifyController,ReportsController,UsersController};
use Illuminate\Support\Facades\Route;
Route::view('/','welcome')->name('home');
Route::get('/verify/certificate/{token}',[CertificateVerifyController::class,'show'])->where('token','[a-zA-Z0-9]{48}')->middleware('throttle:20,1')->name('certificate.verify');
Route::get('/login',[AuthController::class,'show'])->name('login');
Route::post('/login',[AuthController::class,'login'])->name('login.submit');
Route::middleware('auth')->group(function() {
    Route::post('/logout',[AuthController::class,'logout'])->name('logout');
    Route::get('/choose-institution',[InstitutionController::class,'choose'])->name('institution.choose');
    Route::post('/choose-institution',[InstitutionController::class,'select'])->name('institution.select');
    Route::middleware('sms.institution')->group(function() {
        Route::get('/dashboard',[DashboardController::class,'index'])->name('dashboard');
        Route::post('/integrations/demo-payment-intents',[\App\Http\Controllers\DemoPaymentIntentController::class,'store'])
            ->middleware('throttle:10,1')->name('demo.payment.intent');
        Route::get('/my-portal',[PortalController::class,'index'])->name('portal');
        Route::get('/students',[StudentController::class,'index'])->name('students.index');
        Route::get('/students/create',[StudentController::class,'create'])->name('students.create');
        Route::post('/students',[StudentController::class,'store'])->name('students.store');
        Route::get('/students/{id}/edit',[StudentController::class,'edit'])->whereNumber('id')->name('students.edit');
        Route::put('/students/{id}',[StudentController::class,'update'])->whereNumber('id')->name('students.update');
        Route::get('/attendance/mark',[AttendanceController::class,'create'])->name('attendance.mark');
        Route::post('/attendance/mark',[AttendanceController::class,'store'])->name('attendance.store');
        Route::get('/security/users',[UsersController::class,'index'])->name('users.index');
        Route::post('/security/users',[UsersController::class,'store'])->name('users.store');
        Route::put('/security/users/{membershipId}',[UsersController::class,'assign'])->whereNumber('membershipId')->name('users.assign');
        Route::get('/reports/{report}',[ReportsController::class,'show'])->name('report.show');
        Route::get('/reports/{report}/csv',[ReportsController::class,'export'])->name('report.export');
        Route::get('/operations/{flow}',[WorkflowController::class,'show'])->name('workflow.show');
        Route::post('/operations/{flow}',[WorkflowController::class,'store'])->name('workflow.store');
        Route::get('/register/{slug}/{table}/create',[RegisterEditorController::class,'create'])->name('register.create');
        Route::post('/register/{slug}/{table}',[RegisterEditorController::class,'store'])->name('register.store');
        Route::get('/register/{slug}/{table}/{id}/edit',[RegisterEditorController::class,'edit'])->whereNumber('id')->name('register.edit');
        Route::put('/register/{slug}/{table}/{id}',[RegisterEditorController::class,'update'])->whereNumber('id')->name('register.update');
        Route::get('/modules/{slug}',[ModulesController::class,'home'])->name('module.home');
        Route::get('/modules/{slug}/{table}',[ModulesController::class,'records'])->name('module.records');
        Route::get('/modules/{slug}/{table}/export',[ModulesController::class,'export'])->name('module.export');
    });
});

// Public School Site — safe additive routes
require __DIR__.'/school_site.php';
