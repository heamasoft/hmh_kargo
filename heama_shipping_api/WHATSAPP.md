# WhatsApp OTP setup (Meta Cloud API)

Heama sends login codes via WhatsApp using an **authentication** message template.

## One-time setup
1. Create a **Meta Business** account → https://business.facebook.com
2. In **Meta for Developers** (developers.facebook.com) create an app of type
   **Business**, add the **WhatsApp** product.
3. Note the **Phone number ID** (test number to start, or add your own number).
4. Create a **permanent access token** (System User token with `whatsapp_business_messaging`).
5. Create an **authentication template** named exactly `heama_otp`:
   - Category: **Authentication**
   - Body: `Your Heama code is {{1}}` (Meta fills the code + copy button)
   - Language: `en` (add `ar` / `ku` later if desired)
   - Submit for approval (usually minutes for auth templates).

## Fill the server .env
```
WHATSAPP_TOKEN=EAAG...          # permanent token
WHATSAPP_PHONE_NUMBER_ID=1234567890
WHATSAPP_OTP_TEMPLATE=heama_otp
WHATSAPP_OTP_LANG=en
WHATSAPP_API_VERSION=v21.0
```

## Notes
- Recipients must be in **international format, digits only** (e.g. `9647501234567`).
  The app normalizes local `0750...` numbers — confirm the country-code handling
  matches how you store phones (Iraq = +964).
- Until the token/phone ID are set, the API **logs** the code instead of sending
  (see `storage/logs/laravel.log`) so development still works.
- Template message costs apply per Meta's pricing; auth templates are cheap.
