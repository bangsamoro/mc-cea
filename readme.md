# MC-CEA Page

Simplified single-page site for **MC-CEA — Medical City · Corporate Engineering Affairs** (KSUMC).

Original file: `index.html` (2.4 MB, everything inline). This version: **6.7 KB** of markup, with
styles and images split out — **149 KB total**.

## Files

| File | Purpose |
|---|---|
| `index.html` | The page markup only (6.7 KB). No `<style>` block. |
| `css/style.css` | All home-page styles. Re-skin the site from the `:root` tokens at the top. |
| `css/service.css` | Styles for the service detail pages. |
| `img/ksumc-logo.png` | The MC-CEA services-portal badge (512×512, rebuilt as a clean transparent PNG). |
| `services/_template.html` | Detail-page template — copy, rename, edit the marked lines. |
| `services/*.html` | Not created yet — the six card links point here. |
| `preview/desktop.png`, `preview/mobile.png` | Rendered screenshots (1440 px / 414 px). |
| `.htaccess` | Deny rules: no `.md` / `.sh` / `.bat` / dotfiles served over HTTP. |
| `deploy/` | WinSCP publish kit — see *Deploy* below. |

## Structure

```
mc-cea/
├── index.html            markup only
├── css/
│   ├── style.css         home page
│   └── service.css       service detail pages
├── img/
│   └── ksumc-logo.png    one copy, used 7×
├── services/
│   └── _template.html    copy → services/<slug>.html
├── deploy/               publish kit (not uploaded)
└── preview/              screenshots (not uploaded)
```

**Page anatomy** (top to bottom): sticky header lockup → hero (logo, badge, `h1`, two buttons) →
services grid (6 cards, each an `<a>`) → call to action → footer. Every section is a plain block with
its own class; there is no JavaScript and no build step, so the browser renders the files exactly as
written.

## How to open / preview

**This project lives at `C:\xampp\htdocs\cea`** — that is the working copy, and it is a git
repo with the same history as GitHub. XAMPP is already serving it, so there is nothing to copy:

- **Preview:** <http://localhost/cea/> (Apache on this machine).
- **Any static host:** upload the folder as-is (relative paths only, no build step).
- **Without XAMPP:** `python -m http.server 8899` inside the folder, then <http://127.0.0.1:8899/>.

The other copy under the agent workspace (`projects/mc-cea`) is a frozen snapshot; it is no
longer edited.

No build step, no dependencies — plain HTML + CSS.

## What changed

| # | Requested change | Done |
|---|---|---|
| 1 | Flat icons only, no SVG | All 11 inline `<svg>` replaced with Font Awesome 6 flat icons (`<i class="fa-solid …">`). Zero `<svg>` left. |
| 2 | Hero headline | Now `Welcome to Medical City - Corporate Engineering Affairs`. |
| 3 | Remove hero paragraph | Removed. |
| 4 | Remove the 4 stat cards | `.stats-bar` block and its CSS removed. |
| 5 | Section heading → `MC-CEA Services and Projects` | Done; subtitle removed; cards kept. |
| 5b | Add link template | Every card is now an `<a class="service-card">` with an href + a "Learn more →" affordance. |
| 6 | Remove "Our network footprint" | Whole network section (heading, hub, 6 nodes) and its CSS removed; dead "Network" nav link removed. |
| 6b | CTA heading | Now `Need Engineering and Project Support`. |
| 7 | Footer brand | Name `MC-CEA`, department `MEDICAL CITY - CORPORATE ENGINEERING AFFAIRS`. |
| 7b | Header lockup | Now `MC-CEA` on top of `Medical City — Corporate Engineering Affairs`, set at **headline size** (32 px desktop / 20 px mobile, weight 800); logo mark grown 44 → 56 px. Browser tab title aligned to the same brand. |
| 8 | `&amp;` → space | All 4 occurrences replaced with a space. |
| 9 | Split `css/` + `img/`, slim down `index.html` | CSS moved to `css/style.css` (home) and `css/service.css` (detail pages); logo moved to `img/`; `index.html` is markup only — **18.5 KB → 6.7 KB**. Verified pixel-identical to the previous build. |
| 10 | UI/UX pass | Hero → `Welcome to the Services Platform of the Corporate Engineering Affairs`; section heading → `MC-CEA Services and Links`; first three cards replaced (see below). |
| 11 | CTA rework | Heading → `CORPORATE ENGINEERING AFFAIRS`; `Open a ticket` (mailto) → **Open MAXIMO** → the Maximo web client in a new tab; `Call support` → `Contact CEA` (still dials `+966114675000`). |
| 12 | Cards 4-6 replaced | Technical Support -> Report Untagged Devices; Monitoring Analytics -> CEA System Evaluation; Integration Services -> IFR Report System. All three hrefs renamed to match their new titles (still placeholder pages). |
| 13 | Cards 7-8 added | **DIWAN Power BI Dashboard** (Power BI dashboard link) + **HEPA Filter Schedules** (CEA SharePoint list). |
| — | Encoding repair | Mojibake (`â€”`, `Â©`) fixed to `—` and `©`. The file was double-encoded UTF-8. |
| — | File size | 8 byte-identical base64 logos (2.4 MB) → 1 shared PNG. Page weight down **94 %**. |

### Card set (current)

