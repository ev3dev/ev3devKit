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

/* Window.vala - Top level widget */

using Curses;
using GRX;

namespace EV3devTk {
    public enum WindowType {
        NORMAL,
        DIALOG
    }

    public class Window : EV3devTk.Container {
        const int DIALOG_MARGIN = 12;

        internal weak Screen? _screen;
        public Screen? screen {
            get { return _screen; }
        }
        public WindowType window_type { get; private set; }

        public bool on_screen { get; set; default = false; }

        public signal void shown ();

        Window.with_type (WindowType type) {
            base (ContainerType.SINGLE);
            window_type = type;
            shown.connect (on_first_shown);
        }

        public Window () {
            this.with_type (WindowType.NORMAL);
        }

        public Window.dialog () {
            this.with_type (WindowType.DIALOG);
            margin = DIALOG_MARGIN;
            border = 1;
            border_radius = 10;
        }

        public override bool key_pressed (uint key_code) {
            if (key_code == Key.BACKSPACE) {
                Signal.stop_emission_by_name (this, "key-pressed");
                // screen.pop_window () releases the reference to window, so don't
                // do anything that references this after it.
                screen.pop_window ();
                return true;
            }
            return base.key_pressed (key_code);
        }

        public override void redraw () {
            if (_screen != null && on_screen)
                _screen.dirty = true;
        }

        public override void draw (Context context) {
            set_bounds (0, 0, context.x_max, context.y_max);
            var color = screen.bg_color;
            if (window_type == WindowType.DIALOG) {
                filled_rounded_box (border_bounds.x1, border_bounds.y1,
                    border_bounds.x2, border_bounds.y2, 10, color);
                color = screen.fg_color;
            } else {
                filled_box (border_bounds.x1, border_bounds.y1, border_bounds.x2,
                    border_bounds.y2, color);
            }
            base.draw (context);
        }

        void on_first_shown () {
            shown.disconnect (on_first_shown);
            var focus_widget = do_recursive_children ((widget) => {
                if (widget.can_focus)
                    return widget;
                return null;
            });
            if (focus_widget != null)
                focus_widget.focus ();
        }
    }
}
