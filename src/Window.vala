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

/* Window.vala - Top level widget */

using Curses;
using GRX;

namespace EV3devKit {
    public class Window : EV3devKit.Container {
        internal weak Screen? _screen;
        public Screen? screen {
            get { return _screen; }
        }

        public bool on_screen { get; set; default = false; }

        public virtual signal void shown () {
            if (!descendant_has_focus)
                focus_first ();
        }

        public virtual signal void closed () {
        }

        public Window () {
            base (ContainerType.SINGLE);
        }

        public override bool key_pressed (uint key_code) {
            switch (key_code) {
            case Key.UP:
            case Key.DOWN:
            case Key.LEFT:
            case Key.RIGHT:
                focus_first ();
                break;
            case Key.BACKSPACE:
                // screen.close_window () can release the reference to this,
                // so don't do anything that references this after here.
                screen.close_window (this);
                break;
            default:
                return base.key_pressed (key_code);
            }
            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }

        public override void redraw () {
            if (_screen != null && on_screen)
                _screen.dirty = true;
        }

        protected override void do_layout () {
            set_bounds (0, _screen.window_y, _screen.width - 1,
                _screen.window_y + _screen.window_height - 1);
            base.do_layout ();
        }

        protected override void draw_background () {
            var color = screen.bg_color;
            filled_box (border_bounds.x1, border_bounds.y1, border_bounds.x2,
                border_bounds.y2, color);
        }

        protected override void draw_content () {
            base.draw_content ();
        }
    }
}
