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

/* ConsoleApp.vala - Graphic mode console application that uses ncurses for input */

using Curses;
using Linux.Console;
using Linux.VirtualTerminal;
using Posix;

namespace EV3devTk {
    namespace ConsoleApp {
        errordomain ConsoleError {
            MODE
        }

        int vtfd;
        Linux.VirtualTerminal.Stat vtstat;
        int vtnum;
        FileStream? vtIn;
        FileStream? vtOut;
        Curses.Screen term;
        MainLoop main_loop;

        public EV3devTk.Screen screen;

        public void init () {
            vtfd = open ("/dev/tty0", O_RDWR, 0);
            if (vtfd < 0)
                error ("could not open /dev/tty0 (error: %d)", -vtfd);
            if (ioctl (vtfd, VT_GETSTATE, out vtstat) < 0)
                error ("tty is not virtual console");
            if (ioctl (vtfd, VT_OPENQRY, out vtnum) < 0)
                error ("no free virtual consoles");
            var device = "/dev/tty" + vtnum.to_string ();
            if (access (device, (W_OK | R_OK)) < 0)
                error ("insufficient permission for %s", device);
            close (vtfd);

            vtfd = open (device, O_RDWR, 0);

            /* ncurses setup */

            vtIn = FileStream.fdopen (vtfd, "r");
            vtOut = FileStream.fdopen (vtfd, "w");
            term = new Curses.Screen ("linux", vtIn, vtOut);
            cbreak ();
            noecho ();
            stdscr.keypad (true);
            stdscr.nodelay (true);

            main_loop = new MainLoop ();
            Timeout.add (10, on_check_key_timeout);
        }

        public void run () {
            ioctl (vtfd, VT_ACTIVATE, vtnum);
            ioctl (vtfd, VT_WAITACTIVE, vtnum);
            var mode = Mode() {
                mode = (char)VT_PROCESS,
                relsig = (int16)SIGUSR1,
                acqsig = (int16)SIGUSR1
            };
            string error_msg = null;
            try {
                if (ioctl (vtfd, VT_SETMODE, ref mode) < 0)
                      throw new ConsoleError.MODE (
                            "Could not set virtual console to VT_PROCESS mode.");
                if (ioctl (vtfd, KDSETMODE, TerminalMode.GRAPHICS) < 0)
                      throw new ConsoleError.MODE (
                            "Could not set virtual console to KD_GRAPHICS mode.");
                Unix.signal_add (SIGHUP, HandleSIGTERM);
                Unix.signal_add (SIGTERM, HandleSIGTERM);
                Unix.signal_add (SIGINT, HandleSIGTERM);
                Unix.signal_add (SIGUSR1, HandleSIGUSR1);

                main_loop.run ();
            } catch (ConsoleError e) {
                error_msg = e.message;
            }

            ioctl (vtfd, KDSETMODE, TerminalMode.TEXT);
            mode.mode = (char)VT_AUTO;
            ioctl (vtfd, VT_SETMODE, ref mode);

            if (is_active ()) {
                set_active (false);
                ioctl (vtfd, VT_ACTIVATE, vtstat.v_active);
                ioctl (vtfd, VT_WAITACTIVE, vtstat.v_active);
            }
            ioctl (vtfd, VT_DISALLOCATE, vtnum);

            close (vtfd);

            if (error_msg != null)
                error ("%s", error_msg);
        }

        public void quit () {
            main_loop.quit ();
        }

        bool is_active () {
            return !isendwin ();
        }

        void set_active (bool value) {
            if (value == is_active ())
                return;
            if (value) {
                refresh ();
                if (screen != null)
                    screen.dirty = true;
            } else
                endwin ();
            if (screen != null)
                screen.active = value;
        }

        bool HandleSIGTERM () {
            quit ();
            return true;
        }

        /**
         * SIGUSR1 is used for console switching.
         */
        bool HandleSIGUSR1 () {
            if (is_active ()) {
                // release console
                if (ioctl (vtfd, VT_RELDISP, 1) == 0)
                  set_active (false);
            } else {
                Linux.VirtualTerminal.Stat vtstat;
                if (ioctl (vtfd, VT_GETSTATE, out vtstat) == 0) {
                    if (vtstat.v_active == vtnum) {
                        // acquire console
                        ioctl (vtfd, VT_RELDISP, VT_ACKACQ);
                        set_active (true);
                    }
                }
            }
            return true;
        }

        bool on_check_key_timeout () {
            var ch = getch ();
            if (ch != -1 && screen != null)
                screen.queue_key_code (ch);
            return true;
        }
    }
}