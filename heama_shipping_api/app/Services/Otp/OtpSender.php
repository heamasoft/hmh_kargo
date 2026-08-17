<?php

namespace App\Services\Otp;

interface OtpSender
{
    /**
     * Deliver the given code to the recipient (phone or email).
     *
     * @throws \RuntimeException on delivery failure
     */
    public function send(string $recipient, string $code): void;
}
