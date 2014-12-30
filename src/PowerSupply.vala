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
    public class PowerSupply : Device {
        private string power_device_dir = "/sys/class/power_supply/";
        public string device_name = "legoev3-battery";

        public PowerSupply (string? device_name = "legoev3-battery") {
            if (device_name != null)
                this.device_name = device_name;

            try {
                var directory = File.new_for_path (this.power_device_dir);
                var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

                FileInfo device_file;
                while ((device_file = enumerator.next_file ()) != null) {
                    if (device_file.get_file_type () == FileType.DIRECTORY)
                        continue;

                    string device_file_name = device_file.get_name ();
                    if (device_file_name == this.device_name) {
                        this.connect (Path.build_path ("/", this.power_device_dir, device_file_name));
                        return;
                    }
                }
            }
            catch {}

            this.connected = false;
        }

        //~autogen vala_generic-get-set classes.powerSupply>currentClass

        public int current_now {
            get {
                return this.read_int ("current_now");
            }
        }

        public int voltage_now {
            get {
                return this.read_int ("voltage_now");
            }

        }

        public int voltage_max_design {
            get {
                return this.read_int ("voltage_max_design");
            }
        }

        public int voltage_min_design {
            get {
                return this.read_int ("voltage_min_design");
            }
        }

        public string technology {
            owned get {
                return this.read_string ("technology");
            }
        }

        public string motor_type {
            owned get {
                return this.read_string ("type");
            }
        }

//~autogen

        public double voltage_volts {
            get {
                return (double)this.voltage_now / 1000000d;
            }
        }

        public double current_amps {
            get {
                return (double)this.current_now / 1000000d;
            }
        }
    }
}