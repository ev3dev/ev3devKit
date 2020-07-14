# ev3devKit

Programming toolkit for ev3dev

## About

This is a [GLib]/[GObject] based library that provides a number of programming
interfaces for ev3dev, including user interface and device driver interface.
It is written in vala, but since it uses GObjects, it can be used with many
[languages] via [GObjectIntrospection].

For an example of how it is used, checkout [brickman].

## Status

This is currently in the development stages and is unstable.


## Get the code

This project uses git and git submodules.

    git clone --recursive git://github.com/ev3dev/ev3devKit


## Cross-compiling for the EV3

This requires that you have [Docker](https://www.docker.com) installed. (On
Linux, you will also need to install the `qemu-user-static` package.)

    cd ev3devKit
    ./docker/setup.sh $ARCH
    docker exec --tty ev3devkit_$ARCH make install

Substitute `$ARCH` with `armel` for the EV3 or `armhf` for RPi/BeagleBone.
When the build is completed, copy the files from `build-$ARCH/dist` to your EV3.


## Compiling for desktop

    # include install build depends
    $ sudo apt-get install cmake valac libgirepository1.0-dev \
    libgudev-1.0-dev libgrx-3.0-dev libgtk-3-dev
    $ cmake -P setup.cmake
    $ make -C build


## Running

When building for the desktop, one can run the demos using `make -C build run<tab>`. In
order to run them on the device, copy the demos over or share the folder via NFS
or sshfs with the EV3. When copying them to /home/user, the demos are runable
from the file-browser.

## Documentation
API docs are at http://docs.ev3dev.org/projects/ev3devkit/en/ev3dev-bullseye/

[GLib]: https://developer.gnome.org/glib/stable/index.html
[GObject]: https://developer.gnome.org/gobject/stable/index.html
[languages]: https://wiki.gnome.org/Projects/GObjectIntrospection/Users
[GObjectIntrospection]: https://wiki.gnome.org/Projects/GObjectIntrospection
[brickman]: https://github.com/ev3dev/brickman
[brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug

