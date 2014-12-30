/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
 *
 * Copyright 2014 WasabiFan
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

using GLib;

namespace EV3DevLang {
    public class Sensor : Device {
        private string port;
        private const string sensor_device_dir = "/sys/class/lego-sensor";
        private int device_index { get; private set; default = -1; }

        public Sensor (string port = "", string[]? types = null, string? i2c_address = null) {
            this.port = port;
            string root_path = "";

            try {
                var directory = File.new_for_path (this.sensor_device_dir);
                var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

                FileInfo device_file;
                while ((device_file = enumerator.next_file ()) != null) {
                    if (device_file.get_file_type () == FileType.DIRECTORY)
                        continue;

                    string device_file_name = device_file.get_name ();

                    root_path = Path.build_path ("/", this.sensor_device_dir, device_file_name);

                    string port_name;
                    string type_name;
                    string i2c_device_address; {
                        //We don't need a bunch of IO streams and such floating around
                        var port_name_file = File.new_for_path (Path.build_path ("/", root_path, "port_name"));
                        var port_input_stream = new DataInputStream (port_name_file.read ());
                        port_name = port_input_stream.read_line ();

                        var type_file = File.new_for_path (Path.build_path ("/", root_path, "name"));
                        var type_input_stream = new DataInputStream (type_file.read ());
                        type_name = type_input_stream.read_line ();

                        var i2c_file = File.new_for_path (Path.build_path ("/", root_path, "address"));
                        var i2c_input_stream = new DataInputStream (i2c_file.read ());
                        i2c_device_address = i2c_input_stream.read_line ();
                    }

                    bool satisfies_condition = (
                        (port == INPUT_AUTO) || (port_name == port)
                    ) && (
                        (types == null || types.length < 1) || type_name in types
                    ) && (
                        i2c_address == null || i2c_address == i2c_device_address
                    );

                    if (satisfies_condition) {
                        this.device_index = int.parse (device_file_name.substring ("sensor".length));
                        break;
                    }
                }

                if (this.device_index == -1) {
                    this.connected = false;
                    return;
                }
            }
            catch {
                this.connected = false;
                return;
            }

            this.connect (root_path);
        }

        public int get_value (int value_index) {
            return this.read_int ("value" + value_index.to_string ());
        }

        public double get_float_value (int value_index) {
            double decimal_factor = Math.pow (10d, (double)this.read_int ("dp"));
            return (double)this.read_int ("value" + value_index.to_string ()) / decimal_factor;
        }

        //PROPERTIES

        //~autogen vala_generic-get-set classes.sensor>currentClass
        public int decimals {
            get {
                return this.read_int ("decimals");
            }
        }

        public string mode {
            owned get {
                return this.read_string ("mode");
            }
            set {
                this.write_string ("mode", value);
            }
        }

        public string command {
            set {
                this.write_string ("command", value);
            }
        }

        public int num_values {
            get {
                return this.read_int ("num_values");
            }
        }

        public string port_name {
            owned get {
                return this.read_string ("port_name");
            }
        }

        public string units {
            owned get {
                return this.read_string ("units");
            }
        }

        public string device_name {
            owned get {
                return this.read_string ("device_name");
            }
        }
        //~autogen
    }
}