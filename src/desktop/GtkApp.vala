/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* GtkApp.vala - Common code for building an ev3devKit desktop test app (GTK) */

using Curses;
using Ev3devKit;

/**
 * A framework for developing and testing {@link Ev3devKit.Ui} components in a
 * desktop environment.
 */
namespace EV3devKitDesktop {
    /**
     * Does all of the low level setting up of a desktop application so you
     * don't have to.
     *
     * To use it, your main function should look something like this:
     * {{{
     * using EV3devKitDesktop;
     *
     * static int main (string[] args) {
     *     GtkApp.init (args);
     *
     *     // Program-specific initialization which includes something
     *     // that calls GtkApp.quit () when the program is finished.
     *
     *     GtkApp.run ();
     *
     *     // any additional cleanup if needed before application exits.
     *
     *     return 0;
     * }
     * }}}
     */
    namespace GtkApp {
        const string main_window_glade_file = "main_window.glade";

        GtkScreen color_screen;

        /**
         * The GTK window created by {@link init}.
         */
        public Gtk.Window main_window;

        /**
         * Initialize a GTK application.
         *
         * This creates a GTK window that can be accessed using {@link main_window}
         * and an {@link Ev3devKit.Ui.Screen} that can be accessed using
         * {@link Ev3devKit.Ui.Screen.get_active_screen}.
         *
         * @param args The args from the programs main function.
         */
        public static void init (string[] args) {
            Gtk.init (ref args);
            Grx.set_driver ("memory nc 16M");
            Grx.set_mode (Grx.GraphicsMode.GRAPHICS_DEFAULT);

            var stock_lcd = new GtkFramebuffer ();
            Ui.Screen.set_active_screen (new GtkScreen (stock_lcd));

            var color_lcd = new GtkFramebuffer (GtkFramebuffer.DeviceType.ADAFRUIT_18);
            color_screen = new GtkScreen (color_lcd, (GtkScreen)Ui.Screen.get_active_screen ());

            var builder = new Gtk.Builder ();
            Gtk.Box screen1_box;
            Gtk.Box screen2_box;
            try {
                builder.add_from_file (main_window_glade_file);
                main_window = builder.get_object ("main-window") as Gtk.Window;
                screen1_box = builder.get_object ("screen1-box") as Gtk.Box;
                screen2_box = builder.get_object ("screen2-box") as Gtk.Box;
                (builder.get_object ("screen1-copy-button") as Gtk.Button)
                    .clicked.connect (() => color_lcd.copy_to_clipboard ());
                (builder.get_object ("screen2-copy-button") as Gtk.Button)
                    .clicked.connect (() => stock_lcd.copy_to_clipboard ());
                (builder.get_object ("up-button") as Gtk.Button)
                    .clicked.connect (() => Ui.Screen.get_active_screen ().queue_key_code (Key.UP));
                (builder.get_object ("down-button") as Gtk.Button)
                    .clicked.connect (() => Ui.Screen.get_active_screen ().queue_key_code (Key.DOWN));
                (builder.get_object ("left-button") as Gtk.Button)
                    .clicked.connect (() => Ui.Screen.get_active_screen ().queue_key_code (Key.LEFT));
                (builder.get_object ("right-button") as Gtk.Button)
                    .clicked.connect (() => Ui.Screen.get_active_screen ().queue_key_code (Key.RIGHT));
                (builder.get_object ("enter-button") as Gtk.Button)
                    .clicked.connect (() => Ui.Screen.get_active_screen ().queue_key_code ('\n'));
                (builder.get_object ("back-button") as Gtk.Button)
                    .clicked.connect (() => Ui.Screen.get_active_screen ().queue_key_code (Key.BACKSPACE));
                (builder.get_object ("scale-spinbutton") as Gtk.SpinButton)
                    .bind_property ("value", stock_lcd, "scale", BindingFlags.SYNC_CREATE);
                (builder.get_object ("scale-spinbutton") as Gtk.SpinButton)
                    .bind_property ("value", color_lcd, "scale", BindingFlags.SYNC_CREATE);
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
                Ui.Screen.get_active_screen ().queue_key_code (key_code);
                return true;
            });
            color_lcd.key_press_event.connect ((event) => stock_lcd.key_press_event (event));

            screen1_box.pack_start (color_lcd);
            screen2_box.pack_start (stock_lcd);
            main_window.show_all ();
        }

        /**
         * Start the main loop.
         */
        public void run () {
            Gtk.main ();
        }

        /**
         * Terminate the main loop.
         */
        public void quit () {
            Gtk.main_quit ();
        }
    }
}
