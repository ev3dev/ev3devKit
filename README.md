ev3dev-lang-glib
================

This is a [GLib]/[GObject] based library for using sensors, motors and other
devices with ev3dev. It is written in vala, but since it uses GObjects, it can
be used with many [languages] via [GObjectIntrospection].

It is supposed to follow the [ev3dev-lang specification], but has deviated from
it slightly for now.

Status
------

* Works with kernel version 3.16.1-9-ev3dev-pre (unreleased) only.
* Currently there is no binary package, so you have to build from source.
* The API is not stable (which is the reason for no binary package yet).

Compiling the demo
------------------

*   First, you need to clone the source with git.

        git clone git://github.com/dlech/ev3dev-lang-glib
        
*   Setup brickstrap and run a brickstrap shell. See this [wiki page][brickstrap]
    for more information.

*   In the brickstrap shell install the build dependencies.

        sudo apt-get install cmake valac 
                
*   Then create a build directory that is **not** in the source directory that
    just you cloned. You can name the directory whatever you like - this is just
    an example.
  
        mkdir -p build-area/ev3dev-lang-glib-demo
        cd build-area/ev3dev-lang-glib-demo
        
*   In the build directory, run `cmake`. Change `../../ev3dev-lang-glib` to the
    path where you cloned the git repository if it is different than this
    example.

        cmake ../../ev3dev-lang-glib -DCMAKE_BUILD_TYPE=Debug -DEV3DEV_LANG_VALA_DEMO=1
        
* Finally, copy the `ev3dev-lang-glib-demo` binary to your EV3 and run it.


[GLib]: https://developer.gnome.org/glib/stable/index.html
[GObject]: https://developer.gnome.org/gobject/stable/index.html
[languages]: https://wiki.gnome.org/Projects/GObjectIntrospection/Users
[GObjectIntrospection]: https://wiki.gnome.org/Projects/GObjectIntrospection
[ev3dev-lang specification]: https://github.com/ev3dev/ev3dev-lang/blob/master/wrapper-specification.md
[brickstrap]: https://github.com/ev3dev/ev3dev/wiki/Using-brickstrap-to-cross-compile-and-debug