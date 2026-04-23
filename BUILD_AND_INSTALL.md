# Get Focus Arena onto your iPhone (no Mac required)

You need: this folder, a Windows PC, an iPhone, a free GitHub account, a free Apple ID, and a USB-to-Lightning/USB-C cable.

The flow: GitHub builds the app on a free cloud Mac → you download the `.ipa` to your PC → Sideloadly installs it on your iPhone using your Apple ID.

> Free Apple ID signing expires after **7 days**. Just re-run Sideloadly to refresh. A paid Apple Developer account ($99/yr) extends this to 1 year.

---

## Step 1 — Push the code to GitHub

1. Install [Git for Windows](https://git-scm.com/download/win) and [GitHub CLI](https://cli.github.com/) (or use the GitHub web UI).
2. From PowerShell in this folder:

```powershell
git init
git add .
git commit -m "Initial commit"
gh auth login                       # follow prompts, pick HTTPS
gh repo create focus-arena --public --source=. --remote=origin --push
```

If you'd rather avoid the CLI: create a new empty repo at github.com, then run:
```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/focus-arena.git
git push -u origin main
```

> A public repo gets unlimited free macOS build minutes. A private repo gets ~200 minutes/month free, which is more than enough.

## Step 2 — Wait for the build

1. Open your repo on github.com.
2. Click the **Actions** tab. You'll see "Build Unsigned IPA" running. It takes ~5-10 minutes.
3. When it's green, click into the run.
4. Scroll to **Artifacts**, click `FocusArena-unsigned-ipa` to download a zip containing `FocusArena-unsigned.ipa`.
5. Extract the `.ipa` somewhere convenient.

> If the build fails, click into the failed step to see the log. Most failures are missing files or typos — paste the error to me and I'll fix it.

## Step 3 — Install Sideloadly on Windows

1. Download Sideloadly from [sideloadly.io](https://sideloadly.io) (free).
2. Install it. It will prompt you to install **iTunes** if not already present — install it (Apple's drivers are required for the PC to talk to your iPhone).
3. Plug your iPhone into the PC. On the iPhone, tap **Trust** when asked.

## Step 4 — Sideload onto your iPhone

1. Open Sideloadly.
2. Drag `FocusArena-unsigned.ipa` into the Sideloadly window.
3. Pick your iPhone from the device dropdown.
4. Enter your **Apple ID email**. (Use a throwaway Apple ID if you're worried — the free signing tier doesn't require a paid account.)
5. Click **Start**. Enter your Apple ID password when prompted. If your account has 2FA, generate an [app-specific password](https://account.apple.com/account/manage) and use that instead.
6. Sideloadly does its thing (~1-2 min). When done, the app appears on your home screen.

## Step 5 — Trust the developer cert on your iPhone

iOS won't run a sideloaded app until you approve its signing identity:

1. **Settings → General → VPN & Device Management**
2. Under "Developer App," tap your Apple ID.
3. Tap **Trust** → confirm.
4. Open Focus Arena from your home screen.

## Step 6 — When the 7-day signature expires

The app will silently stop launching. To refresh:

1. Plug your iPhone back in.
2. Open Sideloadly with the same `.ipa` and Apple ID.
3. Click **Start**. Sideloadly re-signs in place — your data stays.

---

## Pushing updates later

Edit any source file, then:

```powershell
git add .
git commit -m "Tweak fail screen"
git push
```

GitHub rebuilds automatically. Download the new artifact, sideload it. Your saved sessions/XP persist between installs as long as you don't delete the app.

## Troubleshooting

- **"This app cannot be installed because its integrity could not be verified"** → re-do Step 5 (trust the developer profile).
- **Sideloadly says "Could not find Provision Profile"** → re-enter your Apple ID, make sure 2FA app-password is correct.
- **Build fails on `xcodegen generate`** → check the logs for missing files; paste the error to me.
- **Build fails on signing** → the workflow uses `CODE_SIGNING_ALLOWED=NO`. If you see signing errors, the workflow file got modified; restore it from this commit.
- **App icon is gray/blank** → expected. The asset catalog has no icon image. Drop a 1024×1024 PNG into `FocusArena/Resources/Assets.xcassets/AppIcon.appiconset/` named `Icon.png` and add `"filename": "Icon.png"` to the image entry in `Contents.json`.

## Alternatives I didn't pick

- **AltStore / SideStore** — works similarly to Sideloadly, requires AltServer running on your PC permanently to refresh the app. More setup, less Windows-friendly.
- **TestFlight** — needs a paid Apple Developer Program membership and App Store Connect upload from a Mac. Not free, not without a Mac.
- **Xcode Cloud / Codemagic** — paid services that do similar to GitHub Actions. GitHub is free and good enough.
- **Renting a cloud Mac** (MacInCloud, etc.) — works, but costs $20+/month and you'd still need to sideload onto your phone afterward. GitHub Actions does the same job for free.
