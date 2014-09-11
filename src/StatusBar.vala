/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
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
 * StatusBar.vala - statusbar that can be displayed at the top of a screen
 */

using Gee;
using GRX;

namespace EV3devKit {
    public class StatusBar : Object {
        public const int HEIGHT = 12;
        const int PADDING = 2;

        internal weak Screen? screen;
        ArrayList<StatusBarItem> left_items;
        ArrayList<StatusBarItem> right_items;

        public bool visible { get; set; default = true; }

        public void redraw () {
            if (_visible && screen != null)
                screen.dirty = true;
        }

        public void draw () {
            filled_box (0, 0, screen.width - 1, HEIGHT - 1, screen.bg_color);
            var x = 0;
            foreach (var item in left_items) {
                if (item.visible)
                    x += item.draw (x, Align.LEFT) + PADDING;
            }
            x = screen.width - 1;
            foreach (var item in right_items) {
                if (item.visible)
                    x -= item.draw (x, Align.RIGHT) + PADDING;
            }
            line (0, HEIGHT - 1, screen.width - 1, HEIGHT - 1, screen.fg_color);
        }

        public void add_left (StatusBarItem item) {
            left_items.add (item);
            item.status_bar = this;
        }

        public void add_right (StatusBarItem item) {
            right_items.add (item);
            item.status_bar = this;
        }

        public StatusBar () {
            left_items = new ArrayList<StatusBarItem> ();
            right_items = new ArrayList<StatusBarItem> ();
        }

        public enum Align {
            LEFT, RIGHT
        }
    }
}
