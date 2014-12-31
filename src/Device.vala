/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
 *
 * Copyright 2014 WasabiFan
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

using GUdev;

namespace EV3DevLang {
    public errordomain DeviceError {
        NOT_CONNECTED,
        IO_ERROR
    }

    public abstract class Device : Object {
        const string connect_error = "You must connect to a device before you can read from it.";
        const string read_error = "There was an error reading from the file";
        const string write_error = "There was an error writing to the file";

        Gee.Map<string, DataInputStream> read_attr_map;
        Gee.Map<string, DataOutputStream> write_attr_map;

        protected GUdev.Device udev_device;

        public bool connected { get; internal set; }

        public Device (GUdev.Device udev_device) {
            read_attr_map = new Gee.HashMap<string, DataInputStream?> ();
            write_attr_map = new Gee.HashMap<string, DataOutputStream?> ();
            this.udev_device = udev_device;
            connected = true;
        }

        internal virtual void change (GUdev.Device udev_device) {
            this.udev_device = udev_device;
        }

        void assert_connected () throws DeviceError {
            if (!_connected)
                throw new DeviceError.NOT_CONNECTED (connect_error);
        }

        string get_property_path (string property) {
            return Path.build_filename (udev_device.get_sysfs_path (), property);
        }

        protected int read_int (string property) throws DeviceError {
            var str_value = read_string (property);
            return int.parse (str_value);
        }

        protected string read_string (string property) throws DeviceError {
            assert_connected ();

            string result;
            try {
                DataInputStream stream;
                if (read_attr_map.has_key (property)) {
                    stream = read_attr_map[property];
                    stream.seek (0, SeekType.SET);
                } else {
                    var file = File.new_for_path (get_property_path (property));
                    stream = new DataInputStream (file.read ());
                    read_attr_map[property] = stream;
                }
                result = stream.read_line ();
            }
            catch (Error error) {
                throw new DeviceError.IO_ERROR (read_error + ": " + error.message);
            }
            return result;
        }

        /* Note: All write methods have a limit of 256 bytes to increase write speed */

        protected void write_int (string property, int value) throws DeviceError {
            write_string (property, value.to_string ());
        }

        protected void write_string (string property, string value) throws DeviceError {
            assert_connected ();

            try {
                string property_path = get_property_path (property);
                var file = File.new_for_path (property_path);
                var read_write_stream = file.open_readwrite ();
                var out_stream = new DataOutputStream (new BufferedOutputStream.sized (read_write_stream.output_stream, 256));
                out_stream.put_string (value);
                out_stream.flush ();
            }
            catch (Error error) {
                throw new DeviceError.IO_ERROR (write_error + ": " + error.message);
            }
        }
    }
}