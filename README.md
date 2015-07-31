# ev3devKit

Programming toolkit for ev3dev

## About

This is a [GLib]/[GObject] based library that provides a number of programming
interfaces for ev3dev, including user interface and device driver interface.
It is written in vala, but since it uses GObjects, it can be used with many
[languages] via [GObjectIntrospection].

For an example of how it is used, checkout [brickman].

## Status

This is currently in the development stages and is unstable. The device driver
interfaces require the latest ev3dev kernel (currently v3.16.7-ckt4-ev3dev1).

## Dependencies

Besides dependencies included in trusty, we need vala >= 0.24, which you can get
from the [vala-team PPA](https://launchpad.net/~vala-team/+archive/ubuntu/ppa),
and libgrx which is part of ev3dev repository.

## Compiling

To get something usable on the EV3 brick, you should compile using [brickstrap].

    # include install build depends
    $ sudo apt-get install cmake valac libgee-0.8-dev libgirepository1.0-dev \
    libgudev-1.0-dev libncurses5-dev libgrx-dev
    # if you are building for desktop (see below) you also need
    $ sudo apt-get install libgtk-3-dev
    # clone the git repo
    $ git clone --recursive git://github.com/ev3dev/ev3devKit
    # create a build directory (not in cloned ev3devKit directory).
    $ mkdir build
    $ cd build
    $ cmake ../ev3devKit
    $ make
    
You can add additional build option to the `cmake` command. Note: you need to
delete *everything* in the build directory when changing `cmake` options to
ensure that they take effect (you can use `nuke.sh` to do this).

* Enable debugging: `-DCMAKE_BUILD_TYPE=string:Debug`
* Build additional library for running on a desktop: `-DEV3DEVKIT_DESKTOP=bool:Yes`
* Do not build the demo programs: `-DEV3DEVKIT_NO_DEMO=bool:Yes`

## Running

When building for the desktop, one can run the demos using `make run<tab>`. In
order to run them on the device, copy the demos over or share the folder via NFS
or sshfs with the EV3. When copying them to /home/user, the demos are runable
from the file-browser.

## Documentation
API docs are at http://www.ev3dev.org/ev3devKit/ev3devkit/index.htm

[GLib]: https://developer.gnome.org/glib/stable/index.html
[GObject]: https://developer.gnome.org/gobject/stable/index.html
[languages]: https://wiki.gnome.org/Projects/GObjectIntrospection/Users
[GObjectIntrospection]: https://wiki.gnome.org/Projects/GObjectIntrospection
[brickman]: https://github.com/ev3dev/brickman
[brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug

