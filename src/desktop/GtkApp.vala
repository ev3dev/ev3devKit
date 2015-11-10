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
namespace Ev3devKitDesktop {
    /**
     * Does all of the low level setting up of a desktop application so you
     * don't have to.
     *
     * To use it, your main function should look something like this:
     * {{{
     * using Ev3devKitDesktop;
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
        GtkScreen adafruit18_screen;
        GtkScreen adafruit24_screen;
        GtkScreen evb_screen;

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

            var ev3_lcd = new GtkFramebuffer ();
            Ui.Screen.set_active_screen (new GtkScreen (ev3_lcd));

            var adafruit18_lcd = new GtkFramebuffer (GtkFramebuffer.DeviceType.ADAFRUIT_18);
            adafruit18_screen = new GtkScreen (adafruit18_lcd, (GtkScreen)Ui.Screen.get_active_screen ());
            var adafruit24_lcd = new GtkFramebuffer (GtkFramebuffer.DeviceType.ADAFRUIT_24);
            adafruit24_screen = new GtkScreen (adafruit24_lcd, (GtkScreen)Ui.Screen.get_active_screen ());
            var evb_lcd = new GtkFramebuffer (GtkFramebuffer.DeviceType.EVB);
            evb_screen = new GtkScreen (evb_lcd, (GtkScreen)Ui.Screen.get_active_screen ());

            Gtk.Box ev3_screen_box;
            Gtk.Box adafruit18_screen_box;
            Gtk.Box adafruit24_screen_box;
            Gtk.Box evb_screen_box;

            var builder = new Gtk.Builder ();
            try {
                builder.add_from_string (main_window_glade, -1);
                main_window = builder.get_object ("main-window") as Gtk.Window;
                ev3_screen_box = builder.get_object ("ev3-screen-box") as Gtk.Box;
                adafruit18_screen_box = builder.get_object ("adafruit18-screen-box") as Gtk.Box;
                adafruit24_screen_box = builder.get_object ("adafruit24-screen-box") as Gtk.Box;
                evb_screen_box = builder.get_object ("evb-screen-box") as Gtk.Box;
                (builder.get_object ("ev3-screen-copy-button") as Gtk.Button)
                    .clicked.connect (() => ev3_lcd.copy_to_clipboard ());
                (builder.get_object ("adafruit18-screen-copy-button") as Gtk.Button)
                    .clicked.connect (() => adafruit18_lcd.copy_to_clipboard ());
                (builder.get_object ("adafruit24-screen-copy-button") as Gtk.Button)
                    .clicked.connect (() => adafruit24_lcd.copy_to_clipboard ());
                (builder.get_object ("evb-screen-copy-button") as Gtk.Button)
                    .clicked.connect (() => evb_lcd.copy_to_clipboard ());
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
                    .bind_property ("value", ev3_lcd, "scale", BindingFlags.SYNC_CREATE);
                (builder.get_object ("scale-spinbutton") as Gtk.SpinButton)
                    .bind_property ("value", adafruit18_lcd, "scale", BindingFlags.SYNC_CREATE);
                (builder.get_object ("scale-spinbutton") as Gtk.SpinButton)
                    .bind_property ("value", adafruit24_lcd, "scale", BindingFlags.SYNC_CREATE);
                (builder.get_object ("scale-spinbutton") as Gtk.SpinButton)
                    .bind_property ("value", evb_lcd, "scale", BindingFlags.SYNC_CREATE);
            } catch (Error err) {
                error ("%s", err.message);
            }

            builder.connect_signals (null);

            ev3_lcd.key_press_event.connect ((event) => {
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
            adafruit18_lcd.key_press_event.connect ((event) => ev3_lcd.key_press_event (event));
            adafruit24_lcd.key_press_event.connect ((event) => ev3_lcd.key_press_event (event));
            evb_lcd.key_press_event.connect ((event) => ev3_lcd.key_press_event (event));

            ev3_screen_box.pack_start (ev3_lcd);
            adafruit18_screen_box.pack_start (adafruit18_lcd);
            adafruit24_screen_box.pack_start (adafruit24_lcd);
            evb_screen_box.pack_start (evb_lcd);

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
