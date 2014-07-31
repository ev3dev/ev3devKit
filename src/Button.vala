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
using U8g;

namespace EV3devTk {

    public enum ButtonBorder {
        BOX,
        NONE;
    }

    public class Button : EV3devTk.Container {
        public ButtonBorder border { get; set; default = ButtonBorder.BOX; }

        public override ushort preferred_width {
            get {
                return base.preferred_width
                    + (child == null ? 0 : child.preferred_width);
            }
        }
        public override ushort preferred_height {
            get {
                return base.preferred_height
                    + (child == null ? 0 : child.preferred_height);
            }
        }

        public override ushort border_top {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }
        public override ushort border_bottom {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }
        public override ushort border_left {
            get { return border == ButtonBorder.BOX ? 1 : 0; }
        }
        public override ushort border_right {
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

        protected override void on_draw (Graphics u8g) {
            u8g.set_default_foreground_color ();
            if (has_focus)
                u8g.draw_box (border_x, border_y, border_width, border_height);
            if (border == ButtonBorder.BOX)
                u8g.draw_frame (border_x, border_y, border_width, border_height);
            base.on_draw (u8g);
        }

        protected override bool on_key_pressed (uint key_code) {
            if (key_code == Key.ENTER) {
                pressed ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return base.on_key_pressed (key_code);
        }
    }
}
