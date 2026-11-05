<?php

declare(strict_types=1);

namespace App\Support\Sms;

use LogicException;

final class InstitutionContext
{
    private ?int $institutionId = null;
    private ?int $membershipId = null;
    private ?int $userId = null;
    private bool $allCampuses = false;

    public function set(int $institutionId, int $membershipId, int $userId, bool $allCampuses): void
    {
        $this->institutionId = $institutionId;
        $this->membershipId = $membershipId;
        $this->userId = $userId;
        $this->allCampuses = $allCampuses;
    }

    public function institutionId(): int
    {
        return $this->institutionId ?? throw new LogicException('Institution context has not been resolved.');
    }

    public function membershipId(): int
    {
        return $this->membershipId ?? throw new LogicException('Membership context has not been resolved.');
    }

    public function userId(): int
    {
        return $this->userId ?? throw new LogicException('User context has not been resolved.');
    }

    public function allCampuses(): bool
    {
        return $this->allCampuses;
    }
}
