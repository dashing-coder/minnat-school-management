<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Support\ModuleCatalog;
use PHPUnit\Framework\TestCase;

final class ModuleCatalogTest extends TestCase
{
    public function test_all_twenty_modules_are_mapped_to_unique_registers(): void
    {
        $modules = ModuleCatalog::all();
        self::assertCount(20, $modules);
        $all = [];
        foreach ($modules as $key => $module) {
            self::assertNotEmpty($module['permission'], $key);
            self::assertNotEmpty($module['tables'], $key);
            foreach ($module['tables'] as $table) {
                self::assertMatchesRegularExpression('/^[a-z_]+$/', $table);
                self::assertNotContains($table, $all, 'Duplicate module table: '.$table);
                $all[] = $table;
            }
        }
        self::assertCount(111, $all);
    }
}
