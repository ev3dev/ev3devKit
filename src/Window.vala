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

using U8g;

namespace EV3devTk {
    public enum WindowType {
        NORMAL,
        DIALOG
    }

    public class Window : EV3devTk.Container {

        internal Screen? _screen;
        public Screen? screen {
            get { return _screen; }
        }
        public WindowType window_type { get; private set; }

        public override ushort x {
            get {
                if (screen != null && window_type == WindowType.DIALOG)
                    return screen.u8g.width * 10 / 100;
                return base.x;
            }
        }

        public override ushort y {
            get {
                if (screen != null && window_type == WindowType.DIALOG)
                    return screen.u8g.height * 10 / 100;
                return base.y;
            }
        }

        public override ushort width {
            get {
                if (screen == null)
                    return base.width;
                switch (window_type) {
                case WindowType.NORMAL:
                    return screen.u8g.width;
                case WindowType.DIALOG:
                    return screen.u8g.width * 80 / 100;
                default:
                    return base.width;
                }
            }
        }

        public override ushort height {
            get {
                if (screen == null)
                    return base.height;
                switch (window_type) {
                case WindowType.NORMAL:
                    return screen.u8g.height;
                case WindowType.DIALOG:
                    return screen.u8g.height * 80 / 100;
                default:
                    return base.height;
                }
            }
        }

        public override ushort max_width {
            get { return width; }
        }

        public override ushort max_height {
            get { return height; }
        }

        internal override ushort border_top {
            get { return window_type == WindowType.DIALOG ? 1 : 0; }
        }
        internal override ushort border_bottom {
            get { return window_type == WindowType.DIALOG ? 1 : 0; }
        }
        internal override ushort border_left {
            get { return window_type == WindowType.DIALOG ? 1 : 0; }
        }
        internal override ushort border_right {
            get { return window_type == WindowType.DIALOG ? 1 : 0; }
        }

        public signal void shown ();

        public Window (WindowType type = WindowType.NORMAL) {
            base (ContainerType.SINGLE);
            window_type = type;
            shown.connect (on_first_shown);
        }

        public override void redraw () {
            if (screen != null)
                screen.dirty = true;
        }

        protected override void on_draw (Graphics u8g) {
            if (window_type == WindowType.DIALOG) {
                u8g.set_default_background_color ();
                u8g.draw_rounded_box (border_x, border_y, border_width,
                    border_height, 10);
                u8g.set_default_foreground_color ();
                u8g.draw_rounded_frame (border_x, border_y, border_width,
                    border_height, 10);
            } else {
                u8g.set_default_background_color ();
                u8g.draw_box (border_x, border_y, border_width, border_height);
            }
            base.on_draw (u8g);
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
