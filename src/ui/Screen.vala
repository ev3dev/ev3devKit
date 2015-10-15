/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* Screen.vala - Screen object contains all other widgets */

using Grx;

namespace Ev3devKit.Ui {
    /**
     * Represents a screen that UI elements are displayed on.
     *
     * In addition to displaying widgets, the screen also maintains an input
     * queue that it passes to the top window to handle user input.
     */
    public class Screen : Object {
        internal static Screen? active_screen;

        protected Queue<Window> window_stack;
        Queue<uint?> key_queue;
        Context context;

        /**
         * Gets and sets the foreground color.
         *
         * This color is used by widget drawing functions for things like text
         * and borders.
         */
        public Color fg_color { get; set; }

        /**
         * Gets and sets the background color.
         *
         * This color is used by widget drawing functions for things like filling
         * background areas.
         */
        public Color bg_color { get; set; }

        /**
         * Gets and sets the intermediate color.
         *
         * This color is used by widget drawing functions to indicate focus.
         */
        public Color mid_color { get; set; }

        /**
         * Gets the width of the screen.
         */
        public int width { get; construct; }

        /**
         * Gets the height of the screen.
         */
        public int height { get; construct; }

        /**
         * Gets the height of windows for the screen.
         *
         * The value depends on whether or not the status bar is visible.
         */
        public int window_height {
            get { return height - window_y; }
        }

        /**
         * Gets the topmost y-axis value for windows on the screen.
         *
         * The value depends on whether or not the status bar is visible.
         */
        public int window_y {
            get { return status_bar.visible ? StatusBar.HEIGHT : 0; }
        }

        /**
         * Returns ``true`` if any widget has called {@link Widget.redraw} and
         * the screen has not been redrawn yet.
         */
        public bool dirty { get; set; default = true; }

        /**
         * Gets the top window on the window stack.
         *
         * Returns ``null`` if there are no windows in the stack.
         */
        public Window? top_window {
            owned get { return window_stack.peek_head (); }
        }

        /**
         * Gets the status bar for the screen.
         */
        public StatusBar status_bar { get; internal set; }

        /**
         * Gets the currently active screen.
         *
         * Calling {@link Window.show} will display the window on this screen.
         *
         * @return The currently active screen or ``null`` if that active screen
         * has not been set.
         */
        public static Screen? get_active_screen () {
            return active_screen;
        }

        /**
         * Sets the currently active screen.
         *
         * Calling {@link Window.show} will display the window on this screen.
         *
         * @param screen The new active screen.
         */
        public static void set_active_screen (Screen? screen) {
            active_screen = screen;
        }

        construct {
            window_stack = new Queue<Window> ();
            key_queue = new Queue<uint?> ();
            status_bar = new StatusBar () {
                visible = false
            };
            status_bar.screen = this;

            fg_color = Color.black;
            bg_color = Color.white;
            mid_color = Color.alloc (0, 0, 255); // blue

            Timeout.add (50, draw);
        }

        /**
         * Creates a new screen using the current GRX screen information.
         */
        public Screen () {
            this.custom (screen_x (), screen_y ());
        }

        /**
         * Creates a new screen with a custom size and optional memory location.
         *
         * @param width The width of the screen.
         * @param height The height of the screen.
         * @param context_mem_addr The memory address used by the GRX context.
         * If ``null`` memory will be automatically allocated for the context.
         */
        public Screen.custom (int width, int height, char *context_mem_addr = null) {
            Object (width: width, height: height);
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
            if (context.driver.bits_per_pixel == 1)
                mid_color = Color.black;
        }

        /**
         * Add a key code to the queue.
         */
        public void queue_key_code (uint key_code) {
            key_queue.push_tail (key_code);
        }

        /**
         * Refresh the screen.
         *
         * Everything is drawn on a {@link Grx.Context} in memory. Refreshing
         * copies this to the actual screen so that it is displayed to the user.
         */
        protected virtual void refresh () {
            bit_blt (Context.screen, 0, 0, context, 0, 0, screen_x () - 1, screen_y () - 1);
        }

        void handle_input () {
            var key_code = key_queue.pop_head ();
            if (key_code == null || top_window == null)
                return;
            // get the currently focused widget or top_window if none
            var focus_widget = top_window.get_focused_child () ?? top_window;
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
        internal void show_window (Window window) {
            if (window.screen != null)
                window.screen.close_window (window);
            window.screen = this;
            window_stack.push_head (window);
            dirty = true;
            window.shown ();
        }

        /**
         * Remove the window from the window stack.
         *
         * @param window The window to add to the stack.
         * @return True if the window was removed.
         */
        internal bool close_window (Window window) {
            var was_top_window = window_stack.peek_head () == window;
            var index = window_stack.index (window);
            if (index >= 0) {
                window_stack.pop_nth (index);
                if (window.ref_count > 0) {
                    window.screen = null;
                    window.on_screen = false;
                    window.closed ();
                }
                if (was_top_window && !window_stack.is_empty ()) {
                    window_stack.peek_head ().shown ();
                }
                dirty = true;
                return true;
            }
            return false;
        }

        /**
         * Draws the topmost window and dialog on the screen.
         */
        protected bool draw () {
            handle_input ();
            if (dirty) {
                context.set ();
                Window? top_window = null;
                Window? top_dialog = null;
                unowned List<Window> iter = window_stack.tail;
                while (iter != null) {
                    var window = iter.data;
                    if (window is Dialog) {
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
                    iter = iter.prev;
                }
                if (top_window != null) {
                    top_window.on_screen = true;
                    top_window.draw ();
                }
                if (top_dialog != null) {
                    top_dialog.on_screen = true;
                    top_dialog.draw ();
                }
                if (_status_bar.visible)
                    _status_bar.draw ();
                dirty = false;
                refresh ();
            }
            return true;
        }
    }
}
