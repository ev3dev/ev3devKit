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

using GUdev;

namespace EV3DevLang {
    public class Sensor : EV3DevLang.Device {

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

        public int get_value (int index) {
            return read_int ("value" + index.to_string ());
        }

        public double get_float_value (int index) {
            var value = (double)get_value (index);
            double decimal_factor = Math.pow10 ((double)decimals);
            return value / decimal_factor;
        }

        internal Sensor (GUdev.Device udev_device) {
            base (udev_device);
        }

        internal override void change (GUdev.Device udev_device) {
            base.change (udev_device);
            notify_property ("mode");
            notify_property ("decimals");
            notify_property ("units");
            notify_property ("num-values");
        }
    }
}