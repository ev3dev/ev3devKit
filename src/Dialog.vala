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

/* Dialog.vala - Top level widget */

using Curses;
using GRX;

namespace EV3devKit {
    public class Dialog : EV3devKit.Window {
        
        public Dialog () {
            margin = 12;
            border = 1;
            border_radius = 10;
        }

        protected override void draw_background () {
            var color = screen.bg_color;
            filled_rounded_box (border_bounds.x1, border_bounds.y1,
                border_bounds.x2, border_bounds.y2, 10, color);
        }
    }
}
