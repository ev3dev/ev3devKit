/*
 * ev3dev-tk - graphical toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* main.vala - main function for running demo on desktop */

using Curses;

namespace EV3devTk {

    errordomain DesktopDemoError {
        NULL
    }

    public static int main (string[] args) {
        const string main_window_glade_file = "main_window.glade";

        Gtk.init (ref args);

        var lcd = new FakeEV3LCDDevice ();
        var screen = new DesktopScreen (lcd);

        var builder = new Gtk.Builder ();
        Gtk.Window main_window;
        Gtk.Box main_box;
        try {
            builder.add_from_file (main_window_glade_file);
            main_window = builder.get_object ("main_window") as Gtk.Window;
            main_box = builder.get_object ("main_box") as Gtk.Box;
            (builder.get_object ("up_button") as Gtk.Button)
                .clicked.connect (() => screen.queue_key_code (Key.UP));
            (builder.get_object ("down_button") as Gtk.Button)
                .clicked.connect (() => screen.queue_key_code (Key.DOWN));
            (builder.get_object ("left_button") as Gtk.Button)
                .clicked.connect (() => screen.queue_key_code (Key.LEFT));
            (builder.get_object ("right_button") as Gtk.Button)
                .clicked.connect (() => screen.queue_key_code (Key.RIGHT));
            (builder.get_object ("enter_button") as Gtk.Button)
                .clicked.connect (() => screen.queue_key_code (Key.ENTER));
            (builder.get_object ("back_button") as Gtk.Button)
                .clicked.connect (() => screen.queue_key_code (Key.BACKSPACE));
        } catch (Error err) {
            error ("%s", err.message);
        }

        builder.connect_signals (null);

        var demo_window = new DemoWindow ();
        demo_window.quit.connect (Gtk.main_quit);
        screen.push_window (demo_window);

        main_box.pack_start (lcd);
        main_window.show_all ();
        Gtk.main ();

        return 0;
    }
}
