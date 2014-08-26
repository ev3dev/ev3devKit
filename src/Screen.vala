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

/* AbstractScreen.vala - Screen object contains all other widgets */

using Gee;
using GRX;

namespace EV3devKit {
    public abstract class Screen : Object {
        LinkedList<Window> window_stack;
        LinkedList<uint?> key_queue;
        protected Context context;

        internal Color fg_color;
        internal Color bg_color;
        internal Color mid_color;

        public int width { get; private set; }
        public int height { get; private set; }
        public bool dirty { get; set; default = true; }
        public Window? top_window {
            owned get { return window_stack.peek_tail (); }
        }

        public Screen () {
            this.custom (screen_x () - 1, screen_y () - 1);
        }

        public Screen.custom (int width, int height, char *context_mem_addr = null) {
            window_stack = new LinkedList<Window> ();
            key_queue = new LinkedList<uint?> ();
            FrameMode mode = core_frame_mode ();
            if (mode == FrameMode.UNDEFINED)
                mode = screen_frame_mode ();
            if (context_mem_addr == null)
                context = Context.create_with_mode (mode, width, height);
            else {
                char* addr[4];
                addr[0] = context_mem_addr;
                context = Context.create_with_mode (mode, width, height, addr);
            }
            fg_color = Color.black;
            bg_color = Color.white;
            if (context.driver.bits_per_pixel == 1)
                mid_color = Color.black;
            else
                mid_color = Color.alloc (0, 0, 255);
            this.width = width;
            this.height = height;
            Timeout.add (50, on_draw_timeout);
        }

        public virtual void refresh () {
            bit_blt (Context.screen, 0, 0, context, 0, 0, screen_x () - 1, screen_y () - 1);
        }

        void handle_input () {
            var key_code = key_queue.poll_head ();
            if (key_code == null || top_window == null)
                return;
            // get the currently focused widget or top_window if none
            var focus_widget = top_window.do_recursive_children ((widget) => {
                if (widget.has_focus)
                    return widget;
                return null;
            }) ?? top_window;
            // Trigger the key press event for the focused widget.
            // If it is not handled, pass it to the parent.
            focus_widget.do_recursive_parent ((widget) => {
                // key press event may release all references to widget, so this
                // gets a reference before calling key_pressed ()
                var result = widget;
                if (widget.key_pressed (key_code))
                    return result;
                return null;
            });
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
            handle_input ();
            if (dirty) {
                context.set ();
                Window? top_window = null;
                Window? top_dialog = null;
                foreach (var window in window_stack) {
                    if (window.window_type == WindowType.DIALOG) {
                        if (top_dialog != null && top_dialog.on_screen)
                            top_dialog.on_screen = false;
                        top_dialog = window;
                    } else {
                        if (top_window != null && top_window.on_screen)
                            top_window.on_screen = false;
                        top_window = window;
                        if (top_dialog != null) {
                            if (top_dialog.on_screen)
                                top_dialog.on_screen = false;
                            top_dialog = null;
                        }
                    }
                }
                if (top_window != null) {
                    top_window.on_screen = true;
                    top_window.draw (context);
                }
                if (top_dialog != null) {
                    top_dialog.on_screen = true;
                    top_dialog.draw (context);
                }
                dirty = false;
                refresh ();
            }
            return true;
        }
    }
}
