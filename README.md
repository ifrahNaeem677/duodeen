# DuoDeen: How to run it (Windows, VS Code, Android)

## One-time setup (about 1 hour, mostly downloads)
1. Install **VS Code**: https://code.visualstudio.com
2. Install **Android Studio**: https://developer.android.com/studio
   - Open it once, click Next through the setup wizard (it downloads the Android SDK).
   - More Actions → SDK Manager → SDK Tools tab → tick **Android SDK Command-line Tools** → Apply.
3. Install **Flutter**: in VS Code, open Extensions (Ctrl+Shift+X), install **Flutter** (by Dart Code).
   Then Ctrl+Shift+P → type `Flutter: New Project`. VS Code will offer **Download SDK**, so click it and pick a folder like `C:\src`.
   When asked, click **Add SDK to PATH**. Restart VS Code.
4. Open a terminal in VS Code (Ctrl+`) and run:
   ```
   flutter doctor --android-licenses
   ```
   Type `y` and Enter for every question. Then run `flutter doctor`; Flutter and Android toolchain should show ✓.

## Create the project
5. Ctrl+Shift+P → `Flutter: New Project` → **Application** → choose a folder → name it `duodeen`.
6. Unzip this download. Copy its `lib` folder into your new `duodeen` folder and **Replace** when asked.
7. Delete the file `test/widget_test.dart` (it refers to the old sample app).

## Run on Android
8. **Real phone:** Settings → About phone → tap *Build number* 7 times → back to Settings → Developer options → turn on **USB debugging**. Plug in with USB and tap **Allow**.
   **Or emulator:** Android Studio → More Actions → Virtual Device Manager → Create device → Pixel → Next → download a system image → Finish → ▶ Play.
9. In VS Code, click the device name at the bottom-right corner and pick your phone or emulator.
10. Open `lib/main.dart` and press **F5**. The first build takes 3–5 minutes; later ones are fast.
    While it runs, save a file (Ctrl+S) to see changes instantly (hot reload).
