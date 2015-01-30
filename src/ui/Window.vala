/*
 * EV3devKit.UI - ev3dev toolkit for LEGO MINDSTORMS EV3
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

namespace EV3devKit.UI {
    /**
     * Top level widget for displaying other widgets on the {@link Screen}.
     *
     * All other widgets must be contained in a Window in order to be displayed
     * on the {@link Screen}. Windows are displayed in a stack. A new Window is
     * added to the stack by calling {@link show} and removed from the stack
     * by calling {@link close}. Only the top-most Window is visible to the user
     * and only that Window receives user input.
     */
    public class Window : EV3devKit.UI.Container {
        /**
         * Gets the Screen that this Window is attached to.
         *
         * Returns ``null`` if the Window is not in the window stack of a Screen.
         */
        public weak Screen? screen { get; internal set; }

        /**
         * Returns true if the Window is currently displayed on the Screen.
         *
         * In other words, this Window is on top of the Window stack. Only one
         * Window and one Dialog can be ``on_screen`` at a time.
         */
        public bool on_screen { get; set; default = false; }

        /**
         * Emitted the first time this Window is shown on a Screen.
         */
        public virtual signal void shown () {
            if (!descendant_has_focus)
                focus_first ();
        }

        /**
         * Emitted when this window is closed (removed from the window stack).
         */
        public virtual signal void closed () {
        }

        /**
         * Creates a new instance of a Window.
         */
        public Window () {
            base (ContainerType.SINGLE);
        }

        /**
         * Default handler for the key_pressed signal.
         */
        protected override bool key_pressed (uint key_code) {
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

        /**
         * Make the window visible by putting it on top of the window stack.
         *
         * @param screen The screen to show the window on.
         */
        public void show (Screen screen = Screen.active_screen) {
            if (screen == null) {
                critical ("No active screen.");
                return;
            }
            screen.show_window (this);
        }

        /**
         * Remove the window from the window stack.
         *
         * If it was the top Window on the stack, the next window will become
         * visible.
         *
         * @return True if the window was removed.
         */
        public bool close () {
            if (_screen == null)
                return false;
            return _screen.close_window (this);
        }

        /**
         * {@inheritDoc}
         */
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
