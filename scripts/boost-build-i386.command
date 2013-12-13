#===============================================================================
# Filename:  boost.sh
# Author:    Pete Goodliffe, Daniel Rosser
# Copyright: (c) Copyright 2009 Pete Goodliffe, (c) Copyright 2013 Daniel Rosser
# Licence:   Please feel free to use this, with attribution
# Modified version
#===============================================================================
#
# Builds a Boost framework for OSX
# Creates a set of universal libraries that can be used on an OSX
#
# To configure the script, define:
#    BOOST_LIBS:        which libraries to build
#    OSX_SDKVERSION:    OSX SDK Version. I.E. 10.8
#
# Then go get the source tar.bz of the boost you want to build, shove it in the
# same directory as this script, and run "./boost.sh". Grab a cuppa. And voila.
#===============================================================================

#!/bin/sh
# make sure when running the .command we are in the current directory
here="`dirname \"$0\"`"
echo "cd-ing to $here"
cd "$here" || exit 1

: ${BOOST_LIBS:="random regex graph random chrono thread signals filesystem system date_time"}
: ${OSX_SDKVERSION:=10.8}
: ${XCODE_ROOT:=`xcode-select -print-path`}
: ${EXTRA_CPPFLAGS:="-DBOOST_AC_USE_PTHREADS -DBOOST_SP_USE_PTHREADS -std=c++11 -stdlib=libc++"}

# The EXTRA_CPPFLAGS definition works around a thread race issue in
# shared_ptr. I encountered this historically and have not verified that
# the fix is no longer required. Without using the posix thread primitives
# an invalid compare-and-swap ARM instruction (non-thread-safe) was used for the
# shared_ptr use count causing nasty and subtle bugs.
#
# Should perhaps also consider/use instead: -BOOST_SP_USE_PTHREADS

: ${TARBALLDIR:=`pwd`/..}
: ${SRCDIR:=`pwd`/../temp/src}
: ${OSXBUILDDIR:=`pwd`/../libs/boost/lib}
: ${PREFIXDIR:=`pwd`/../temp/prefix}
: ${OSXINCLUDEDIR:=`pwd`/../libs/boost/include/boost}
: ${COMPILER:="clang++"}
: ${BOOST_VERSION:=1.55.0}
: ${BOOST_VERSION2:=1_55_0}

BOOST_TARBALL=$TARBALLDIR/boost_$BOOST_VERSION2.tar.bz2
BOOST_SRC=$SRCDIR/boost_${BOOST_VERSION2}
BOOST_INCLUDE=$BOOST_SRC/boost

#===============================================================================
OSX_DEV_CMD="xcrun --sdk macosx"

#===============================================================================


#===============================================================================
# Functions
#===============================================================================

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

doneSection()
{
    echo
    echo "================================================================="
    echo "Done"
    echo
}

#===============================================================================

cleanEverythingReadyToStart()
{
    echo Cleaning everything before we start to build...

    rm -rf osx-build
    rm -rf $OSXBUILDDIR
    rm -rf $OSXINCLUDEDIR
    rm -rf $OSXBUILDDIR/osx_i386/obj
 #   rm -rf $OSXBUILDDIR/osx_x86_64/obj
    rm -rf $SRCDIR
    rm -rf $TARBALLDIR/temp
 #   rm -f $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2

    doneSection
}

postcleanEverything()
{
    echo Cleaning everything after the build...

    rm -rf osx-build
    rm -rf $OSXBUILDDIR/osx_i386/obj
#    rm -rf $OSXBUILDDIR/x86_64/obj
    rm -rf $SRCDIR
    rm -rf $TARBALLDIR/temp
    rm -f $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2
    doneSection
}

#===============================================================================

downloadBoost()
{
    if [ ! -s $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2 ]; then
        echo "Downloading boost ${BOOST_VERSION}"
        curl -L -o $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2 http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION2}.tar.bz2/download
    fi

    doneSection
}

#===============================================================================

unpackBoost()
{
    [ -f "$BOOST_TARBALL" ] || abort "Source tarball missing."

    echo Unpacking boost into $SRCDIR...

    [ -d $SRCDIR ]    || mkdir -p $SRCDIR
    [ -d $BOOST_SRC ] || ( cd $SRCDIR; tar xfj $BOOST_TARBALL )
    [ -d $BOOST_SRC ] && echo "    ...unpacked as $BOOST_SRC"

    doneSection
}

