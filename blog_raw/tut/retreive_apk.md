# Retreive an APK from a non-rooted Android device

## Context

I recently installed [LineageOS](https://lineageos.org) and [LineageOS addonsu](https://download.lineageos.org/extras) on my old OnePlus X phone to un-google it and get root access on it.
The reason I did that is simple: I bought the device, it sould be normal I get root access on it, it should not be Google's.

The system works perfectly.
For most apps I used, a FOSS replacement was quickly found on [F-Droid](https://f-droid.org), but I still faced a problem for some apps, such as Discord, Magic Earth, etc.

We'll focus on Magic Earth in this tutorial.
Magic Earth is not on F-Droid and doesn't provide any APK (an Android application package) elsewhere than the Google Play Store.
Sure, some websites say they'll give you "free magic earth apk no viruses no spyware", but it seemed a little... unsafe to me.

The thing is, Magic Earth is installed on my current, non-rooted phone, from Google Play Store.

"In order to be installed, the APK file has to be downloaded, and is probably still somewhere on the phone", I thought.

Turns out I was right, here is how to retreive it from the non-rooted phone, just using [adb (Android Debug Bridge)](https://developer.android.com/studio/releases/platform-tools).

## Installing ADB on a computer

Download it from the above link.

On most Linux distros, it is also available directly from the package manager (`android-tools` on Arch).

## Enable USB debugging from the device

This will allow us to perform adb commands with our phone connected to a computer.

To do so, head to the settings app.
In the "About phone" section tap 7 times on the build number, a toast saying "You are now a developer" should appear.
Go back home on the settings app, and to "Developer options".
From there, enable USB debugging.

## Pair the phone to the computer

Linux users might have to run the following commands as root (with sudo).

First, run `adb devices`.
You should get a pop-up on your phone asking to trust the computer, accept.

```
me : ~ $ sudo adb devices
* daemon not running; starting now at tcp:5037
* daemon started successfully
List of devices attached
XXXXXXXXX	device
```

The device is now attached, we will be able to proceed!

## Get the package id

We need to find the app's package name.
To do so, we'll list every app installed on our phone: `adb shell pm list packages`

Which give us a list of all app packages installed.

```
me : ~ $ sudo adb shell pm list packages
package:...
package:com.generalmagic.magicearth
package:...
```

💡 Linux users can use `grep` to filter the results: `adb shell pm list packages | grep magic`

We deduce Magic Earth's package id is `com.generalmagic.magicearth`.

## Get the APK location

This information allows us to ask the device the APK's location, with one command: `adb shell pm path com.generalmagic.magicearth`.

```
me : ~ $ sudo adb shell pm path com.generalmagic.magicearth
package:/data/app/com.generalmagic.magicearth-XXXXXXXXXXXXXXXXXXXXXX==/base.apk
```

It's a path we can't access on Android (unless our phone has root access), but adb can!

## Retreive the APK

adb allows us to pull data from our phone, just run `adb pull <path>`.

```
me : ~ $ sudo adb pull /data/app/com.generalmagic.magicearth-XXXXXXXXXXXXXXXXXXxxXX==/base.apk
/data/app/com.generalmagic.magicearth-XXXXXXXXXXXXXXXXXXXXXX==/base.apk: 1 file pulled, 0 skipped. 37.6 MB/s (52342418 bytes in 1.326s)
```

We now have a file `base.apk` we can rename `magicearth.apk`.

I copied this file to my LineageOS phone, and installed it like a standard APK file.
