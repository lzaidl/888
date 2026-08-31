# وصل — Chat & Dating V1.0

Flutter + Supabase application for Web, Android and iOS.

## GitHub Pages deployment

1. Create a GitHub repository, e.g. `888`.
2. Upload all files from this project to the repository (do not upload the ZIP itself).
3. In **Settings → Secrets and variables → Actions**, add:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
4. In **Settings → Pages**, set **Source** to **GitHub Actions**.
5. Push to `main`. The workflow builds Flutter Web and publishes it automatically.

For a repository named `888`, the site will be:
`https://YOUR-USERNAME.github.io/888/`

## Supabase

Run:
- `supabase/schema.sql`
- `supabase/live_match.sql`

## Local run

```bash
flutter create .
flutter pub get
# create .env from .env.example
flutter run
```

For Web:
```bash
flutter build web --release
```

## V1 features

- Account registration/login
- Gender and country profile fields
- Discover/search by gender and country
- Likes and mutual matches
- Private realtime chat foundation
- Live search/matching foundation
- Blocking/reporting foundation
- Light/Dark/System theme
- Supabase database, RLS and Realtime

Production additions still recommended before store release: avatar storage policies, push notifications, moderation/admin dashboard, password reset/email verification, anti-spam/rate limits, pagination, presence heartbeat, privacy/terms pages, and App Store/Play Store configuration.