#===============================================================================

restoreBoost()
{
    echo "Attempt to restore boost"
    cp $BOOST_SRC/tools/build/v2/user-config.jam-bk $BOOST_SRC/tools/build/v2/user-config.jam
}

#===============================================================================

updateBoost()
{
    echo Updating boost into $BOOST_SRC...

    cp $BOOST_SRC/tools/build/v2/user-config.jam $BOOST_SRC/tools/build/v2/user-config.jam-bk


    doneSection
}

#===============================================================================

bootstrapBoost()
{
    cd $BOOST_SRC

    BOOST_LIBS_COMMA=$(echo $BOOST_LIBS | sed -e "s/ /,/g")
    echo "Bootstrapping (with libs $BOOST_LIBS_COMMA)"
    ./bootstrap.sh --with-libraries=$BOOST_LIBS_COMMA

    doneSection
}

#===============================================================================

buildBoostForOSX()
{
    cd $BOOST_SRC

    ./b2 -j16 --build-dir=osx-build --stagedir=osx-build/stage --prefix=$PREFIXDIR toolset=clang cxxflags="-std=c++11 -stdlib=libc++ -arch i386 -arch x86_64" linkflags="-stdlib=libc++" link=static threading=multi stage
    ./b2 -j16 --build-dir=osx-build --stagedir=osx-build/stage --prefix=$PREFIXDIR toolset=clang cxxflags="-std=c++11 -stdlib=libc++ -arch i386 -arch x86_64" linkflags="-stdlib=libc++" link=static threading=multi install
    doneSection
}

#===============================================================================
buildIncludes()
{
    
    echo "Copying includes..."
    mkdir -p $OSXINCLUDEDIR
    #cp -r $BOOST_INCLUDE/*  $OSXINCLUDEDIR/
    cp -r $PREFIXDIR/include/boost/* $OSXINCLUDEDIR/

    doneSection
}

#===============================================================================

scrunchAllLibsTogetherInOneLibPerPlatform()
{
    cd $BOOST_SRC

    mkdir -p $OSXBUILDDIR/osx_i386/obj

    ALL_LIBS=""

    echo Splitting all existing fat binaries...

    for NAME in $BOOST_LIBS; do
        ALL_LIBS="$ALL_LIBS libboost_$NAME.a"

        $ARM_DEV_CMD lipo "osx-build/stage/lib/libboost_$NAME.a" -thin i386 -o $OSXBUILDDIR/osx_i386/libboost_$NAME.a
    done

    echo "Decomposing each architecture's .a files"

    for NAME in $ALL_LIBS; do
        echo Decomposing $NAME...

        (cd $OSXBUILDDIR/osx_i386/obj; ar -x ../$NAME );
#        (cd $OSXBUILDDIR/x86_64/obj; ar -x ../$NAME );
    done

    echo "Linking each architecture into an uberlib ($ALL_LIBS => libboost.a )"

 
    echo ...osx-i386
    (cd $OSXBUILDDIR/osx_i386/;  $SIM_DEV_CMD ar crus libboost.a obj/*.o; )

#    echo ...x86_64
#    (cd $OSXBUILDDIR/x86_64;  $SIM_DEV_CMD ar crus libboost.a obj/*.o; )
}

#===============================================================================


#===============================================================================
# Execution starts here
#===============================================================================

cleanEverythingReadyToStart #may want to comment if repeatedly running during dev
mkdir -p $OSXBUILDDIR
restoreBoost

echo "BOOST_VERSION:     $BOOST_VERSION"
echo "BOOST_LIBS:        $BOOST_LIBS"
echo "BOOST_SRC:         $BOOST_SRC"
echo "OSXBUILDDIR:       $OSXBUILDDIR"
echo "OSXINCLUDEDIR:     $OSXINCLUDEDIR"
echo "BOOST_INCLUDE:     $BOOST_INCLUDE"
echo "XCODE_ROOT:        $XCODE_ROOT"
echo "COMPILER:          $COMPILER"
echo

downloadBoost
unpackBoost
#inventMissingHeaders
bootstrapBoost
updateBoost
buildBoostForOSX
scrunchAllLibsTogetherInOneLibPerPlatform
buildIncludes

restoreBoost

postcleanEverything

echo "Completed successfully"

#===============================================================================
