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

/* TabButton.vala - Button used for notebook tabs */

using Curses;
using Gee;
using GRX;

namespace EV3devKit.UI {
    /**
     * Button used for the tab of a {@link NotebookTab}.
     */
    public class TabButton : EV3devKit.UI.Button {
        /**
         * Gets the active state of this tab.
         *
         * The "active" tab is the currently selected/displayed tab.
         */
        public bool active { get; internal set; }

        /**
         * Creates a new tab button.
         */
        public TabButton (string? text = null) {
            base (new Label (text));
            border_radius = 3;
            notify["active"].connect_after (() => {
                can_focus = !active;
                if (has_focus)
                    focus_next (FocusDirection.RIGHT);
                redraw ();
            });
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_background () {
            if (draw_children_as_focused) {
                var color = window.screen.mid_color;
                filled_box (border_bounds.x1, border_bounds.y2 - border_radius,
                    border_bounds.x2, border_bounds.y2, color);
            }
            base.draw_background ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_border (GRX.Color color = window.screen.fg_color) {
            if (border_top != 0)
                filled_box (border_bounds.x1 + border_radius, border_bounds.y1,
                    border_bounds.x2 - border_radius,
                    border_bounds.y1 + border_top - 1, color);
            if (border_bottom != 0 && !_active)
                filled_box (border_bounds.x1,
                    border_bounds.y2 - border_bottom + 1,
                    border_bounds.x2 , border_bounds.y2, color);
            if (border_left != 0)
                filled_box (border_bounds.x1, border_bounds.y1 + border_radius,
                    border_bounds.x1 + border_left- 1,
                    border_bounds.y2, color);
            if (border_right != 0)
                filled_box (border_bounds.x2 - border_left + 1,
                    border_bounds.y1 + border_radius, border_bounds.x2,
                    border_bounds.y2, color);
            if (border_radius != 0) {
                circle_arc (border_bounds.x2 - border_radius,
                    border_bounds.y1 + border_radius, border_radius, 0, 900,
                    ArcStyle.OPEN, color);
                circle_arc (border_bounds.x1 + border_radius,
                    border_bounds.y1 + border_radius, border_radius, 900, 1800,
                    ArcStyle.OPEN, color);
            }
        }
    }
}
