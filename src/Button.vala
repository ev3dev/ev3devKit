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

/* Button.vala - Widget that represents a selectable button */

using Curses;
using Gee;
using GRX;

namespace EV3devTk {

    public enum ButtonBorder {
        BOX,
        NONE;
    }

    public class Button : EV3devTk.Container {
        public ButtonBorder border { get; set; default = ButtonBorder.BOX; }

        public override int preferred_width {
            get {
                return base.preferred_width
                    + (child == null ? 0 : child.preferred_width);
            }
        }
        public override int preferred_height {
            get {
                return base.preferred_height
                    + (child == null ? 0 : child.preferred_height);
            }
        }

        public override int border_top {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }
        public override int border_bottom {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }
        public override int border_left {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }
        public override int border_right {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }

        public signal void pressed ();

        public Button (Widget? child = null) {
            base (ContainerType.SINGLE);
            if (child != null)
                add (child);
            notify["border"].connect (redraw);
            padding_top = 2;
            padding_bottom = 2;
            padding_left = 2;
            padding_right = 2;
            can_focus = true;
        }

        public Button.with_label (string? text = null) {
            this (new Label (text));
        }

        protected override void on_draw (Context context) {
            unowned GRX.Color color;
            if (has_focus) {
                color = window.screen.mid_color;
                filled_box (border_x, border_y, border_x + border_width - 1, border_y + border_height - 1, color);
            }
            if (border == ButtonBorder.BOX) {
                color = window.screen.fg_color;
                box (border_x, border_y, border_x + border_width - 1, border_y + border_height - 1, color);
            }
            base.on_draw (context);
        }

        protected override bool on_key_pressed (uint key_code) {
            if (key_code == '\n') {
                pressed ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return base.on_key_pressed (key_code);
        }
    }
}
