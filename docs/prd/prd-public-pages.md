# PRD: Public Pages (Home, About, Services & Portfolio)

<!-- review_prd summary
Reviewed: 2026-03-09
Status: READY

Fixes applied (initial review):
- Added [UI story] bullets to PP-001, PP-002, PP-003 (component stories)
- Removed navigation update from PP-004 (belongs in PP-008, was a duplicate concern)
- Rewrote compound criteria into single-concern bullets
- Classified all Open Questions as blocking or non-blocking with defaults
- Added inline review comments for non-blocking questions

Fixes applied (second pass — copy integration):
- Resolved OQ-1 (BLOCKING): Incorporated real project descriptions, tags from provided copy
- Resolved OQ-3 (BLOCKING): YouTube channel is @jeremywarddev (single channel)
- Renamed "Projects" to "Services & Portfolio" to match provided copy structure
- Added Services section to PP-005 (consulting availability + capabilities)
- Updated About page copy with provided bio content
- Updated social links to match provided copy (X, LinkedIn, YouTube — no GitHub in social links per copy)
- Expanded project list from 4 to 6 based on provided copy (CoverText/ClientCompass, WorkhorseOps, RailsFoundry, Workhorse Compliance, RFP/Grant Ecosystem)
- Updated all story references from "Projects" to "Services & Portfolio"
- All previously blocking questions resolved — status changed to READY
-->

## Introduction

JeremyWardDev is a developer brand hub — part build-in-public blog, part project
showcase, part Mission Control dashboard (behind auth). The public-facing site
needs polished Home, About, and Services & Portfolio pages that establish the brand,
showcase curated projects, and link to social profiles. These pages use static
content (no database models) with reusable ViewComponent patterns that set the
standard for future development.

## Goals

- Establish a professional, authentic developer brand presence
- Showcase curated projects with descriptions and tech stacks
- Provide an About page with authentic bio and social links
- Create reusable ViewComponents (Hero, ProjectCard, SocialLinks) that follow
  existing codebase patterns and serve as reference implementations
- Replace the placeholder home page with a branded landing page
- Keep all content static (YAML/view-level) — no database models needed

## Content Reference

The following copy has been provided by the user and should be used as the
source of truth for page content. Implementing agents should use this copy
directly (adapting for i18n as needed) rather than inventing placeholder text.

### About Page Copy

> I'm Jeremy Ward — a Rails developer with 20 years of experience building real software for real businesses.
>
> I'm not here to sell you courses or teach you the fundamentals. I'm here to build profitable SaaS products that generate revenue and fund the life I want to live.
>
> **What makes me different:** Most developer content creators are teaching. I'm shipping. CoverText, ClientCompass, WorkhorseOps, RailsFoundry — these aren't side projects or demos. They're actual businesses solving real problems for paying customers.
>
> I build in public because it creates accountability, proves the tools work, and helps other solo founders see what's possible when you combine deep Rails experience with modern AI tooling.
>
> **My background:** B.S. in Athletic Training and Strength & Conditioning. Built Fitrme back in 2012 (Rails + Ionic native apps for customized workout guidance). Spent years in the trenches shipping production Rails apps. Now building a portfolio of software products to replace W2 income.
>
> **The philosophy:** Build products that fund the life you want to live. For me, that's time on the golf course (I coach high school golf), archery elk hunting in the backcountry, and outdoor adventure. Your version might look different — but the principle is the same.
>
> I'm not chasing unicorn exits or VC funding. I'm building sustainable, profitable software businesses that run with minimal overhead so I can spend time doing what I love.
>
> **What you'll find here:** Weekly updates on what I'm building. Technical deep dives into architecture decisions. Revenue transparency. Real problems and real solutions. No fluff, no hype — just honest documentation of building a software portfolio as a solo founder.

### Services & Portfolio Page Copy

**Services intro:**

> I'm not actively looking for client work — I'm focused on building my own product portfolio. That said, I'm open to interesting projects that align with my expertise and philosophy.
>
> **What I'm good at:**
> - Ruby on Rails development (20 years, Rails 8 + Hotwire + Tailwind)
> - SaaS architecture and multi-tenant systems
> - AI-native development (building with Claude Code, Cursor, coding agents)
> - Solo founder technical strategy (build fast, ship lean, monetize early)
>
> **If you need help:** Reach out. I'm selective, but if your project is interesting and the fit is right, let's talk.

**Project data (for project cards):**

| Project | Description | Tags |
|---|---|---|
| CoverText / ClientCompass | Insurance agency communication platform. SMS workflows, compliance tracking, client management. Rebuilt on RailsFoundry. | Rails 8, Hotwire, Stripe, SMS |
| WorkhorseOps | Trailer rental management SaaS. Born from running a real trailer rental business. Built for operators who need simplicity and reliability. | Rails 8, Multi-tenant, Stripe |
| RailsFoundry | Rails 8 SaaS starter kit. The actual foundation used to ship real products. Multi-tenant architecture, Stripe billing, Kamal deployment, AI-native workflows. | Rails 8, Kamal, DaisyUI, AI |
| Workhorse Compliance | Subcontractor insurance and compliance tracking for general contractors. Solves a painful, expensive problem in construction project management. | Rails 8, Compliance, B2B |
| RFP/Grant Ecosystem | RFPNotify, GrantScribe, GrantKit. Underserved markets with clear monetization paths and real customer pain. | Rails 8, AI, Document Processing |

