/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
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

namespace Ev3devKit.Devices {
    /**
     * Info about the machine we are running on.
     */
    namespace Cpu {
        string _model;
        string _hardware;
        string _revision;
        string _serial_number;

        /**
         * Get the model name of the board we are running on.
         *
         * @return The model name.
         */
        public string get_model () {
            if (_model == null) {
                set_model ();
            }
            return _model;
        }

        /**
         * Get the revision of the board we are running on.
         *
         * @return The revision number.
         */
        public string get_revision () {
            if (_revision == null) {
                set_cpuinfo ();
            }
            return _revision;
        }

        /**
         * Get the serial number of the board we are running on.
         *
         * @return The serial number.
         */
        public string get_serial_number () {
            if (_serial_number == null) {
                set_cpuinfo ();
            }
            return _serial_number;
        }

        void set_model () {
            // This is based on the lookup in flash-kernel, but adds some extra
            // version info when possible

            try {
                // first try looking in device-tree
                string model;
                size_t length;
                var io_channel = new IOChannel.file ("/proc/device-tree/model", "r");
                io_channel.read_to_end (out model, out length);
                _model = model.strip ();
            } catch {
                // if device-tree doesn't work, go for cpuinfo
                if (_hardware == null) {
                    set_cpuinfo ();
                }
                _model = _hardware;
            }
        }

        void set_cpuinfo () {
            // This is based on the lookup in flash-kernel, but adds some extra
            // version info when possible

            try {
                var io_channel = new IOChannel.file ("/proc/cpuinfo", "r");
                string line;
                size_t length;
                size_t term;
                while (io_channel.read_line (out line, out length, out term) == IOStatus.NORMAL) {
                    if (line.length >= 8 && line.substring (0, 8) == "Hardware") {
                        _hardware = line.substring (line.index_of (":") + 1).strip ();
                    }
                    if (line.length >= 8 && line.substring (0, 8) == "Revision") {
                        _revision = line.substring (line.index_of (":") + 1).strip ();
                    }
                    if (line.length >= 6 && line.substring (0, 6) == "Serial") {
                        _serial_number = line.substring (line.index_of (":") + 1).strip ();
                    }
                }
            } catch (Error e) {
                warning ("%s", e.message);
            }

            if (_hardware == null) {
                _hardware = "Unknown";
            }
            if (_revision == null) {
                _revision = "Unknown";
            }
            if (_serial_number == null) {
                _serial_number = "Unknown";
            }
        }
    }
}
