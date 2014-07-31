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

/* CheckButton.vala - Widget that represents a checkbox or radio button */

using Curses;
using Gee;
using U8g;

namespace EV3devTk {

    public enum CheckButtonType {
        CHECKBOX,
        RADIO;
    }

    public class CheckButtonGroup : Object {
        public CheckButton selected_item { get; internal set; }
        public CheckButtonGroup () {
        }
    }

    public class CheckButton : EV3devTk.Widget {
        CheckButtonType check_button_type;

        public override ushort preferred_width {
            get {
                return outer_size + base.preferred_width;
            }
        }
        public override ushort preferred_height {
            get {
                return outer_size + base.preferred_height;
            }
        }

        bool _checked = false;
        public bool checked {
            get { return _checked; }
            set {
                _checked = value;
                if (checked && group != null) {
                    group.selected_item = this;
                    if (window != null) {
                        /* uncheck all other CheckButtons with the same group name */
                        window.do_recursive_children ((widget) => {
                            var check_button = widget as CheckButton;
                            if (check_button != null && check_button != this
                                && check_button.group == group)
                                check_button.checked = false;
                            return null;
                        });
                    }
                }
                if (!checked && group != null && group.selected_item == this)
                    group.selected_item = null;
            }
        }
        public CheckButtonGroup? group { get; private set; }

        public ushort outer_size { get; set; default = 9; }
        public ushort inner_size { get; set; default = 5; }

        public CheckButton (CheckButtonType type = CheckButtonType.CHECKBOX,
            CheckButtonGroup? group = null)
        {
            check_button_type = type;
            this.group = group;
            padding_top = 2;
            padding_bottom = 2;
            padding_left = 2;
            padding_right = 2;
            can_focus = true;

            notify["checked"].connect (redraw);
            notify["outer_size"].connect (redraw);
            notify["inner_size"].connect (redraw);
        }

        protected override void on_draw (Graphics u8g) {
            weak Widget widget = this;
            while (widget.parent != null) {
                if (widget.can_focus)
                    break;
                else
                    widget = widget.parent;
            }
            u8g.set_default_foreground_color ();
            if (widget.has_focus) {
                u8g.draw_box (border_x, border_y, border_width, border_height);
                u8g.set_default_background_color ();
            }
            if (check_button_type == CheckButtonType.CHECKBOX)
                u8g.draw_frame (content_x, content_y, outer_size, outer_size);
            else
                u8g.draw_circle (content_x + outer_size / 2,
                    content_y + outer_size / 2, outer_size / 2);
            if (checked) {
                if (check_button_type == CheckButtonType.CHECKBOX)
                    u8g.draw_box (content_x + (outer_size - inner_size) / 2,
                        content_y + (outer_size - inner_size) / 2,
                        inner_size, inner_size);
                else
                    u8g.draw_disc (content_x + outer_size / 2,
                        content_y + outer_size / 2, inner_size / 2);
            }
        }

        protected override bool on_key_pressed (uint key_code) {
            if (key_code == Key.ENTER) {
                if (check_button_type == CheckButtonType.CHECKBOX)
                    checked = !checked;
                else
                    checked = true;
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return base.on_key_pressed (key_code);
        }
    }
}
