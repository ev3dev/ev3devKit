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
using Ev3devKit.Ui;
using Linux.VirtualTerminal;
using Posix;

/**
 * Toolkit for developing applications using ev3dev.
 *
 * {{{
 *             _____     _            _  ___ _
 *   _____   _|___ /  __| | _____   _| |/ (_) |_
 *  / _ \ \ / / |_ \ / _` |/ _ \ \ / / ' /| | __|
 * |  __/\ V / ___) | (_| |  __/\ V /| . \| | |_
 *  \___| \_/ |____/ \__,_|\___| \_/ |_|\_\_|\__|
 *
 * }}}
 *
 * Find out more about ev3dev at [[http://www.ev3dev.org]].
 */
namespace Ev3devKit {
    /**
     * Does all of the low level setting up of a virtual console so you don't
     * have to.
     *
     * To use it, your main function should look something like this:
     * {{{
     * using Ev3devKit;
     *
     * static int main (string[] args) {
     *     try {
     *         ConsoleApp.init ();
     *
     *         // Program-specific initialization goes here. It must include something
     *         // that calls ConsoleApp.quit () when the program is finished.
     *
     *         ConsoleApp.run ();
     *
     *         // Any additional cleanup needed before application exits goes here.
     *
     *         return 0;
     *     } catch (ConsoleAppError err) {
     *         critical ("%s", err.message);
     *         return 1;
     *     }
     * }
     * }}}
     */
    namespace ConsoleApp {
        /**
         * ConsoleApp errors.
         */
        public errordomain ConsoleAppError {
            /**
             * Indicates that the application is not running on a virtual console.
             */
            NOT_A_TTY,
            /**
             * Indicates that an error occurred while setting the graphics mode.
             */
            MODE
        }

        FileStream? tty_in;
        FileStream? tty_out;
        int tty_num;
        Curses.Screen term;
        MainLoop main_loop;

        /**
         * Initialize a console application.
         *
         * This puts the current virtual terminal into graphics mode and sets up
         * ncurses for keyboard input. This must be run before calling any other
         * {@link ConsoleApp} method or using the GRX graphics library.
         *
         * @throws ConsoleAppError if initialization failed.
         */
        public void init () throws ConsoleAppError {

            var tty = ttyname (STDIN_FILENO);
            Regex tty_regex;
            try {
                tty_regex = new Regex ("^/dev/tty([0-9]+)$");
            } catch (RegexError err) {
                // bad regex is a programming error since it does not come from
                // user input.
                error ("%s", err.message);
            }
            MatchInfo match_info;
            if (!tty_regex.match (tty, 0, out match_info)) {
                throw new ConsoleAppError.NOT_A_TTY ("Not running on a virtual console.");
            }
            tty_num = int.parse (match_info.fetch (1));

            /* ncurses setup */

            // If stdout is redirected, curses won't work correctly, so we get
            // file descriptors for the tty and call newterm() instead of
            // initscr(). Note: Curses.Screen() is vala wrapper for newterm().
            tty_in = FileStream.open (tty, "r");
            tty_out = FileStream.open (tty, "w");
            term = new Curses.Screen ("linux", tty_out, tty_in);
            cbreak ();
            noecho ();
            stdscr.keypad (true);

            try {
                if (!Grx.set_driver ("linuxfb"))
                    throw new ConsoleAppError.MODE ("Error setting driver");
                if (!Grx.set_mode (Grx.GraphicsMode.GRAPHICS_DEFAULT))
                    throw new ConsoleAppError.MODE ("Error setting mode");
                Unix.signal_add (SIGHUP, HandleSIGTERM);
                Unix.signal_add (SIGTERM, HandleSIGTERM);
                Unix.signal_add (SIGINT, HandleSIGTERM);
            } catch (ConsoleAppError e) {
                release_console ();
                throw e;
            }
            main_loop = new MainLoop ();
            Ui.Screen.active_screen = new Ui.Screen ();
        }

        /**
         * Starts the main loop for the application.
         *
         * Does not return until {@link quit} is called.
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

        /**
         * Gets the number of the tty that this application is running on.
         *
         * @return The number of the tty.
         */
        public int get_tty_num () {
            return tty_num;
        }

        /**
         * Checks to see if the virtual console this application is running on is active.
         *
         * @return ``true`` if this is running on the active virtual console.
         */
        public bool is_active () {
            Linux.VirtualTerminal.Stat vtstat;
            ioctl (tty_in.fileno (), VT_GETSTATE, out vtstat);
            return tty_num == vtstat.v_active;
        }

        void release_console () {
            Grx.set_driver ("memory"); // releases frame buffer
            endwin ();
        }

        bool HandleSIGTERM () {
            quit ();
            return false;
        }

        bool ignore_next_ch = false;

        /**
         * Tell ConsoleApp to ignore the next key read by ncurses.
         *
         * This is useful when a key press has been handled already by some
         * other method (like {@link Devices.Input}).
         */
        public void ignore_next_key_press () {
            ignore_next_ch = true;
        }

        int read_input () {
            while (true) {
                var ch = getch ();
                if (ch != -1 && Ui.Screen.active_screen != null) {
                    if (ignore_next_ch) {
                        ignore_next_ch = false;
                        continue;
                    }
                    Idle.add (() => {
                        Ui.Screen.active_screen.queue_key_code (ch);
                        return false;
                    });
                }
            }
        }
    }
}