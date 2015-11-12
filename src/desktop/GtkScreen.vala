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

/* GtkScreen.vala - Screen implementation for desktop (Gtk) */

using Ev3devKit;
using Grx;

namespace Ev3devKitDesktop {
    /**
     * A Screen that can be embedded in a Gtk application.
     *
     * GtkScreens can be linked in a master-slave type connection so that the
     * UI on the master screen can be viewed simultaneously on the slave screens.
     * This lets you view your UI on multiple resolutions and color depths at
     * the same time.
     */
    public class GtkScreen : Ev3devKit.Ui.Screen {
        GtkFramebuffer fb;

        /**
         * Creates a new screen.
         *
         * @param fb The frambuffer that the screen will be displayed on.
         */
        public GtkScreen (GtkFramebuffer fb) {
            base.custom (fb.info.width, fb.info.height, fb.pixbuf_data);
            this.fb = fb;
            if (fb.info.monochrome) {
                mid_color = fg_color;
            }
        }

        /**
         * {@inheritDoc}
         */
        protected override void refresh () {
            fb.refresh ();
        }
    }
}
