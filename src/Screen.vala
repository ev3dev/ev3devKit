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

/* AbstractScreen.vala - Screen object contains all other widgets */

using Gee;
using U8g;

namespace EV3devTk {
    public abstract class Screen : Object {
        LinkedList<Window> window_stack;
        LinkedList<uint?> key_queue;

        Graphics _u8g;
        public unowned Graphics u8g { get { return _u8g; } }

        public abstract bool active { get; }
        public bool dirty { get; set; }
        public Window? top_window {
            owned get { return window_stack.peek_tail (); }
        }

        protected Screen (Device device) {
            window_stack = new LinkedList<Window> ();
            key_queue = new LinkedList<uint?> ();
            _u8g = new Graphics ();
            _u8g.init (device);

            Timeout.add(50, on_draw_timeout);
        }

        void handle_input () {
            var key_code = key_queue.poll_head ();
            if (key_code == null)
                return;
            var focus_widget = top_window.do_recursive_children ((widget) => {
                if (widget.has_focus)
                    return widget;
                return null;
            });
            if (focus_widget != null) {
                focus_widget.do_recursive_parent ((widget) => {
                    if (widget.key_pressed (key_code))
                        return widget;
                    return null;
                });
            }
        }

        /**
         * Put window on top of visible window stack.
         *
         * @param window The window to add to the stack.
         */
        public void push_window (Window window) {
            window._screen = this;
            window.shown ();
            window_stack.offer_tail (window);
            dirty = true;
        }

        /**
         * Remove the top window from the window stack.
         *
         * @return The window that was popped from the stack.
         */
        public Window? pop_window () {
            var window = window_stack.poll_tail ();
            window._screen = null;
            if (window_stack.size > 0)
                window_stack.peek_tail ().shown ();
            dirty = true;
            return window;
        }

        public void queue_key_code (uint key_code) {
            key_queue.offer_tail (key_code);
        }

        bool on_draw_timeout () {
            if (active) {
                handle_input ();
                if (dirty) {
                    u8g.begin_draw ();
                    foreach (var window in window_stack)
                        window.draw (_u8g);
                    u8g.end_draw ();
                    dirty = false;
                }
            }
            return true;
        }
    }
}
