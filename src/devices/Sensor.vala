/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014 WasabiFan
 * Copyright 2015-2015 David Lechner <david@lechnology.com>
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

namespace EV3devKit.Devices {
    /**
     * Represents a LEGO MINDSTORMS or LEGO WeDo sensor
     */
    public class Sensor : EV3devKit.Devices.Device {
        /**
         * Gets the address.
         *
         * Currently only I2C/NXT sensors use this property. Other sensors will
         * return ``0x00``.
         */
        public string? address {
            get {
                return udev_device.get_sysfs_attr ("address");
            }
        }

        /**
         * Gets the firmware version.
         *
         * Currently only I2C/NXT sensors use this property. Other sensors will
         * return an empty string.
         */
        public string? fw_version {
            get {
                return udev_device.get_sysfs_attr ("fw_version");
            }
        }

        /**
         * Gets the polling period in milliseconds.
         *
         * Currently only I2C/NXT sensors use this property. Other sensors will
         * always return 0.
         */
        public int poll_ms {
            get {
                return udev_device.get_sysfs_attr_as_int ("poll_ms");
            }
        }

        /**
         * Gets the number of decimal places for the value* attributes.
         */
        public int decimals {
            get {
                return udev_device.get_sysfs_attr_as_int ("decimals");
            }
        }

        /**
         * Gets the list of available modes.
         *
         * See the individual sensor driver documentation for information about
         * the modes.
         */
        public string[]? modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("modes");
            }
        }

        /**
         * Gets the current mode.
         *
         * See the individual sensor driver documentation for information about
         * the modes.
         */
        public string mode {
            owned get {
                return udev_device.get_sysfs_attr ("mode");
            }
        }

        /**
         * Gets the list of available commands.
         *
         * Sensors that do not support commands will return ``null``.
         */
        public string[]? commands {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("commands");
            }
        }

        /**
         * Gets the number of valid value attributes.
         */
        public int num_values {
            get {
                return udev_device.get_sysfs_attr_as_int ("num_values");
            }
        }

        /**
         * Gets the name of the port that the sensor is attached to.
         *
         * The port may or may not have a corresponding {@link Port} object
         * depending on how the driver was implemented.
         */
        public string port_name {
            owned get {
                return udev_device.get_sysfs_attr ("port_name");
            }
        }

        /**
         * Gets the units of the value attributes.
         *
         * May be empty string if values are dimensionless or there is more one
         * value attribute and not all of the attributes have the same units.
         */
        public string? units {
            owned get {
                return udev_device.get_sysfs_attr ("units");
            }
        }

        /**
         * Gets the name of the driver that loaded this Sensor.
         */
        public string driver_name {
            owned get {
                return udev_device.get_sysfs_attr ("driver_name");
            }
        }

        internal Sensor (GUdev.Device udev_device) {
            base (udev_device);
        }

        /**
         * Gets the value of a value attribute.
         *
         * @param index The index of the value attribute
         * @return The value read
         * @throws Error if the index is out of range or the device was removed
         */
        public int get_value (int index) throws Error {
            return read_int ("value" + index.to_string ());
        }

        /**
         * Gets the value of a value attribute as a floating point number.
         *
         * @param index The index of the value attribute.
         * @return The value read.
         * @throws Error if the index is out of range or the device was removed.
         */
        public double get_float_value (int index) throws Error {
            var value = (double)get_value (index);
            double decimal_factor = Math.pow10 ((double)decimals);
            return value / decimal_factor;
        }

        /**
         * Sets the mode.
         *
         * @param mode One of the modes returned by the {@link modes} property.
         * @throws Error if setting the mode failed or the device was removed.
         */
        public void set_mode (string mode) throws Error {
            write_string ("mode", mode);
        }

        /**
         * Sends a command to the sensor.
         *
         * @param command One of the commands returned by the {@link commands}
         * property.
         * @throws Error if sending the command failed or the device was removed.
         */
        public void send_command (string command) throws Error {
            write_string ("command", command);
        }

        /**
         * Sets the polling period.
         *
         * @param poll_ms The polling period in milliseconds.
         * @throws Error if setting the polling period is not supported or the
         * device was removed.
         */
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