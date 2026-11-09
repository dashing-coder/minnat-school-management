<?php
namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use RuntimeException;

abstract class TestCase extends BaseTestCase
{
    /**
     * Ensure RefreshDatabase never truncates the developer's working ERP DB.
     * CI uses campussphere_ci; local QA must use a separate *_test database.
     */
    public function createApplication()
    {
        $app = parent::createApplication();
        $connection = (string) $app['config']->get('database.default');
        $database = (string) $app['config']->get("database.connections.{$connection}.database", '');
        $safeSqlite = $connection === 'sqlite' && $database === ':memory:';
        $safeNamed = (bool) preg_match('/(?:^|[_-])(?:test|testing|ci)(?:$|[_-])/i', $database);
        if (!$safeSqlite && !$safeNamed) {
            throw new RuntimeException(
                'REFUSING TO RUN TESTS: database '.$database.' is not an isolated testing database. '.
                'Create campussphere_test (or *_ci), set DB_DATABASE in .env.testing, '.
                'and clear Laravel configuration cache. Never run RefreshDatabase on scm-system.'
            );
        }
        return $app;
    }
}
