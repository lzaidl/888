# V1.0 Feature Map

## Core
- Auth
- Profile
- Gender/country filters
- Discover
- Live matching
- Private chat
- Theme

## Security
RLS is enabled. Users can only modify their own profile, likes, blocks and search sessions; messages require conversation membership.

## Next production hardening
1. Email verification flow.
2. Password reset.
3. Storage bucket `avatars` with RLS.
4. Push notifications via FCM/APNs.
5. Admin dashboard and moderation queue.
6. Age/identity safety controls.
7. Rate limiting / anti-spam.
8. Pagination for users and messages.
9. Presence heartbeat instead of a simple boolean.
10. Server-side live matcher with stricter symmetric filter validation.
11. Content moderation.
12. App Store / Play Store privacy and terms pages.
