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

/* DesktopScreen.vala - Screen implementation for desktop (Gtk) */

using Curses;
using GRX;

namespace EV3devTk {
    public class DesktopScreen : EV3devTk.Screen {
        FakeEV3LCDDevice lcd;

        public DesktopScreen (FakeEV3LCDDevice lcd) {
            base (lcd.info.width, lcd.info.height, lcd.pixbuf_data);
            this.lcd = lcd;
            if (lcd.info.use_custom_colors) {
                fg_color = lcd.info.fg_color;
                bg_color = lcd.info.bg_color;
                mid_color = lcd.info.mid_color;
            }
        }

        public override void refresh () {
            lcd.refresh ();
        }
    }
}
