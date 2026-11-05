<?php

declare(strict_types=1);

namespace Tests\Feature;

use Tests\TestCase;

final class GuestRouteSecurityTest extends TestCase
{
    public function test_all_protected_entrypoints_redirect_guests_to_login(): void
    {
        foreach (['/dashboard', '/students', '/students/create', '/attendance/mark',
                  '/my-portal', '/modules/finance', '/modules/students/students',
                  '/operations/fee-payment', '/operations/student-enrollment',
                  '/register/finance/fee_heads/create', '/security/users', '/reports/trial-balance'] as $path) {
            $this->get($path)->assertRedirect('/login');
        }
    }
}
