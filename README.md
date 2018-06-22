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
and libgrx which is part of the ev3dev package repository.


## Get the code

This project uses git and git submodules.

    git clone --recursive git://github.com/ev3dev/ev3devKit


## Cross-compiling for the EV3

This requires that you have [Docker](https://www.docker.com) installed.

    cd ev3devKit
    ./docker/setup.sh $BUILD_DIR $ARCH
    docker exec --tty ev3devkit_$ARCH make install

Substitute any directory you like for `$BUILD_DIR` this is where the compiled
files will be stored. The directory will be created if it does not exist.
Substitute `$ARCH` with `armel` for the EV3 or `armhf` for RPi/BeagleBone.
When the build is completed, copy the files from `$BUILD_DIR/dist` to your EV3.


## Compiling for desktop

    # include install build depends
    $ sudo apt-get install cmake valac libgirepository1.0-dev \
    libgudev-1.0-dev libgrx-3.0-dev libgtk-3-dev
    # create a build directory (not in cloned ev3devKit directory).
    $ mkdir build
    $ cd build
    $ cmake ../ev3devKit -DCMAKE_BUILD_TYPE=string:Debug
    $ make
    
You can add additional build option to the `cmake` command. Note: you need to
delete *everything* in the build directory when changing `cmake` options to
ensure that they take effect.


## Running

When building for the desktop, one can run the demos using `make run<tab>`. In
order to run them on the device, copy the demos over or share the folder via NFS
or sshfs with the EV3. When copying them to /home/user, the demos are runable
from the file-browser.

## Documentation
API docs are at http://docs.ev3dev.org/projects/ev3devkit/en/ev3dev-stretch/

[GLib]: https://developer.gnome.org/glib/stable/index.html
[GObject]: https://developer.gnome.org/gobject/stable/index.html
[languages]: https://wiki.gnome.org/Projects/GObjectIntrospection/Users
[GObjectIntrospection]: https://wiki.gnome.org/Projects/GObjectIntrospection
[brickman]: https://github.com/ev3dev/brickman
[brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug

