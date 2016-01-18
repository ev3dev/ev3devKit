/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014 WasabiFan
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

using GUdev;

namespace Ev3devKit.Devices {
    /**
     * Represents a port that sensors and motors are plugged into.
     *
     * Ports can be Input Ports and Output Ports on the EV3 itself or on sensor
     * or motor multiplexers or even the ports on the WeDo USB hub.
     */
    public class Port : Ev3devKit.Devices.Device {
        /**
         * The value returned by address for Input Port 1 on the EV3 itself.
         */
        public const string INPUT_1 = "in1";
        /**
         * The value returned by address for Input Port 2 on the EV3 itself.
         */
        public const string INPUT_2 = "in2";
        /**
         * The value returned by address for Input Port 3 on the EV3 itself.
         */
        public const string INPUT_3 = "in3";
        /**
         * The value returned by address for Input Port 4 on the EV3 itself.
         */
        public const string INPUT_4 = "in4";

        /**
         * The value returned by address for Output Port A on the EV3 itself.
         */
        public const string OUTPUT_A = "outA";
        /**
         * The value returned by address for Output Port B on the EV3 itself.
         */
        public const string OUTPUT_B = "outB";
        /**
         * The value returned by address for Output Port C on the EV3 itself.
         */
        public const string OUTPUT_C = "outC";
        /**
         * The value returned by address for Output Port D on the EV3 itself.
         */
        public const string OUTPUT_D = "outD";

        /**
         * Gets the name of the driver that loaded this Port.
         */
        public string driver_name {
            owned get {
                return udev_device.get_property ("LEGO_DRIVER_NAME");
            }
        }

        /**
         * Gets the identifier string.
         *
         * This can be used to match a port to a sensor or motor.
         */
        public string address {
            owned get {
                return udev_device.get_property ("LEGO_ADDRESS");
            }
        }

        /**
         * Gets a list of modes.
         *
         * See the individual port driver documentation for descriptions of the
         * modes.
         */
        public string[]? modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("modes");
            }
        }

        /**
         * Gets the current mode.
         *
         * See the individual port driver documentation for descriptions of the
         * modes.
         */
        public string mode {
            owned get {
                return udev_device.get_sysfs_attr ("mode");
            }
        }

        /**
         * Gets the current status.
         *
         * The status is generally the same as the mode unless there is an
         * ``auto`` mode in which case it may return additional values such as
         * ``no-device`` or ``error``.
         *
         * See the individual port driver documentation for descriptions of the
         * possible values.
         */
        public string status {
            owned get {
                return udev_device.get_sysfs_attr ("status");
            }
        }

        internal Port (GUdev.Device udev_device) {
            base (udev_device);
        }

        /**
         * Sets the mode.
         *
         * @param mode One of the modes returned by the {@link modes} property.
         * @throws Error if setting the mode failed.
         */
        public void set_mode (string mode) throws Error {
            write_string ("mode", mode);
        }

        /**
         * Sets the device connected to this Port.
         *
         * This is only needed for devices that cannot be fully automatically
         * detected, such as Analog/NXT sensors.
         *
         * The device name must match a driver name or no driver will be bound
         * to the device.
         *
         * @param device The name of the device/driver.
         * @throws Error if setting the device failed.
         */
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
