#!/usr/bin/env bash
# A0: source scripts/env.sh before running Flutter, Gradle or adb.
# Keep toolchains, user configuration, temporary files and caches together.
export ANDROID_DEV_ROOT=/home/tidalflux/android-dev
export FLUTTER_ROOT="$ANDROID_DEV_ROOT/flutter"
export FLUTTER_HOME="$FLUTTER_ROOT"
export JAVA_HOME="$ANDROID_DEV_ROOT/jdk"
export ANDROID_HOME="$ANDROID_DEV_ROOT/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
# A0: the SDK CMake package also supplies Ninja for native plugin builds.
export CMAKE_HOME="$ANDROID_HOME/cmake/3.22.1"
export ANDROID_USER_HOME="$ANDROID_DEV_ROOT/android-user"
export ANDROID_EMULATOR_HOME="$ANDROID_USER_HOME"
export ANDROID_AVD_HOME="$ANDROID_USER_HOME/avd"
export PUB_CACHE="$ANDROID_DEV_ROOT/pub-cache"
export ANALYZER_STATE_LOCATION_OVERRIDE="$ANDROID_DEV_ROOT/dart-server"
export GRADLE_USER_HOME="$ANDROID_DEV_ROOT/gradle"
export XDG_CACHE_HOME="$ANDROID_DEV_ROOT/cache"
export XDG_CONFIG_HOME="$ANDROID_DEV_ROOT/config"
export XDG_DATA_HOME="$ANDROID_DEV_ROOT/data"
export TMPDIR="$ANDROID_DEV_ROOT/tmp"
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true
export CI=true
export PATH="$FLUTTER_ROOT/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$CMAKE_HOME/bin:$PATH"
mkdir -p "$ANDROID_USER_HOME" "$ANDROID_AVD_HOME" "$PUB_CACHE" \
  "$ANALYZER_STATE_LOCATION_OVERRIDE" \
  "$GRADLE_USER_HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" "$TMPDIR"
