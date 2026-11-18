[app]

# (str) Title of your application
title = Employee App

# (str) Package name
package.name = employeeapp

# (str) Package domain (needed for android packaging)
package.domain = org.spcsalary

# (str) Source files where the app lives (relative to .spec)
source.dir = .

# (list) Source files to include
source.include_exts = py,png,jpg,kv,atlas

# (str) Application versioning
version = 0.1

# (list) Application requirements
requirements = python3,kivy

# (str) Supported orientations
orientation = portrait

# (int) Indicate if the application should be fullscreen or not
fullscreen = 0

# (str) Supported Android API
android.api = 33

# (str) Minimum API your APK will support
android.minapi = 21

# (int) Android NDK API; keep it aligned with the minimum supported API
android.ndk_api = 21

# (str) Android NDK version to use
android.ndk = 25b

# (int) Automatically accept Android SDK licenses
android.accept_sdk_license = True

# (str) Stable python-for-android branch used by Buildozer
p4a.branch = master
