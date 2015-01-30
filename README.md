# ev3devKit

Programming toolkit for ev3dev

## About

This is a [GLib] based library that provides user interface widgets for ev3dev.
It is currently in the development stages and is unstable.

For an example of how it is used, checkout [brickman].

## Compiling

Since this is unstable, it is currently setup to compile as a static library.
To get something usable on the EV3 brick, you should compile using [brickstrap].

    # include install build depends
    $ sudo apt-get install cmake valac libgrx20-dev
    # clone the git repo
    $ git clone git://github.com/ev3dev/ev3devKit
    # create a build directory (not in cloned ev3devKit directory).
    $ mkdir build
    $ cd build
    $ cmake ../ev3devKit
    $ make
    
You can add additional build option to the `cmake` command. Note: you need to
delete *everything* in the build directory when changing `cmake` options to
ensure that they take effect.

* Enable debugging: `-DCMAKE_BUILD_TYPE=Debug`
* Build additional library for running on a desktop: `-DEV3DEVKIT_DESKTOP=1`
* Do not build the demo program: `-DEV3DEVKIT_NO_DEMO=1`

## Documentation
API docs are at http://www.ev3dev.org/ev3devKit/

[GLib]: https://developer.gnome.org/glib/2.40/
[brickman]: https://github.com/ev3dev/brickman
[brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug
