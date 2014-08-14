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

/* Line.vala - Widget to display a line */

using GRX;

namespace EV3devTk {
    public enum LineDirection {
        HORIZONTAL,
        VERTICAL;
    }

    public class Line : EV3devTk.Widget {
        LineDirection direction;

        public int line_width { get; set; default = 1; }
        public int line_length { get; set; default = 10; }

        Line (LineDirection direction) {
            this.direction = direction;
            notify["line_width"].connect (redraw);
            notify["line_length"].connect (redraw);
        }

        public Line.horizontal () {
            this (LineDirection.HORIZONTAL);
        }

        public Line.vertical () {
            this (LineDirection.VERTICAL);
        }

        public override int get_preferred_width () {
            if (direction == LineDirection.HORIZONTAL)
                return line_length + get_margin_border_padding_width ();
            return line_width + get_margin_border_padding_width ();
        }
        public override int get_preferred_height () {
            if (direction == LineDirection.VERTICAL)
                return line_length + get_margin_border_padding_height ();
            return line_width + get_margin_border_padding_height ();
        }

        protected override void on_draw (Context context) {
            Color color = window.screen.fg_color;
            filled_box (content_bounds.x1, content_bounds.y1, content_bounds.x2,
                content_bounds.y2, color);
        }
    }
}
