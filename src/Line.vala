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

using U8g;

namespace EV3devTk {
    public enum LineDirection {
        HORIZONTAL,
        VERTICAL;
    }

    public class Line : EV3devTk.Widget {
        LineDirection direction;

        public ushort line_width { get; set; default = 1; }
        public ushort line_length { get; set; default = 10; }

        public override ushort preferred_width {
            get {
                if (direction == LineDirection.HORIZONTAL)
                    return line_length + base.preferred_width;
                return line_width + base.preferred_width;
            }
        }
        public override ushort preferred_height {
           get {
                if (direction == LineDirection.VERTICAL)
                    return line_length + base.preferred_height;
                return line_width + base.preferred_height;
            }
        }

        public Line (LineDirection direction = LineDirection.HORIZONTAL) {
            this.direction = direction;
            notify["line_width"].connect (redraw);
            notify["line_length"].connect (redraw);
        }

        protected override void on_draw (Graphics u8g) {
            u8g.set_default_foreground_color ();
            u8g.draw_box (content_x, content_y, content_width, content_height);
        }
    }
}
