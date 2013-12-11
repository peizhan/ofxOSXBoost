ofxOSXBoost
===========

Addon with Boost 1.55.0 for OSX / Xcode - Precompiled and Command to build yourself - Master is currently targeted for i386 (32bit) - Check Branches for x86_64 (64bit) - Designed for use as an open frameworks addon, however should definitely work for other OSX projects

Boost C++ Libraries 1.55.0 
===========
License: See Boost License LICENSE.MD


Where to checkout?
===========
- For openframeworks: Checkout in the addons folder like so: addons/ofxOSXBoost
- For others: anywhere you please


How to Build?
===========

1. Figure out what target architecture you require (i386 or x86_64) (http://tinyurl.com/i386vsx8464osx)
2. Double click on one of the command scripts for your chosen architecture (or the all which will build both into seperate folders)
3. Let the script download, compile and create the library for you.
3. Done


================================================================================

How to get working with a project in Xcode?
============

In Xcode Build Settings for your project*:
- Add to Library Search Paths: "$(SRCROOT)../../../addons/ofxOSXBoost/lib/" 
- Add to Header Search Paths: "$(SRCROOT)../../../addons/ofxOSXBoost/src"


In Xcode Build Phases*
- Add the libs in the addons/ofxOSXBoost/lib/ directory to Link Binary With Libraries

- Enjoy boost :)

* = Note for when using the 'boost-build-all.command' you will need to add the folder associated with the target architecture for your project to the library search paths (i.e. '...ofxOSXBoost/lib/i386') and also add those libs to the build phases.



Documentation on Boost 1.55.0
===========

See: http://www.boost.org/users/history/version_1_55_0.html