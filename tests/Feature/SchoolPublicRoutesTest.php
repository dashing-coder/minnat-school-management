<?php
namespace Tests\Feature;

use Tests\TestCase;

class SchoolPublicRoutesTest extends TestCase
{
    public function test_public_school_pages_render_without_authentication(): void
    {
        foreach (['/school', '/school/about', '/school/academics', '/school/admissions', '/school/campus-life', '/school/contact'] as $url) {
            $this->get($url)->assertOk();
        }
    }
}
