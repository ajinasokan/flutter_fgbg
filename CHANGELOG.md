## 0.7.1

* Fixed event broadcast if there are multiple listeners

## 0.7.0

* `FGBGEvents.stream` will contain events based on the `AppLifecycleListener` for Desktop and Web fallbacks. Earlier this was available only for the `FGBGNotifier` widget.
* `FGBGEvents.last` will return the last event captured
* `FGBGNotifier` will not send the event again if it is same as the last event
* Fixes `androidx.lifecycle` deprecations

## 0.6.0

* Updated compileSdkVersion to 34 to fix AAPT errors

## 0.5.0

* Attempt to update the list of supported platforms on pub.dev, since now all supported Flutter platforms are supported by the plugin.

## 0.4.0

* Desktop and Web fallbacks to `AppLifecycleListener` API. Thanks to #17 by @csells.

## 0.3.0

* Gradle 8 compatibility. Thanks @Rexios80
* New `FGBGEvents.ignoreWhile` API

## 0.2.2

* Move to mavenCentral

## 0.2.1

* Fix use of FGBGNotifier and event stream in multiple places

## 0.2.0

* Removed deprecated `registerWith` function to cleanup warnings

## 0.1.0

* Null safety migration

## 0.0.1

* Initial release.