**Philosophy blurb (bottom of portfolio page):**

> I build tools that work for solo founders, not against them. Minimal dependencies. "The Rails Way." AI-leveraged but not over-engineered.
>
> Every product I build is designed to generate recurring revenue with minimal ongoing maintenance. The goal isn't to work harder — it's to build leverage so I can work less and live more.

### Social Links Data

| Platform | Label | URL |
|---|---|---|
| X | @jeremywarddev | https://x.com/jeremywarddev |
| LinkedIn | in/jrmyward | https://linkedin.com/in/jrmyward |
| YouTube | @jeremywarddev | https://youtube.com/@jeremywarddev |

## User Stories

### PP-001: Hero Component (configurable size)

**Description:** As a developer, I want a reusable HeroComponent so that every
public page has a consistent, branded header section with configurable sizing.

**Acceptance Criteria:**

- [x] Component renders a large variant with prominent heading, subheading, and optional CTA button
- [x] Component renders a compact variant with smaller heading and optional subheading (no CTA)
- [x] Component is configurable for size, title text, subtitle text, and an optional CTA (label + destination)
- [x] Both sizes are visually distinct and use Tailwind/DaisyUI utility classes
- [x] Component follows existing ViewComponent patterns (`app/components/ui/public/`)
- [x] Component test covers both size variants
- [x] All tests pass
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/components/ui/public/hero_component_test.rb`

### PP-002: Social Links Component

**Description:** As a visitor, I want to see Jeremy's social profiles so that I
can follow his work across platforms.

**Acceptance Criteria:**

- [x] Component renders a full variant showing platform name/label alongside an icon
- [x] Component renders a compact variant showing icon-only links in a horizontal row
- [x] Each link opens in a new tab with appropriate security attributes
- [x] Component supports X (Twitter), LinkedIn, and YouTube platforms
- [x] Component follows existing ViewComponent patterns (`app/components/ui/public/`)
- [x] Component test covers both variants and link attributes
- [x] All tests pass
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/components/ui/public/social_links_component_test.rb`

### PP-003: Project Card Component

**Description:** As a visitor, I want to see curated project cards so that I can
learn about Jeremy's work and visit the projects.

**Acceptance Criteria:**

- [x] Component displays a project name, description, technology tags, and a link to the project
- [x] Tags render as DaisyUI badge elements
- [x] Card follows the same styling pattern as existing card components
- [x] Component follows existing ViewComponent patterns (`app/components/ui/public/`)
- [x] Component test covers rendering of all card elements
- [x] All tests pass
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/components/ui/public/project_card_component_test.rb`

### PP-004: Home Page

**Description:** As a visitor, I want to land on a branded home page so that I
understand who Jeremy Ward is and what he builds.

**Acceptance Criteria:**

- [x] Home page renders the HeroComponent in large size with heading "Jeremy Ward", subtitle about building SaaS with Rails + AI, and a CTA linking to the Services & Portfolio page
- [x] Page includes a brief intro section below the hero
- [x] Existing `root_path` route continues to serve the home page
- [x] i18n keys follow the `public.pages.home.*` pattern
- [x] All tests pass
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/system/public/home_page_test.rb`

### PP-005: Services & Portfolio Page

**Description:** As a visitor, I want to browse Jeremy's services and curated
projects so that I can see what he offers and what he has built.

**Acceptance Criteria:**

- [x] New `portfolio` action added to `Public::PagesController`
- [x] Route added: `GET /portfolio` mapped to `pages#portfolio`
- [x] Project data is defined as static structured data (YAML file or equivalent)
- [x] Page renders HeroComponent in compact size with "Services & Portfolio" title
- [x] Page includes a services section with capabilities list and consulting availability blurb (from provided copy)
- [x] Page renders a ProjectCardComponent for each project in a responsive grid (1 col mobile, 2 col tablet, 3 col desktop)
- [x] Page includes the philosophy blurb below the project grid (from provided copy)
- [x] Projects rendered: CoverText/ClientCompass, WorkhorseOps, RailsFoundry, Workhorse Compliance, RFP/Grant Ecosystem
- [x] i18n keys follow the `public.pages.portfolio.*` pattern
- [x] All tests pass
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/system/public/portfolio_page_test.rb`

### PP-006: About Page

**Description:** As a visitor, I want to read about Jeremy so that I understand
his background and can connect with him on social platforms.

**Acceptance Criteria:**

- [ ] New `about` action added to `Public::PagesController`
- [ ] Route added: `GET /about` mapped to `pages#about`
- [ ] Page renders HeroComponent in compact size with "About" title
- [ ] Page includes the full bio content from the provided About copy (multiple sections with bold subheadings)
- [ ] Page renders the SocialLinksComponent in full variant with links to X (@jeremywarddev), LinkedIn (in/jrmyward), and YouTube (@jeremywarddev)
- [ ] i18n keys follow the `public.pages.about.*` pattern
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** About page shows a compact hero, multi-section bio content with bold subheadings, and a social links section displaying platform names and icons as clickable links

