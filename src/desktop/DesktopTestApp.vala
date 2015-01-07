/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
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

/* DesktopTestApp.vala - Common code for building an ev3devKit desktop test app (GTK) */

using Curses;

namespace EV3devKit.DesktopTestApp {
    const string main_window_glade_file = "main_window.glade";

    DesktopScreen color_screen;
    public Gtk.Window main_window;

    public static void init (string[] args) {
        Gtk.init (ref args);
        GRX.set_driver ("memory nc 16M");
        GRX.set_mode (GRX.GraphicsMode.GRAPHICS_DEFAULT);

        var stock_lcd = new FakeEV3LCDDevice ();
        Screen.active_screen = new DesktopScreen (stock_lcd);

        var color_lcd = new FakeEV3LCDDevice (FakeEV3LCDDevice.DeviceType.ADAFRUIT_18);
        color_screen = new DesktopScreen (color_lcd, (DesktopScreen)Screen.active_screen);

        var builder = new Gtk.Builder ();
        Gtk.Box screen1_box;
        Gtk.Box screen2_box;
        try {
            builder.add_from_file (main_window_glade_file);
            main_window = builder.get_object ("main_window") as Gtk.Window;
            screen1_box = builder.get_object ("screen1_box") as Gtk.Box;
            screen2_box = builder.get_object ("screen2_box") as Gtk.Box;
            (builder.get_object ("screen1_copy_button") as Gtk.Button)
                .clicked.connect (() => color_lcd.copy_to_clipboard ());
            (builder.get_object ("screen2_copy_button") as Gtk.Button)
                .clicked.connect (() => stock_lcd.copy_to_clipboard ());
            (builder.get_object ("up_button") as Gtk.Button)
                .clicked.connect (() => Screen.active_screen.queue_key_code (Key.UP));
            (builder.get_object ("down_button") as Gtk.Button)
                .clicked.connect (() => Screen.active_screen.queue_key_code (Key.DOWN));
            (builder.get_object ("left_button") as Gtk.Button)
                .clicked.connect (() => Screen.active_screen.queue_key_code (Key.LEFT));
            (builder.get_object ("right_button") as Gtk.Button)
                .clicked.connect (() => Screen.active_screen.queue_key_code (Key.RIGHT));
            (builder.get_object ("enter_button") as Gtk.Button)
                .clicked.connect (() => Screen.active_screen.queue_key_code ('\n'));
            (builder.get_object ("back_button") as Gtk.Button)
                .clicked.connect (() => Screen.active_screen.queue_key_code (Key.BACKSPACE));
        } catch (Error err) {
            error ("%s", err.message);
        }

        builder.connect_signals (null);

        stock_lcd.key_press_event.connect ((event) => {
            uint key_code = 0;
            switch (event.keyval) {
            case Gdk.Key.Up:
                key_code = Key.UP;
                break;
            case Gdk.Key.Down:
                key_code = Key.DOWN;
                break;
            case Gdk.Key.Left:
                key_code = Key.LEFT;
                break;
            case Gdk.Key.Right:
                key_code = Key.RIGHT;
                break;
            case Gdk.Key.Return:
                key_code = '\n';
                break;
            case Gdk.Key.BackSpace:
                key_code = Key.BACKSPACE;
                break;
            case Gdk.Key.Delete:
                key_code = Key.DC; // DELETE
                break;
            default:
                if (event.keyval >= 32 && event.keyval < 127) {
                    key_code = event.keyval;
                    break;
                }
                return false;
            }
            Screen.active_screen.queue_key_code (key_code);
            return true;
        });
        color_lcd.key_press_event.connect ((event) => stock_lcd.key_press_event (event));

        screen1_box.pack_start (color_lcd);
        screen2_box.pack_start (stock_lcd);
        main_window.show_all ();
    }

    public void run () {
        Gtk.main ();
    }

    public void quit () {
        Gtk.main_quit ();
    }
}
