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
    public class Port : EV3DevLang.Device {
        public const string INPUT_AUTO = "";
        public const string OUTPUT_AUTO = "";

        public const string INPUT_1 = "in1";
        public const string INPUT_2 = "in2";
        public const string INPUT_3 = "in3";
        public const string INPUT_4 = "in4";

        public const string OUTPUT_A = "outA";
        public const string OUTPUT_B = "outB";
        public const string OUTPUT_C = "outC";
        public const string OUTPUT_D = "outD";

        public string name {
            owned get {
                return udev_device.get_property ("LEGO_PORT_NAME");
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

        public string status {
            owned get {
                return udev_device.get_sysfs_attr ("status");
            }
        }

        internal Port (GUdev.Device udev_device) {
            base (udev_device);
        }

        public void set_mode (string mode) throws Error {
            write_string ("mode", mode);
        }

        public void set_device (string device) throws Error {
            write_string ("set_device", device);
        }

        internal override void change (GUdev.Device udev_device) {
            base.change (udev_device);
            notify_property ("mode");
            notify_property ("status");
        }
    }
}
