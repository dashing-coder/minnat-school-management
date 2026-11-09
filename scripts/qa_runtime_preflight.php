<?php
/**
 * CampusSphere QA: read-only effective Laravel configuration preflight.
 * NEVER migrates, seeds, truncates or modifies data. It refuses the working DB.
 * Usage: php scripts/qa_runtime_preflight.php [--mode=staging|testing]
 */
declare(strict_types=1);

$mode = 'staging';
foreach (array_slice($argv, 1) as $arg) {
    if (str_starts_with($arg, '--mode=')) {
        $mode = substr($arg, 7);
    }
}
if (! in_array($mode, ['staging', 'testing'], true)) {
    fwrite(STDERR, "Use --mode=staging or --mode=testing\n");
    exit(2);
}

$checks = [];
$check = static function (string $id, bool $ok, string $details) use (&$checks): void {
    $checks[] = ['check' => $id, 'status' => $ok ? 'PASS' : 'BLOCK', 'details' => $details];
};
$required = ['pdo_mysql', 'mbstring', 'dom', 'xml', 'fileinfo', 'openssl', 'ctype', 'tokenizer'];
foreach ($required as $extension) {
    $check('PHP_EXTENSION_' . strtoupper($extension), extension_loaded($extension),
        extension_loaded($extension) ? 'Available' : 'Missing PHP extension');
}
$autoload = dirname(__DIR__) . '/vendor/autoload.php';
$check('COMPOSER_DEPS', is_file($autoload), 'Composer vendor/autoload.php must exist');
if (is_file($autoload)) {
    try {
        require $autoload;
        $app = require dirname(__DIR__) . '/bootstrap/app.php';
        $app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();
        $connection = (string) config('database.default');
        $settings = (array) config('database.connections.' . $connection, []);
        $name = (string) ($settings['database'] ?? '');
        $host = (string) ($settings['host'] ?? '');
        $effectiveEnv = (string) app()->environment();
        $check('LARAVEL_BOOT', true, 'Laravel bootstrap completed');
        $check('DB_DRIVER', $connection === 'mysql', 'Expected MySQL/MariaDB driver; actual: ' . $connection);
        $safeName = $mode === 'testing'
            ? (bool) preg_match('/(?:^|[_-])(?:test|testing|ci)(?:$|[_-])/i', $name)
            : (bool) preg_match('/(?:^|[_-])(?:staging|stage|qa)(?:$|[_-])/i', $name);
        $check('DB_NAME_IS_ISOLATED', $safeName && ! in_array(strtolower($name),
            ['scm-system', 'production', 'campussphere_local'], true),
            'Configured DB name: ' . ($name ?: '[empty]') . '; staging/test-only name required');
        $check('DB_HOST_LOCAL', in_array($host, ['127.0.0.1', 'localhost', '::1'], true),
            'Configured host: ' . ($host ?: '[empty]') . '; local QA only');
        $check('NON_PRODUCTION_APP', $effectiveEnv !== 'production', 'Effective APP_ENV: ' . $effectiveEnv);
        $check('APP_KEY_PRESENT', is_string(config('app.key')) && strlen((string) config('app.key')) > 20,
            'Application key present (value redacted)');
    } catch (\Throwable $e) {
        $check('LARAVEL_BOOT', false, 'Unable to bootstrap Laravel; check PHP extensions, Composer, environment and config');
    }
} else {
    $check('LARAVEL_BOOT', false, 'Install dependencies with composer install');
}
$blocked = count(array_filter($checks, static fn (array $row): bool => $row['status'] === 'BLOCK'));
$report = ['gate' => 'LARAVEL_RUNTIME_' . strtoupper($mode), 'status' => $blocked ? 'BLOCKED' : 'READY_TO_TEST',
    'read_only' => true, 'blockers' => $blocked, 'checks' => $checks];
echo json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL;
exit($blocked ? 1 : 0);
