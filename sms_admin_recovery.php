<?php
/**
 * CampusSphere demo account recovery — LOCAL DEV ONLY.
 * Execute using `php sms_admin_recovery.php --diagnose` or `--reset`.
 * Place beside artisan; remove immediately after use.
 */
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

$here = __DIR__;
if (!is_file($here . '/artisan') || !is_file($here . '/vendor/autoload.php')) {
    fwrite(STDERR, "Place this file beside Laravel's artisan file and run composer install first.\n");
    exit(1);
}

require $here . '/vendor/autoload.php';
$app = require $here . '/bootstrap/app.php';
$kernel = $app->make(\Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

if (! $app->environment(['local', 'testing'])) {
    fwrite(STDERR, "Stopped: this recovery tool only runs in local/testing environment.\n");
    exit(2);
}

$args = $_SERVER['argv'] ?? [];
$reset = in_array('--reset', $args, true);
if (! $reset && ! in_array('--diagnose', $args, true)) {
    echo "Usage: php sms_admin_recovery.php --diagnose OR --reset\n";
    exit(1);
}

$email = 'admin.school@example.test';
try {
    $connection = \Illuminate\Support\Facades\DB::connection();
    $database = $connection->getDatabaseName();
    $driver = $connection->getDriverName();
    $host = config('database.connections.' . config('database.default') . '.host') ?: '(not set)';
    $guard = (string) config('auth.defaults.guard');
    echo "CampusSphere Authentication Diagnostic\n";
    echo "App env: " . $app->environment() . "\n";
    echo "App URL: " . config('app.url') . "\n";
    echo "Database connection: " . config('database.default') . " ($driver)\n";
    echo "Database host: $host\n";
    echo "Database name: $database\n";
    echo "Default auth guard: $guard\n";

    $user = \App\Models\User::query()->where('email', $email)->first();
    if (! $user) {
        fwrite(STDERR, "ERROR: $email does not exist in the connected database.\n");
        fwrite(STDERR, "Import/seed the account in THIS database, or correct DB_DATABASE in .env.\n");
        exit(3);
    }
    echo "User found: ID=" . $user->getKey() . ", email=" . $user->email . "\n";
    echo "Password storage: " . (password_get_info((string) $user->password)['algoName'] ?? 'unknown') . "\n";

    if (! $reset) {
        echo "No changes made. Use --reset to generate and save a new password.\n";
        exit(0);
    }

    $password = \Illuminate\Support\Str::random(28);
    $user->forceFill([
        'password' => \Illuminate\Support\Facades\Hash::make($password),
        'remember_token' => null,
    ])->save();
    $user->refresh();

    $hashOk = \Illuminate\Support\Facades\Hash::check($password, (string) $user->password);
    $credentials = ['email' => $email, 'password' => $password];
    $webOk = (bool) \Illuminate\Support\Facades\Auth::guard('web')->validate($credentials);
    $defaultOk = (bool) \Illuminate\Support\Facades\Auth::guard($guard)->validate($credentials);

    echo "Hash::check: " . ($hashOk ? 'PASS' : 'FAIL') . "\n";
    echo "Web guard credentials validation: " . ($webOk ? 'PASS' : 'FAIL') . "\n";
    echo "Default guard credentials validation: " . ($defaultOk ? 'PASS' : 'FAIL') . "\n";

    if (! $hashOk || ! $webOk || ! $defaultOk) {
        fwrite(STDERR, "Authentication mismatch detected. Check config/auth.php and provider configuration.\n");
        exit(4);
    }

    echo "SUCCESS — account reset verified in this Laravel environment.\n";
    echo "EMAIL: $email\n";
    echo "NEW PASSWORD (SAVE ONCE): $password\n";
    echo "Next: restart the SAME Laravel server, visit /login in a private browser window.\n";
    echo "Delete sms_admin_recovery.php as soon as login works.\n";
    exit(0);
} catch (\Throwable $error) {
    fwrite(STDERR, "ERROR: " . $error->getMessage() . "\n");
    exit(5);
}
