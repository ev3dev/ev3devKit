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

namespace ev3dev_lang {
    public class MotorBase : Device {
        protected string port;
        protected string motor_device_dir = "/sys/class/tacho-motor";
        protected int device_index { get; private set; default = -1; }

        public MotorBase (string port = "", string? type = null) {
            this.port = port;
            string root_path = "";

            try {
                var directory = File.new_for_path (this.motor_device_dir);
                var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

                FileInfo device_file;
                while ((device_file = enumerator.next_file ()) != null) {
                    if (device_file.get_file_type () == FileType.DIRECTORY)
                        continue;

                    string device_file_name = device_file.get_name ();

                    root_path = Path.build_path ("/", this.motor_device_dir, device_file_name);

                    string port_name;
                    string motor_type;

                    {
                        //We don't need a bunch of IO streams and such floating around
                        var port_name_file = File.new_for_path (Path.build_path ("/", root_path, "port_name"));
                        var port_input_stream = new DataInputStream (port_name_file.read ());
                        port_name = port_input_stream.read_line ();

                        var type_file = File.new_for_path (Path.build_path ("/", root_path, "type"));
                        var type_input_stream = new DataInputStream (type_file.read ());
                        motor_type = type_input_stream.read_line ();
                    }

                    bool satisfies_condition = (
                        (port == OUTPUT_AUTO) || (port_name == (port))
                    ) && (
                        (type == null || type == "") || motor_type == type
                    );

                    if (satisfies_condition) {
                        this.device_index = int.parse (device_file_name.substring ("motor".length));
                        break;
                    }
                }

                if (this.device_index == -1) {
                    this.connected = false;
                    return;
                }
            } catch {
                this.connected = false;
                return;
            }

            this.connect (root_path);
        }
    }
}