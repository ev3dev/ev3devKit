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

/* DesktopScreen.vala - Screen implementation for desktop (Gtk) */

using Gee;
using GRX;

namespace EV3devKit {
    public class DesktopScreen : EV3devKit.Screen {
        FakeEV3LCDDevice lcd;
        weak DesktopScreen? master;
        Gee.List<weak DesktopScreen> slaves;

        public DesktopScreen (FakeEV3LCDDevice lcd, DesktopScreen? master = null) {
            base.custom (lcd.info.width, lcd.info.height, lcd.pixbuf_data);
            this.lcd = lcd;
            if (lcd.info.use_custom_colors) {
                fg_color = lcd.info.fg_color;
                bg_color = lcd.info.bg_color;
                mid_color = lcd.info.mid_color;
            }
            this.master = master;
            slaves = new ArrayList<DesktopScreen> ();
            if (master != null) {
                master.slaves.add (this);
            }
        }

        ~DesktopScreen () {
            master.slaves.remove (this);
            foreach (var slave in slaves) {
                slave.master = null;
            }
        }

        public override void refresh () {
            lcd.refresh ();
            foreach (var slave in slaves) {
                set_screen_for_each_window (slave);
                var save_slave_window_stack = slave.window_stack;
                slave.window_stack = window_stack;
                slave.dirty = true;
                slave.on_draw_timeout ();
                slave.window_stack = save_slave_window_stack;
            }
            set_screen_for_each_window (this);
        }

        void set_screen_for_each_window (Screen screen) {
            foreach (var window in window_stack) {
                window._screen = screen;
            }
        }
    }
}
