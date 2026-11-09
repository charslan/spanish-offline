# Lingua Offline – Spanish Learning App

Fully offline Spanish A1 language learning app (inspired by Busuu).

## Features
- CEFR A1 course (Greetings, Numbers, Food, Travel + Checkpoint)
- Interactive lessons, dialogues & exercises
- Spaced Repetition vocabulary review
- Progress tracking & streaks
- 100% offline after install

---

## How to get the APK (No computer needed)

### Recommended: GitHub Actions

1. Create a **new empty repository** on GitHub (example name: `lingua-offline`).
2. Upload **all files and folders** from this project into the repository.
3. Go to the **Actions** tab.
4. Select **Build APK** on the left → click **Run workflow** → **Run workflow**.
5. Wait 4–8 minutes for the build to finish.
6. Open the finished workflow run → download the artifact **offline-language-app-apk**.
7. Unzip the file → you will get `app-release.apk`.
8. Transfer the APK to your phone and install it  
   (enable “Install unknown apps” if asked).

### Alternative: Codemagic
1. Go to https://codemagic.io and login with GitHub.
2. Add this repository.
3. Build as Flutter → Android APK.
4. Download the APK.

---

## Project contents
- Full A1 Spanish content pack (60 vocabulary items, 9 lessons)
- Home, Lesson, Review (SRS) and Profile screens
- Local progress storage