| # | Card | Icon | Target |
|---|---|---|---|
| 1 | MAXIMO EAM (Enterprise Asset Management) system | `fa-screwdriver-wrench` | `http://kksrv-maximo1.ksuhs.edu.sa/maximo/webclient/login/login.jsp` *(new tab)* |
| 2 | CEA Systems Evaluation | `fa-list-check` | `https://ksusa.sharepoint.com/sites/CEA/Lists/CEASEvaluation/AllItems.aspx` *(new tab)* |
| 3 | Space Allocation | `fa-building` | `#` — placeholder, still needs a URL |
| 4 | Report Untagged Devices | `fa-camera` | `services/report-untagged-devices.html` — page not written yet |
| 5 | CEA System Evaluation | `fa-gears` | `services/cea-system-evaluation.html` — page not written yet |
| 6 | IFR Report System | `fa-triangle-exclamation` | `services/ifr-report-system.html` — page not written yet |
| 7 | DIWAN Power BI Dashboard | `fa-chart-column` | Power BI dashboard link *(new tab)* |
| 8 | HEPA Filter Schedules | `fa-wind` | `https://ksusa.sharepoint.com/sites/CEA/Lists/HEPA 101/AllItems.aspx` *(new tab)* |

## How to customise

| What | Where |
|---|---|
| Service card target links | `index.html` → each `<a href="services/…">`. Template marker in the HTML comment above the grid. |
| Card title / description / icon | Inside each `service-card`; icons are `fa-solid` class names from <https://fontawesome.com/icons>. |
| Brand name in header / footer | `.logo-text .main` / `.sub` (header) and `.footer-brand` (footer). |
| Colours | `css/style.css` → the `:root` tokens at the top (`--ksu-blue`, `--ksu-cream`, …). |
| Section headings | `.section-title h2`. |
| Background watermark words | `.watermark-ens` / `.watermark-ksumc` (decorative, 3.5 % opacity). |
| Contact links | CTA block in `index.html`: **Open MAXIMO** → the Maximo web client; **Contact CEA** → `tel:+966114675000`. |

## Adding a new service page

1. Copy `services/_template.html` → `services/my-service.html`.
2. Edit the four lines marked `<!-- EDIT: … -->` plus the title.
3. Point the card's `href` in `index.html` at it.

The template already uses correct relative paths (`../img/…`, `../css/service.css`, `../index.html`).

## Quality coverage

- **Responsive:** grid collapses 3 → 1 column; verified at 1440 px and 414 px (no overflow, no overlap).
- **States:** card hover (lift, blue top rule, arrow slide) and `:focus-visible` outlines on cards, buttons and links — keyboard reachable.
- **Motion:** all animation disabled under `prefers-reduced-motion: reduce`; faded-in content forced visible.
- **Accessibility:** decorative images `alt=""` + `aria-hidden`, icons `aria-hidden`, real `<a>`/`<h1>`/`<h2>` semantics.
- **Verified:** page served locally, loaded in Chrome headless, screenshots inspected — icons render as real glyphs, logo loads, no leftover stats/network markup, no `&amp;`, no mojibake.

## Notes / caveats

- The **header lockup**, the **footer brand** and the **tab title** now all use the MC-CEA naming, so
  the old ENS branding is gone from the page chrome. Only the decorative background watermark still
  spells `ENS`.
- The portal is published to B's **docroot**, so it replaces the old `WELCOME TO THE HOME OF ENS - CEA`
  placeholder and lives beside `ifr/`, `tag/` and `phpmyadmin/`. The sync never deletes, so those are safe.
- Icons + fonts load from CDNs (Font Awesome, Google Fonts). If the page must work on a host
  without internet, the icons degrade to blank boxes — tell me and I'll self-host them.
- The faint background watermark still spells `ENS`; say the word and it becomes `MC-CEA`.
- Reference to the original single-file build: if you need a **self-contained** `index.html`
  (no `css/` or `img/` folder), I can inline both again.

## Deploy — A → GitHub → C → B over SFTP

**The workflow is A → GitHub → C → B:** A pushes to `bangsamoro/mc-cea`, C pulls,
then C publishes. Publishing runs **on C** with WinSCP and mirrors the site folder into B's **docroot** (`/var/www/html`) so the portal *is* the site home page
(live at <https://mc-cea.ksu.edu.sa/>). A cannot reach B or C on any file-transfer port
(B: 21/22/989/990 and C: 22 are all closed from A — only RDP 3389 to C is open), which is why this
leg lives on C, exactly like the `tag` app. Code reaches C through GitHub - the repo is public,
so C pulls anonymously - and the RDP copy of `mc-cea-site.zip` is only a fallback.

| File | Purpose |
|---|---|
| `deploy/deploy-mc-cea.bat` | Double-click on C — publishes the folder to B. |
| `deploy/deploy.winscp.txt` | The WinSCP `synchronize remote` script the `.bat` calls. |
| `deploy/readme.md` | Full runbook: one-time WinSCP session setup, every-deploy steps, filemask. |
| `.htaccess` | Deny rules for `.md` / `.sh` / `.bat` / dotfiles. Kept in the repo, but **not uploaded** to the docroot - it would cascade over `ifr/` and `tag/`. |

`deploy/post-receive` is a leftover from an earlier git-relay attempt that was **stopped on request**;
it is unused and the WinSCP filemask excludes it from the upload.
