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

/* ConsoleApp.vala - Graphic mode console application that uses ncurses for input */

using Curses;
using Linux.VirtualTerminal;
using Posix;

namespace EV3devKit {
    /**
     * ConsoleApp does all of the low level setting up of a virtual console
     * so you don't have to. To use it, your main function should look something
     * like this:
     * {{{
     * static int main (string[] args) {
     *     try {
     *         ConsoleApp.init ();
     *
     *         // Program-specific initialization which includes something
     *         // that calls ConsoleApp.quit () when the program is finished.
     *
     *         ConsoleApp.run ();
     *
     *         // any additional cleanup if needed before application exits.
     *
     *         return 0;
     *     } catch (ConsoleAppError err) {
     *         critical ("%s", err.message);
     *     }
     *     return 1;
     * }
     * }}}
     */
    namespace ConsoleApp {
        /**
         * ConsoleApp errors.
         */
        public errordomain ConsoleAppError {
            /**
             * Indicates that an error occurred while setting the graphics mode.
             */
            MODE
        }

        FileStream? vtIn;
        FileStream? vtOut;
        Curses.Screen term;
        MainLoop main_loop;

        /**
         * Initialize a console application.
         *
         * This puts the specified virtual terminal into graphics mode and sets
         * up ncurses for keyboard input. This must be run before calling anything
         * else using the GRX graphics library.
         *
         * @param vtfd File descriptor for virtual terminal to use or ``null`` to
         * use the current virtual terminal.
         * @throws ConsoleAppError if initialization failed.
         */
        public void init (int? vtfd = null) throws ConsoleAppError {
            /* ncurses setup */

            if (vtfd != null) {
                vtIn = FileStream.fdopen (vtfd, "r");
                vtOut = FileStream.fdopen (vtfd, "w");
                term = new Curses.Screen ("linux", vtIn, vtOut);
            } else {
                initscr ();
            }
            cbreak ();
            noecho ();
            stdscr.keypad (true);

            try {
                if (!GRX.set_driver ("linuxfb"))
                    throw new ConsoleAppError.MODE ("Error setting driver");
                if (!GRX.set_mode (GRX.GraphicsMode.GRAPHICS_DEFAULT))
                    throw new ConsoleAppError.MODE ("Error setting mode");
                Unix.signal_add (SIGHUP, HandleSIGTERM);
                Unix.signal_add (SIGTERM, HandleSIGTERM);
                Unix.signal_add (SIGINT, HandleSIGTERM);
            } catch (ConsoleAppError e) {
                release_console ();
                throw e;
            }
            main_loop = new MainLoop ();
            Screen.active_screen = new Screen ();
        }

        /**
         * Starts the main loop for the application.
         *
         * Does not return until ConsoleApplication.quit () is called.
         */
        public void run () {
            new Thread<int> ("input", read_input);
            main_loop.run ();
            release_console ();
        }

        /**
         * Instructs the main loop to quit.
         */
        public void quit () {
            main_loop.quit ();
        }

        void release_console () {
            GRX.set_driver ("memory"); // releases frame buffer
        }

        bool HandleSIGTERM () {
            quit ();
            return false;
        }

        int read_input () {
            while (true) {
                var ch = getch ();
                if (ch != -1 && Screen.active_screen != null) {
                    Idle.add (() => {
                        Screen.active_screen.queue_key_code (ch);
                        return false;
                    });
                }
            }
        }
    }
}