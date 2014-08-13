/*
 * ev3dev-tk - graphical toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * FakeEV3LCDDevice.vala:
 *
 * U8g.Device that simulates the EV3 LCD.
 */

using Gee;
using Gtk;
using GRX;

namespace EV3devTk {
    public class FakeEV3LCDDevice : Gtk.EventBox {
        public const uint16 WIDTH = 178;
        public const uint16 HEIGHT = 128;

        Gdk.Pixbuf pixbuf;
        Gtk.Image image;
        internal Color bg_color;
        internal char* pixbuf_data { get { return pixbuf.pixels; } }

        public FakeEV3LCDDevice () {
            can_focus = true;
            button_press_event.connect ((event) => {
                grab_focus ();
                return true;
            });
            image = new Gtk.Image.from_pixbuf(new Gdk.Pixbuf (
                Gdk.Colorspace.RGB, false, 8, WIDTH * 2, HEIGHT * 2));
            add (image);
            pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8, WIDTH, HEIGHT);
            bg_color = Color.alloc (195, 212, 202);
        }

        public void refresh () {
            image.set_from_pixbuf (pixbuf.scale_simple (WIDTH * 2, HEIGHT * 2, Gdk.InterpType.TILES));
        }
    }
}
