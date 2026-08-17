# Heama API — Deploy to Hostinger (shipping.heama-soft.com)

Target: Hostinger **shared/cloud (cPanel)**, subdomain **shipping.heama-soft.com**,
MySQL **u562289011_shipping**. Laravel 13 → requires **PHP 8.3**.

> ⚠️ The DB password was shared during setup — **rotate it in hPanel → Databases**
> and update `.env` accordingly.

---

## 1. Set PHP to 8.3
hPanel → **Advanced → PHP Configuration** → select **PHP 8.3**.
Enable extensions: `pdo_mysql`, `mbstring`, `openssl`, `curl`, `fileinfo`, `intl`, `zip`.

## 2. Confirm the MySQL database
Already created: DB `u562289011_shipping`, user `u562289011_shipping`.
On shared hosting `DB_HOST=127.0.0.1` (localhost) is correct.

## 3. Upload the project — app OUTSIDE the web root
Put the Laravel app in your home dir, **not** inside `public_html`:

```
/home/u562289011/heama_api/          ← whole Laravel project goes here
/home/u562289011/public_html/__shipping/   ← subdomain doc root (see step 4)
```

Upload options:
- **Git (Business/Cloud w/ SSH):** `cd ~ && git clone <repo> heama_api`
- **Zip via File Manager:** zip the project (see "Packaging" below), upload to
  `~/heama_api`, extract.

If you have **SSH**, install dependencies on the server:
```bash
cd ~/heama_api
composer install --no-dev --optimize-autoloader
```
No SSH? Then include the `vendor/` folder in your upload zip.

## 4. Point the subdomain at the `public/__shipping` entry
The app ships with a bootstrap at `heama_shipping_api/public/__shipping/` so the
`shipping` subdomain can live alongside other subdomains as sibling folders under
`public/`.

hPanel → **Domains → Subdomains → shipping** → set **Document Root** to:
```
<path>/heama_shipping_api/public/__shipping
```
(e.g. `public_html/__shipping/heama_shipping_api/public/__shipping` if you
extracted the zip inside `public_html/__shipping`).

Other subdomains you add later go in their own folders under
`heama_shipping_api/public/` (e.g. `public/__other`).

## 5. The .env is already set up
The zip includes a ready **`.env`** (production, with the DB password filled in),
so there's **nothing to rename or edit** to get it running.

Later, when you're ready, update on the server:
- `MAIL_MAILER=smtp` + `MAIL_PASSWORD` — to send real OTP emails (currently `log`)
- `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID` — from Meta (see WHATSAPP.md)
- `OTP_DEMO_CODE=` (empty) — **remove the `1234` demo bypass once WhatsApp works**
- `DB_PASSWORD` — if/when you rotate it

## 6. Create the tables

### No SSH? Import the SQL dump (recommended for shared hosting)
Use the provided **`heama_shipping_import.sql`**:
1. hPanel → **Databases → phpMyAdmin** → open database **u562289011_shipping**.
2. **Import** tab → choose `heama_shipping_import.sql` → **Go**.
3. This creates all 22 tables + seed data (9 stores, settings, FX rates, admin).
   No artisan needed — the app runs straight away.

### Have SSH? Run migrations instead
```bash
cd ~/heama_api
php artisan migrate --force
php artisan db:seed --force        # stores, settings, FX, admin
php artisan config:cache
php artisan route:cache
```

> Seeded admin (for the future Filament dashboard): `admin@heama-soft.com` /
> `ChangeMe123!` — change it once the admin panel is live.

## 7. Permissions
```bash
chmod -R 775 storage bootstrap/cache
```

## 8. Cron (scheduler / queued OTP sends)
hPanel → **Advanced → Cron Jobs**, every minute:
```
php /home/u562289011/heama_api/artisan schedule:run >> /dev/null 2>&1
```

## 9. Smoke test
```
https://shipping.heama-soft.com/api/v1/health   → {"ok":true,"app":"heama"}
https://shipping.heama-soft.com/api/v1/stores    → list of 9 stores
```

---

## Packaging a zip to upload (no Git)
From your PC, zip everything **except** `node_modules`, `.git`, and (if you have
server SSH) `vendor`. Keep `.env.production` out of any public repo, but you DO
need it on the server as `.env`.

## Flutter app base URL (Phase 4)
```
https://shipping.heama-soft.com/api/v1
```
