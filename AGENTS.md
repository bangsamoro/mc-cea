# AGENTS.md — build rules for the cea app

Copied from the KSUMC starter kit (`github.com/bangsamoro/ksumc-starter-kit`) when the Modern Web
Guidance layer landed on 2026-11-12. The canonical version lives in the kit — change rules there and
re-copy, rather than editing this copy in isolation.

## Where the standard lives

- **Design system + machine flow** — `docs/KSUMC-STARTER-KIT.md` in the starter kit repo, `github.com/bangsamoro/ksumc-starter-kit` (not copied into this app).
- **Build-pattern manual** (commands, `.mwgrc` baselines, update procedure) — `docs/MODERN-WEB-GUIDANCE.md`
  in `github.com/bangsamoro/ksumc-starter-kit`.

## Mandatory for any HTML, CSS or client-side JS task

The guidance skill is committed in this repo at `.agents/skills/modern-web-guidance/` (209 guides). Do
not write layout, components, forms, animations, date/time handling or DOM code from memory — training
data is full of patterns the platform replaced years ago.

1. `npx -y modern-web-guidance@latest search "<2–5 word action query>"` — one capability per query, no
   framework or app nouns (`"light dismiss dialog"`, not `"close modal on outside click"`).
2. `npx -y modern-web-guidance@latest retrieve "<id>,<discipline-guide>"` and read the whole guide,
   fallbacks included. Discipline guides: `html`, `css`, `forms`, `accessibility`, `performance`, `security`.
3. Implement against the guide; re-check the code against it before reporting done.
4. End the reply with a `### Modern Web Guidance` section naming the guide ids that shaped the code and
   the specific rule each enforced. Nothing applied → say what you checked and why none fitted.

`legacy-scan` is for open-ended "modernise this codebase" work only, never for a named feature or bug.

## Authority order

- **Visual / brand** → the KSU design system (kit Part 1 + this app's `ksu` stylesheet). Palette, type
  stack, radius (12 / 9 px), hairlines instead of shadows, one pop shadow, emblem placement and opacity.
  Do not redesign these.
- **Implementation** → Modern Web Guidance: which native API, how focus moves, how errors are announced,
  which fallback, how work is scheduled.
- Conflict → keep the **house visual**, take the **modern technique**.

## Browser support policy

- Baseline **Widely available** → use as-is: no fallback, no polyfill, no feature detect.
- Below that → the guide's fallback. Budget: **≤ 20 lines, no new dependency**.
- No jQuery, no polyfill bundles, no utility library for what the platform now does natively
  (`<dialog>`, `popover`, `field-sizing`, `:user-invalid`, `Temporal`, fetch priorities).
- A different target must be written down — here, or pinned in `.mwgrc` with
  `npx -y modern-web-guidance@latest set-baseline newly|widely|limited|<year>` — before code relies on it.

## Non-negotiables

- KSU palette and tokens only; black is the action colour, `--ksu-blue` the accent. No new hexes.
- Cards: white, 1 px `#E3E6D8`, radius 12 px, no shadow. Focus ring `0 0 0 3px rgba(0,190,230,.22)` on
  every focusable control.
- Validation feedback only after interaction (`:user-invalid`), never on page load.
- Emblem on white/cream only, ≥ 24 px, ≤ 6 % as a watermark, never recoloured; no hot-linking.
- `utf8mb4` on every SQL import; no secrets in the repo — per-machine values live in `config.local.php`;
  `README.md` + changelog + version strings move in the same commit.
- Local testing on A uses the box IP, not `localhost` — `http://10.139.210.10/cea/` (kit §2.3a);
  never develop against B.
