/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2017 David Lechner <david@lechnology.com>
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

/* main.vala - main function for running UI demo */

using Ev3devKit;

namespace Ev3devKit.Demo {

    public static int main (string[] args) {
        try {
            var app = new ConsoleApp ();

            var activate_id = app.activate.connect (() => {
                var demo_window = new UiDemoWindow ();
                demo_window.quit.connect (app.quit);
                demo_window.show ();
            });

            app.run ();
            // break reference cycle on app
            app.disconnect (activate_id);

            return 0;
        } catch (GLib.Error err) {
            critical ("%s", err.message);
            return 1;
        }
    }
}
