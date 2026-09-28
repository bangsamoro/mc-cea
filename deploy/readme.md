# Deploy MC-CEA — A → GitHub → C → B

**A** (dev, `C:\xampp\htdocs\cea`) → `git push` → **GitHub** (`bangsamoro/mc-cea`) →
`git pull` → **C** (Windows, WinSCP) → **B** (`B-HOST`, Ubuntu/Apache, `/var/www/html`).

Live URL: **<https://mc-cea.ksu.edu.sa/>** (inside KSU only).
LAN check: <http://B-HOST/>.

A **cannot** reach B or C except over RDP (verified: B ports 21/22/989/990 are closed from A, C port
22 is closed), so the upload always runs **on C**. C is the only box with a route to B.

The site has **no build step** — publishing is just copying files.

---

## The workflow

| Step | Where | What |
|---|---|---|
| 1 | **A** | edit in `C:\xampp\htdocs\cea`, preview at <http://localhost/cea/>, then `git push origin main` |
| 2 | **C** | `git pull origin main` in the clone (`C:\Users\DELL\MCCEA`) |
| 3 | **C** | run `deploy\deploy-mc-cea.bat` → WinSCP mirrors the folder into B's **docroot** (`/var/www/html`), which replaces the old home page |

Steps 2 and 3 are what `deploy-mc-cea.bat` does in one double-click.

## One-time setup on C

1. **WinSCP** installed (default path `C:\Program Files (x86)\WinSCP\`).

2. **Tell the kit how to reach B.** Either way works - the launcher prefers the
   local file and falls back to the saved session.

   **A. A local connection file** (no WinSCP GUI needed):

   ```bat
   echo sftp://root@B-HOST/> "C:\Users\DELL\MCCEA\deploy\connection.local.txt"
   ```

   Change `root` if you connect as a different user. The file holds one line,
   may be a URL *or* a saved-session name, and is **git-ignored** - so the real
   address never reaches GitHub.

   **B. A saved WinSCP session** - open WinSCP, *New Session*: **SFTP**, host
   `B-HOST`, port `22`, your SSH user, then *Save* and name it **exactly `B`**.
   Log in once and tick *Save password*.

   To see which sessions already exist:

   ```bat
   reg query "HKCU\Software\Martin Prikryl\WinSCP 2\Sessions"
   ```

3. **Accept B's host key once.** If WinSCP has never connected to B from this
   machine, connect once in the GUI and accept the key. After that the script
   runs unattended.

No setup is needed on B: the docroot already exists and you connect as `root`,
so permissions already work.

## Every deploy

0. **On A:** `git push origin main` (the repo is the only channel from A).
1. **On C:** double-click **`deploy\deploy-mc-cea.bat`** — or pass a folder:
   `deploy-mc-cea.bat D:\sites\mc-cea`. It does:

   ```
   1/2  git pull origin main        (only if the folder is a git clone - skipped otherwise)
   2/2  WinSCP  synchronize remote  ->  /var/www/html
   ```

2. **Check** from A: <http://B-HOST/>.

> If WinSCP says 'Host "B" does not exist.', the saved session has not been created - that is step 2 of the
> one-time setup above. The full WinSCP log lands in `%TEMP%\mc-cea-deploy.log`.

## What is uploaded

Everything in the site folder **except** the dev-only material, which the script's
filemask keeps off the server:

| Skipped | Why |
|---|---|
| `.git/`, `.gitignore`, `.gitattributes` | version control, not content |
| `*.md` | the runbook and README (they name internal hosts and paths) |
| `deploy/` | WinSCP scripts and the deploy log |
| `preview/` | local screenshots |
| `assets/` | empty leftover from before the `css/` + `img/` split |
| `*.log` | runtime junk |

Uploaded, and wanted on B: `index.html`, `css/`, `img/`, `services/`, and
**`.htaccess`** — that last one is what stops Apache from serving `.md` / `.sh` /
`.bat` / dotfiles if anything ever does land there.

## Notes

- **No `-delete`.** The script overwrites changed files but never removes files on B
  that are missing locally. If you want the remote folder to mirror the local one
  exactly (so a deleted page disappears from B too), add `-delete` to the
  `synchronize` line — it is commented in `deploy.winscp.txt` with the exact syntax.
- **Timestamps.** `synchronize -criteria=time` compares file times, and WinSCP
  preserves them by default — leave that on.
- **`.htaccess` needs `AllowOverride`.** If Apache has overrides off, the deny rules
  are silently ignored (the site still works, the files are just public). Check on B
  over SSH and either enable overrides or put the same rules in the vhost. On A's
  XAMPP it is confirmed **on**: `http://localhost/cea/readme.md` returns 403.
- **Cache.** Static files, no service worker, no cache-busting needed. A hard refresh
  (Ctrl-F5) is enough if the browser holds on to the old page.
- Only `index.html`, `css/style.css` and `img/ksumc-logo.png` matter for the home page.
  Editing the site means touching those (plus `css/service.css` and `services/*.html`
  once the detail pages exist).
- **Pushing from A is the only way changes leave A.** The site folder on C is a clone,
  so editing files on C directly would be overwritten by the next `git pull`.
