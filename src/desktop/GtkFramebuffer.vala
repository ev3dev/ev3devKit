/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * GtkFramebuffer.vala:
 *
 * Simulates a framebuffer device using a Gtk.Image in a Gtk.EventBox.
 */

using Gtk;
using Grx;

namespace Ev3devKitDesktop {
    public class GtkFramebuffer : Gtk.EventBox {
        public struct Info {
            public int width;
            public int height;
            public bool monochrome;
        }

        public enum DeviceType {
            EV3,
            ADAFRUIT_18,
            ADAFRUIT_22,
            ADAFRUIT_24,
        }

        const Info[] devices = {
            { 178, 128, true  }, /* EV3 LCD 178x128, 1bpp MONO01 */
            { 160, 128, false }, /* Adafruit 1.8" LCD 160x128, 16bpp RGB565 */
            { 220, 176, false }, /* Adafruit 2.2" LCD 220x176, 16bpp RGB565 (EVB)*/
            { 320, 240, false }, /* Adafruit 2.4" LCD 320x240, 16bpp RGB565 (PiStorms) */
        };

        const int LCD_BG_RED   = 173;
        const int LCD_BG_GREEN = 181;
        const int LCD_BG_BLUE  = 120;
        const int LCD_BG_RGB   = (LCD_BG_RED << 16) + (LCD_BG_GREEN << 8) + LCD_BG_BLUE;

        Gdk.Pixbuf pixbuf;
        Gtk.Image image;
        internal char* pixbuf_data { get { return pixbuf.pixels; } }

        public Info info { get; construct; default = devices[0]; }

        int _scale;
        public int scale {
            get { return _scale; }
            set {
                if (image != null)
                    image.destroy ();
                _scale = value;
                image = new Gtk.Image.from_pixbuf(new Gdk.Pixbuf (
                    Gdk.Colorspace.RGB, false, 8, info.width * value, info.height * value));
                if (info.monochrome) {
                    // Set the background color to look like the LED on the EV3.
                    image.override_background_color (StateFlags.NORMAL, Gdk.RGBA () {
                        red   = LCD_BG_RED   / 256.0,
                        green = LCD_BG_GREEN / 256.0,
                        blue  = LCD_BG_BLUE  / 256.0,
                        alpha = 1.0
                    });
                }
                image.show ();
                child = image;
                var window = get_toplevel () as Window;
                if (window != null)
                    window.resize (1, 1);
                refresh ();
            }
        }

        static construct {
            Grx.set_driver ("memory nc 16M");
            Grx.set_mode (Grx.GraphicsMode.GRAPHICS_DEFAULT);
        }

        construct {
            can_focus = true;
            button_press_event.connect ((event) => {
                grab_focus ();
                return true;
            });
            pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8, info.width, info.height);
            scale = 1; // initializes image
        }

        public GtkFramebuffer (DeviceType type = DeviceType.EV3) {
            // have to use variable here to make valadoc happy.
            int index = (int)type;
            Object (info: devices[index]);
        }

        public void refresh () {
            Gdk.Pixbuf p = pixbuf;
            if (info.monochrome) {
                // make white transparent so that the "LCD color" will show through.
                p = p.add_alpha (true, 255, 255, 255);
            }
            image.set_from_pixbuf (p.scale_simple (info.width * scale,
                info.height * scale, Gdk.InterpType.TILES));
        }

        public void copy_to_clipboard () {
            Gdk.Pixbuf p = pixbuf;
            if (info.monochrome) {
                // make white transparent so that the "LCD color" will show through.
                p = p.add_alpha (true, 255, 255, 255);
                // in this case, we have to supply the background ourselves
                p = p.composite_color_simple (p.width, p.height, Gdk.InterpType.TILES,
                    255, 4096, LCD_BG_RGB, LCD_BG_RGB);
            }
            var display = get_display ();
            var clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
            clipboard.set_image (p.scale_simple (info.width * scale,
                info.height * scale, Gdk.InterpType.TILES));
        }
    }
}
