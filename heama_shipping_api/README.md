# Heama API

Laravel 13 backend for the Heama shop-and-ship app. Customers browse foreign
storefronts in-app, capture products into a Heama cart, and order in IQD; the
admin fulfils the orders.

- **Auth:** OTP over WhatsApp (Meta Cloud API) or email (SMTP) → Sanctum tokens
- **Pricing:** captured foreign price → IQD (FX rate × markup) + shipping + fee
- **Payments (MVP):** Heama Wallet only (admin-credited ledger)
- **Hosting:** Hostinger cPanel + MySQL, PHP 8.3 — see [DEPLOYMENT.md](DEPLOYMENT.md)

## Local dev
Requires PHP 8.3 + Composer. Uses SQLite locally.
```bash
composer install
cp .env.example .env      # then set OTP_DEMO_CODE=1234 for local
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

## API (v1) — base `/api/v1`
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET  | `/health` | – | health check |
| GET  | `/stores` | – | active storefronts |
| POST | `/auth/otp/request` | – | send OTP (`identifier`, `channel`=whatsapp\|email) |
| POST | `/auth/otp/verify`  | – | verify code → `{token, user}` (creates user+wallet+cart) |
| POST | `/auth/login` | – | optional password login (phone + password) |
| POST | `/auth/password` | token | set/change the account password |
| GET  | `/auth/me` | token | current user + wallet balance |
| PATCH| `/auth/profile` | token | update name/city/email |
| POST | `/auth/logout` | token | revoke current token |
| POST | `/capture` | token | price a scraped product in IQD (preview) |
| GET  | `/cart` | token | cart items + totals breakdown |
| POST | `/cart/items` | token | add a captured item to the cart |
| PATCH| `/cart/items/{id}` | token | change qty / variant |
| DELETE | `/cart/items/{id}` | token | remove a cart item |
| GET  | `/orders` | token | list the user's orders |
| POST | `/orders` | token | place order from cart, debit wallet |
| GET  | `/orders/{code}` | token | order detail + tracking events |
| GET  | `/wallet` | token | balance + transaction ledger |

**Coming next (step ③):** Filament admin (orders queue, status/tracking, wallet top-ups, settings).

## Structure
```
app/Models/            Eloquent models (User, Store, Cart, Order, Wallet, ...)
app/Services/Otp/      OtpService + WhatsApp/Email senders
app/Services/PricingService.php   FX + markup -> IQD
app/Http/Controllers/Api/         AuthController, StoreController
database/migrations/   full schema
database/seeders/      stores, settings, FX rates, admin
routes/api.php         API routes
```

## Setup guides
- [DEPLOYMENT.md](DEPLOYMENT.md) — Hostinger cPanel deploy
- [WHATSAPP.md](WHATSAPP.md) — Meta WhatsApp Cloud API + OTP template
