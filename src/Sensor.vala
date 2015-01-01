/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
 *
 * Copyright 2014 WasabiFan
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

namespace EV3DevLang {
    public class Sensor : EV3DevLang.Device {

        public string? address {
            get {
                return udev_device.get_sysfs_attr ("address");
            }
        }

        public string? fw_version {
            get {
                return udev_device.get_sysfs_attr ("fw_version");
            }
        }

        public int poll_ms {
            get {
                return udev_device.get_sysfs_attr_as_int ("poll_ms");
            }
        }

        public int decimals {
            get {
                return udev_device.get_sysfs_attr_as_int ("decimals");
            }
        }

        public string[]? modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("modes");
            }
        }

        public string mode {
            owned get {
                return udev_device.get_sysfs_attr ("mode");
            }
        }

        public string[]? commands {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("commands");
            }
        }

        public int num_values {
            get {
                return udev_device.get_sysfs_attr_as_int ("num_values");
            }
        }

        public string port_name {
            owned get {
                return udev_device.get_sysfs_attr ("port_name");
            }
        }

        public string? units {
            owned get {
                return udev_device.get_sysfs_attr ("units");
            }
        }

        public string device_name {
            owned get {
                return udev_device.get_sysfs_attr ("device_name");
            }
        }

        internal Sensor (GUdev.Device udev_device) {
            base (udev_device);
        }

        public int get_value (int index) throws Error {
            return read_int ("value" + index.to_string ());
        }

        public double get_float_value (int index) throws Error {
            var value = (double)get_value (index);
            double decimal_factor = Math.pow10 ((double)decimals);
            return value / decimal_factor;
        }

        public void set_mode (string mode) throws Error {
            write_string ("mode", mode);
        }

        public void send_command (string command) throws Error {
            write_string ("command", command);
        }

        public void set_poll_ms (int poll_ms) throws Error {
            write_int ("poll_ms", poll_ms);
        }

        internal override void change (GUdev.Device udev_device) {
            base.change (udev_device);
            notify_property ("mode");
            notify_property ("decimals");
            notify_property ("units");
            notify_property ("num-values");
            notify_property ("poll-ms");
        }
    }
}