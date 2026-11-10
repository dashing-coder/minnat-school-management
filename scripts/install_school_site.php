<?php
/**
 * CampusSphere school-site installer — only registers /school public routes.
 * Run from the LARAVEL PROJECT ROOT: php scripts/install_school_site.php --install
 * This installer never modifies the database, .env, passwords, or ERP routes.
 */
if (PHP_SAPI !== 'cli') { http_response_code(403); exit("CLI only.\n"); }
$root = dirname(__DIR__);
$required = [
    'artisan', 'bootstrap/app.php', 'routes/web.php', 'routes/school_site.php',
    'resources/views/school/home.blade.php',
    'resources/views/school/about.blade.php',
    'resources/views/school/academics.blade.php',
    'resources/views/school/admissions.blade.php',
    'resources/views/school/campus_life.blade.php',
    'resources/views/school/contact.blade.php',
    'public/school-site/assets/styles.css',
    'public/school-site/assets/site.js',
];
$missing = [];
foreach ($required as $file) { if (!is_file($root . DIRECTORY_SEPARATOR . $file)) { $missing[] = $file; } }
if ($missing) {
    fwrite(STDERR, "ERROR: File(s) missing from Laravel project root:\n  - " . implode("\n  - ", $missing) . "\n\n");
    fwrite(STDERR, "Extract the fix ZIP into the directory that contains artisan, not into public/ or public_html/.\n");
    exit(2);
}
$web = $root . '/routes/web.php';
$routes = (string) file_get_contents($web);
// Match both `require __DIR__.'/school_site.php';` and spacing variants.
$registered = (bool) preg_match('~\\brequire(?:_once)?\\s*\\(?\\s*__DIR__\\s*\\.\\s*[\'\"]\\/school_site\\.php[\'\"]\\s*\\)?\\s*;~', $routes);
$mode = $argv[1] ?? '--status';
if ($mode === '--status') {
    echo "Laravel root: {$root}\n";
    echo 'School route include: ' . ($registered ? 'PRESENT' : 'MISSING') . "\n";
    echo "Files: OK\n";
    echo $registered ? "Next: php artisan route:list --path=school\n" : "Next: php scripts/install_school_site.php --install\n";
    exit($registered ? 0 : 1);
}
if ($mode !== '--install') {
    fwrite(STDERR, "Usage: php scripts/install_school_site.php --install|--status\n");
    exit(2);
}
if (!$registered) {
    if (!is_writable($web)) { fwrite(STDERR, "ERROR: routes/web.php is not writable.\n"); exit(3); }
    $backupDir = $root . '/storage/app/school-site-install-backups';
    if (!is_dir($backupDir) && !mkdir($backupDir, 0700, true) && !is_dir($backupDir)) {
        fwrite(STDERR, "ERROR: Cannot create safe route backup folder.\n"); exit(3);
    }
    $backup = $backupDir . '/web.php.' . gmdate('Ymd_His') . '.' . bin2hex(random_bytes(3)) . '.bak';
    if (!copy($web, $backup)) { fwrite(STDERR, "ERROR: Cannot back up routes/web.php; no changes made.\n"); exit(3); }
    $addition = "\n// Public School Site — safe additive routes\nrequire __DIR__.'/school_site.php';\n";
    if (file_put_contents($web, $addition, FILE_APPEND | LOCK_EX) === false) {
        fwrite(STDERR, "ERROR: Could not append route include. Original backed up to: {$backup}\n"); exit(3);
    }
    echo "School route registration added.\nBackup: {$backup}\n";
} else {
    echo "School route registration already present. Nothing duplicated.\n";
}
$artisan = $root . '/artisan';
$cmds = ['route:clear', 'view:clear'];
$canExecute = function_exists('passthru') && !str_contains((string) ini_get('disable_functions'), 'passthru');
if ($canExecute) {
    foreach ($cmds as $command) {
        $cmd = escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg($artisan) . ' ' . $command;
        echo "> php artisan {$command}\n";
        $status = 0;
        passthru($cmd, $status);
        if ($status !== 0) { echo "WARNING: {$command} failed (exit {$status}); run it manually on the host.\n"; }
    }
} else {
    echo "Run manually: php artisan route:clear && php artisan view:clear\n";
}
echo "\nVerification:\n";
echo "  php artisan route:list --path=school\n";
echo "  https://scm.intrigueit.co/school\n";
echo "  https://scm.intrigueit.co/school-site/assets/styles.css\n";
echo "If the route is listed but the URL still returns 404, confirm you installed this into the Laravel project actually served by this domain.\n";
