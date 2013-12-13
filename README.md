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

In Xcode Build Settings for your project:

For i386:
- Add to Library Search Paths: "$(SRCROOT)/../../../addons/ofxOSXBoost/libs/boost/lib/osx_i386/" 
For x86_64:
- Add to Library Search Paths: "$(SRCROOT)/../../../addons/ofxOSXBoost/libs/boost/lib/osx_x86_64/" 

Both:
- Add to Header Search Paths: "$(SRCROOT)/../../../addons/ofxOSXBoost/libs/boost/include"


In Xcode Build Phases*
- Add the libs in the addons/ofxOSXBoost/libs/boost/lib/osx_x86_64/ or addons/ofxOSXBoost/libs/boost/lib/osx_i386/ directory to Link Binary With Libraries

- Enjoy boost :)




Documentation on Boost 1.55.0
===========

See: http://www.boost.org/users/history/version_1_55_0.html