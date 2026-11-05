<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
final class AuthController {
    public function show() { if(Auth::check()) return redirect()->route('institution.choose'); return view('auth.login'); }
    public function login(Request $request) {
        $credentials=$request->validate(['email'=>['required','email'],'password'=>['required','string']]);
        $key=Str::lower($credentials['email']).'|'.$request->ip();
        if (RateLimiter::tooManyAttempts($key,5)) {
            throw ValidationException::withMessages(['email'=>'Too many attempts. Please retry shortly.']);
        }
        if (!Auth::attempt($credentials)) {
            RateLimiter::hit($key,60);
            throw ValidationException::withMessages(['email'=>'These credentials do not match our records.']);
        }
        RateLimiter::clear($key); $request->session()->regenerate();
        return redirect()->route('institution.choose');
    }
    public function logout(Request $request) {
        Auth::logout(); $request->session()->invalidate(); $request->session()->regenerateToken();
        return redirect()->route('login');
    }
}
