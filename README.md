# DuoDeen V3: setup

Supabase URL + publishable key are already in `lib/main.dart`. Never put the secret key in the app.

## 1. Supabase (one time)
SQL Editor → New query → paste **all** of `supabase/duodeen_v3.sql` → **Run**.
It keeps profiles / pairs / daily_entries and adds:
- `permanent_skills` table (60-day skill, locked until finished)
- `messages` table (chat + snaps)
- Storage bucket `snaps` (public read, logged-in users upload)
- columns `read_book`, `skill_done`, `tasbeeh_count` on daily_entries
- score V3 (max 120 = old 100 + Read Book 10 + Work On My Skill 10)
- realtime for live updates, safe pairing functions

## 2. Upload to GitHub
1. Repo → **Add file → Upload files** → drag `android`, `lib`, `tool`, `supabase`, `pubspec.yaml`, `README.md` → **Commit**.
   The `android` folder contains the build fix (desugaring, Java 17, minSdk 24, internet permission).
2. Build file (GitHub skips the `.github` folder when dragging):
   open `.github/workflows/build-apk.yml` in the repo → ✏️ Edit → select all → paste this zip's
   `.github/workflows/build-apk.yml` → Commit.
   (If your Actions run is already named "Build APK V2", that also works. The V3 build fix is in `tool/patch_android.py`.)
3. **Actions** → green ✓ → **Artifacts → DuoDeen-APK** → install `app-release.apk`.

## Build fix (built in)
`android/app/build.gradle.kts` is now part of the project, so the fix applies with ANY build file.
Also:
`tool/patch_android.py` runs in the GitHub build after `flutter create` and sets in
`android/app/build.gradle.kts`: `isCoreLibraryDesugaringEnabled = true`, Java/Kotlin 17,
`coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`, plus INTERNET permission.
Building on your own computer? Run `python tool/patch_android.py` once after `flutter create .`.

## 3. Test V3
1. Both partners log in → each one must set their own skill (full screen, cannot skip).
2. Home: My Skill card → **Done Today** → +10 pts, streak +1. Partner sees it in "Partner's Skill".
3. Add a goal → partner sees it live in "Partner's Goals Today" (read-only).
4. Chat tab → send a message and a Snap (camera or gallery) → tap the snap to view full screen.
