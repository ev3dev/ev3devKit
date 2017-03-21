/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014,2016 David Lechner <david@lechnology.com>
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

using Grx;

namespace Ev3devKit.Ui {
    /**
     * A dialog window for displaying pop-up messages.
     *
     * Unlike a regular Window, a Dialog does not take up the full screen area.
     * Instead, it displays a smaller area with the previous window partially
     * visible behind it.
     */
    public class Dialog : Ev3devKit.Ui.Window {

        construct {
            border = 1;
            border_radius = 10;
            notify["screen"].connect (set_margin);
        }

        /**
         * Creates a new instance of a dialog window.
         */
        public Dialog () {
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            set_bounds (0, 0, screen.width - 1, screen.height - 1);
            foreach (var child in _children)
                set_child_bounds (child, content_bounds.x1, content_bounds.y1,
                    content_bounds.x2, content_bounds.y2);
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_background () {
            var color = screen.bg_color;
            draw_filled_rounded_box (border_bounds.x1, border_bounds.y1,
                border_bounds.x2, border_bounds.y2, border_radius, color);
        }

        void set_margin () {
            if (screen == null) {
                    return;
                }
                margin = int.min (screen.width, screen.height) / 15;
        }
    }
}
