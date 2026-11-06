<?php

use App\Http\Controllers\DemoPaymentWebhookController;
use Illuminate\Support\Facades\Route;

// Stateless callback route: no web session or CSRF, but HMAC, timestamp,
// local-only feature gate, event-id uniqueness, and strict throttling.
Route::post('/webhooks/demo-payments',[DemoPaymentWebhookController::class,'receive'])
    ->middleware('throttle:30,1');
