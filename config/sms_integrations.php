<?php

return [
    // Only the locally simulated payment provider is included. Real provider
    // integrations need separately verified official API credentials & specs.
    'demo_webhook_secret' => env('SMS_DEMO_WEBHOOK_SECRET',''),
    'demo_provider_enabled' => env('SMS_DEMO_PROVIDER_ENABLED',false),
];
