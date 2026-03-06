# Stack Reference

RailsFoundry is a minimal, production-ready Rails 8 foundation.
The stack favors clarity, durability, and minimal runtime dependencies.

---

## Core Stack

- **Rails 8** — Propshaft asset pipeline, import maps (no JS bundler)
- **PostgreSQL 16** — primary database
- **Tailwind CSS + DaisyUI** — utility-first CSS with component layer
- **Hotwire** — Turbo Drive/Frames/Streams + Stimulus controllers
- **Solid Queue** — DB-backed background jobs (no Redis required)
- **Kamal 2** — zero-downtime Docker deployment
- **Stripe** — subscription billing + webhooks

### Runtime Philosophy

- No JS bundler.
- No Redis required.
- Node is used only for asset compilation (build-time), not runtime.
- Production containers should not depend on Node.

---

## SaaS Foundations (Intentional Defaults)

- Rails 8 native authentication (no Devise)
- Account-scoped multitenancy
- Stripe subscriptions at the Account level
- `bin/ci` as canonical verification step

## Development Email Preview

- **Letter Opener Web** — all outgoing emails are intercepted in development and opened in a browser tab at `http://localhost:3000/letter_opener`
- No SMTP server required in development
- Configured in `config/environments/development.rb` with `delivery_method = :letter_opener_web`
- Route is mounted only in `Rails.env.development?` guard — not available in production

---

## Key Config Locations

| Concern | File |
|---|---|
| Database | `config/database.yml` |
| Routes | `config/routes.rb` |
| Background jobs | `config/queue.yml`, `config/recurring.yml` |
| Asset pipeline | `config/initializers/assets.rb` |
| Import maps | `config/importmap.rb` |
| Deployment | `config/deploy.yml` |
| Session store | `config/initializers/session_store.rb` |
| Content security | `config/initializers/content_security_policy.rb` |
| Tailwind source | `app/assets/tailwind/application.css` |
| JS entry point | `app/javascript/application.js` |
| Stimulus controllers | `app/javascript/controllers/` |
| CI entrypoint | `bin/ci` |

---

## APP_IDENTIFIER / APP_NAME

Every collision-sensitive identifier derives from:

- `APP_IDENTIFIER` — snake_case machine identifier (must be unique per app)
- `APP_NAME` — human display name

These are set in:

- `.env` (local)
- `.devcontainer/.env` (devcontainer)

### Uses `APP_IDENTIFIER`

| Concern | Location |
|---|---|
| Postgres database name | `config/database.yml` |
| Session cookie key | `config/initializers/session_store.rb` |
| Docker Compose project name | `.devcontainer/docker-compose.yml` |
| Kamal service / image name | `config/deploy.yml` |

Never hardcode app-specific identifiers.
