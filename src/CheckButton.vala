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

/* CheckButton.vala - Widget that represents a checkbox or radio button */

using Curses;
using Gee;
using GRX;

namespace EV3devKit {

    public enum CheckButtonType {
        CHECKBOX,
        RADIO;
    }

    public class CheckButtonGroup : Object {
        public weak CheckButton selected_item { get; internal set; }
        public CheckButtonGroup () {
        }
    }

    public class CheckButton : EV3devKit.Widget {
        CheckButtonType check_button_type;

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

        public int outer_size { get; set; default = 9; }
        public int inner_size { get; set; default = 5; }

        CheckButton (CheckButtonType type, CheckButtonGroup? group = null)
        {
            check_button_type = type;
            this.group = group;
            padding = 2;
            can_focus = true;
            horizontal_align = WidgetAlign.CENTER;
            vertical_align = WidgetAlign.CENTER;

            notify["checked"].connect (redraw);
            notify["outer-size"].connect (redraw);
            notify["inner-size"].connect (redraw);
        }

        public CheckButton.checkbox () {
            this (CheckButtonType.CHECKBOX);
        }

        public CheckButton.radio (CheckButtonGroup group) {
            this (CheckButtonType.RADIO, group);
        }

        public override int get_preferred_width () {
            return outer_size + get_margin_border_padding_width ();
        }

        public override int get_preferred_height () {
            return outer_size + get_margin_border_padding_height ();
        }

        protected override void draw_content () {
            unowned GRX.Color color;
            if (has_focus || parent.draw_children_as_focused) {
                color = window.screen.mid_color;
                filled_box (border_bounds.x1, border_bounds.y1, border_bounds.x2,
                    border_bounds.y2, color);
                color = window.screen.bg_color;
            } else
                color = window.screen.fg_color;
            if (check_button_type == CheckButtonType.CHECKBOX)
                box (content_bounds.x1, content_bounds.y1, content_bounds.x2,
                    content_bounds.y2, color);
            else
                circle (content_bounds.x1 + outer_size / 2,
                    content_bounds.y1 + outer_size / 2, outer_size / 2, color);
            if (checked) {
                if (check_button_type == CheckButtonType.CHECKBOX) {
                    var x1 = content_bounds.x1 + (outer_size - inner_size) / 2;
                    var y1 = content_bounds.y1 + (outer_size - inner_size) / 2;
                    var x2 = content_bounds.x2 - (outer_size - inner_size) / 2;
                    var y2 = content_bounds.y2 - (outer_size - inner_size) / 2;
                    filled_box (x1, y1, x2, y2, color);
                } else
                    filled_circle (content_bounds.x1 + outer_size / 2,
                        content_bounds.y1 + outer_size / 2, inner_size / 2, color);
            }
        }

        protected override bool key_pressed (uint key_code) {
            if (key_code == '\n') {
                if (check_button_type == CheckButtonType.CHECKBOX)
                    checked = !checked;
                else
                    checked = true;
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return base.key_pressed (key_code);
        }
    }
}
