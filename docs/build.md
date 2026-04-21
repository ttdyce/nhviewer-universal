# In-Depth Build Instructions

### NOTE: At this time, build to APK is disabled. You will need to build straight to your Android phone for this app to work.

# Requirements
- Flutter app (for building the app)
- Android Studio SDK (for connecting to the phone)
- Android phone in developer mode (for building to)
- A USB(C) connector (for connecting for USB debugging)
- VSCode (recommended)

### Notes
At this time, because build to APK is disabled, it will be challenging to build this app over SSH. You would need to SSH into the system your Android phone is connected to, and at that point, it would be easier to simply use that system directly.

# 1. Download and Install Flutter
As with the rest of the steps, if you already have Flutter installed, you need not worry about this one.

Flutter can be installed using according to [the docs](https://docs.flutter.dev/install/quick). You can also install the VSCode extension which will allow you to use Flutter, but this will not install Flutter. You will need to install the SDK separately.

# 2. Download and install Android Studio SDK
It is easiest to just install Android Studio from [the install page](https://developer.android.com/studio). On first run, you will be asked to install the SDK.

# 3. Set Android phone to Developer mode
If you haven't already set your Android phone to developer mode, please see the instructions page for your model. 

# 4. Using the Flutter CLI
Flutter will try to install itself to your terminal, so you should just be able to used `flutter`. If this fails, you can also navigate to your Flutter install and use `flutter\bin\flutter` on Windows or `./flutter/bin/flutter` on Mac/Linux. If you just run the command, it should give a simple help message.

## 4.1 Verify device connection
You can use `flutter devices` (or one of the above commands) to list the devices connected to the system. This should output something like the following:

```
Found 4 connected devices:
  SM S000U (mobile) • ABCDEFGHIJK • android-arm64  • Android 16 (API 36)
  Windows (desktop) • windows     • windows-x64    • Microsoft Windows [Version 10.0.26200.8246]
  Chrome (web)      • chrome      • web-javascript • Google Chrome 147.0.7727.56
  Edge (web)        • edge        • web-javascript • Microsoft Edge 147.0.3912.72

Run "flutter emulators" to list and start any available device emulators.
```

# Actually doing the build
Now, if all has gone well, you should be able to just run `flutter run`. It will install to your phone on first run. You can now safely eject your phone from your computer and use it as normal.

#### Credits

*Written by afterDarkInvalid, 2026-04-20*