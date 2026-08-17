<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// This entry point lives in public/__shipping so the "shipping" subdomain can
// point its document root here while other subdomains use sibling folders under
// public/. The Laravel app root is two levels up.

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../../bootstrap/app.php';

$app->handleRequest(Request::capture());
