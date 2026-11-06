<?php

declare(strict_types=1);

namespace Tests\Feature\Sms;

use Tests\TestCase;

final class ApiSessionSmokeTest extends TestCase
{
    public function test_guest_cannot_read_same_origin_api(): void
    {
        $this->getJson('/api/v1/institutions/any-school/context')->assertUnauthorized();
    }

    public function test_get_only_api_does_not_expose_unprotected_mutating_routes(): void
    {
        $this->postJson('/api/v1/institutions/any-school/campuses',[])
            ->assertStatus(405);
    }
}
