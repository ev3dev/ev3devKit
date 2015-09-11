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

/* GtkScreen.vala - Screen implementation for desktop (Gtk) */

using EV3devKit;
using Gee;
using Grx;

namespace EV3devKitDesktop {
    /**
     * A Screen that can be embedded in a Gtk application.
     *
     * GtkScreens can be linked in a master-slave type connection so that the
     * UI on the master screen can be viewed simultaneously on the slave screens.
     * This lets you view your UI on multiple resolutions and color depths at
     * the same time.
     */
    public class GtkScreen : EV3devKit.Ui.Screen {
        GtkFramebuffer fb;
        weak GtkScreen? master;
        Gee.List<weak GtkScreen> slaves;

        /**
         * Creates a new screen.
         *
         * @param fb The frambuffer that the screen will be displayed on.
         * @param master If specified, this screen will used the window stack
         * and status bar from the master screen.
         */
        public GtkScreen (GtkFramebuffer fb, GtkScreen? master = null) {
            base.custom (fb.info.width, fb.info.height, fb.pixbuf_data);
            this.fb = fb;
            if (fb.info.monochrome) {
                mid_color = fg_color;
            }
            this.master = master;
            slaves = new ArrayList<GtkScreen> ();
            if (master != null) {
                master.slaves.add (this);
            }
        }

        ~GtkScreen () {
            master.slaves.remove (this);
            foreach (var slave in slaves) {
                slave.master = null;
            }
        }

        /**
         * {@inheritDoc}
         */
        protected override void refresh () {
            fb.refresh ();
            foreach (var slave in slaves) {
                status_bar.screen = slave;
                var save_slave_status_bar = slave.status_bar;
                slave.status_bar = status_bar;
                set_screen_for_each_window (slave);
                var save_slave_window_stack = slave.window_stack;
                slave.window_stack = window_stack;
                slave.dirty = true;
                slave.draw ();
                slave.status_bar = save_slave_status_bar;
                slave.window_stack = save_slave_window_stack;
                slave.dirty = false;
            }
            status_bar.screen = this;
            set_screen_for_each_window (this);
        }

        void set_screen_for_each_window (Ui.Screen screen) {
            foreach (var window in window_stack) {
                window.screen = screen;
                    if (master != null) {
                    window.do_recursive_children ((child) => {
                        child.redraw ();
                        return null;
                    });
                }
            }
        }
    }
}