### PP-007: Update Footer with Social Links

**Description:** As a visitor, I want to see social links in the footer so that
I can connect from any page.

**Acceptance Criteria:**

- [ ] Footer component is updated to accept optional social links data
- [ ] Footer renders the SocialLinksComponent in compact variant (icon-only row)
- [ ] Social links appear above the copyright line
- [ ] The public layout passes the social links data (X, LinkedIn, YouTube) to the footer
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** Every public page footer displays a row of social link icons (X, LinkedIn, YouTube) above the copyright text

### PP-008: Update Navigation

**Description:** As a visitor, I want the site navigation to reflect the actual
pages so that I can easily find Home, Portfolio, and About.

**Acceptance Criteria:**

- [ ] Public layout header navigation is updated to: Home, Portfolio, About
- [ ] Mobile drawer navigation matches desktop navigation
- [ ] Old placeholder nav items (features, how it works, pricing, FAQ) are removed
- [ ] Named route helpers are used in navigation links
- [ ] Active state highlights the current page in the nav
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** Desktop and mobile navigation show Home, Portfolio, and About links; the current page link is visually highlighted

## Functional Requirements

- FR-1: `UI::Public::HeroComponent` renders two size variants (large, compact) with title, subtitle, and optional CTA
- FR-2: `UI::Public::SocialLinksComponent` renders two variants (full with labels, compact icon-only) for a list of social platform links
- FR-3: `UI::Public::ProjectCardComponent` renders a card with project name, description, tags, and external link
- FR-4: Home page (`/`) displays large hero and intro section
- FR-5: Services & Portfolio page (`/portfolio`) displays compact hero, services section, responsive project grid, and philosophy blurb
- FR-6: About page (`/about`) displays compact hero, multi-section bio, and full social links
- FR-7: Footer on all public pages includes compact social link icons
- FR-8: Navigation updated to Home, Portfolio, About (removing placeholder items)
- FR-9: All content is static — no database migrations or models required
- FR-10: i18n keys follow the existing `public.pages.<action>.<key>` pattern

## Non-Goals

- No database-backed project management (future enhancement via Signal Radar)
- No blog/post system (separate future PRD)
- No contact form or email capture
- No animations or JavaScript-heavy interactions
- No SEO meta tags or Open Graph — defer to a future PRD
- No admin interface for editing page content

## Design Considerations

- Use Tailwind + DaisyUI exclusively (no custom CSS), matching existing patterns
- Reuse `UI::SectionComponent` for page section layout (background variants, padding)
- Follow existing ViewComponent patterns: `initialize` with keyword args, private `attr_reader`, `.html.erb` template
- Hero should feel authentic to a developer brand — not corporate/generic
- Project cards in a responsive grid: 1 column on mobile, 2 on tablet, 3 on desktop
- Heroicons does not include brand icons — use inline SVGs for social platform icons (X, LinkedIn, YouTube)

## Technical Considerations

- All new components live under `app/components/ui/public/`
- Views live under `app/views/public/pages/`
- i18n strings in the existing locale files under `public.pages.*`
- Project data can live in `config/projects.yml` or as a simple data structure in a helper/concern — avoid over-engineering
- The pricing page route and action already exist — leave as-is (out of scope)
- Use inline SVGs for social brand icons since Heroicons doesn't include them

## Success Metrics

- All three public pages render correctly and pass system tests
- Navigation accurately reflects the site structure
- Social links appear on About page (full) and footer (compact)
- `bin/ci` passes with all new tests
- Components are reusable and follow established ViewComponent patterns

## Open Questions

- Should the home page include a "Featured Projects" preview section linking to `/portfolio`?
  <!-- review_prd: Non-blocking. Default: No — keep the home page minimal for v1 (hero + intro). Can be added in a follow-up. -->
- Should the pricing page route be removed or left as-is?
  <!-- review_prd: Non-blocking. Default: Leave as-is — it's out of scope for this PRD and removing it risks breaking existing links. -->

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | PP-001: Hero Component | — | Foundation component used by all three pages |
| 2 | PP-002: Social Links Component | — | Foundation component used by About page and footer |
| 3 | PP-003: Project Card Component | — | Foundation component used by Portfolio page |
| 4 | PP-004: Home Page | PP-001 | Needs HeroComponent |
| 5 | PP-005: Services & Portfolio Page | PP-001, PP-003 | Needs Hero and ProjectCard components |
| 6 | PP-006: About Page | PP-001, PP-002 | Needs Hero and SocialLinks components |
| 7 | PP-007: Update Footer with Social Links | PP-002 | Needs SocialLinksComponent |
| 8 | PP-008: Update Navigation | PP-004, PP-005, PP-006 | Needs all page routes to exist |
