/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
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

namespace EV3devKit.Devices {
    /**
     * Represents a hobby type servo motor.
     */
    public class ServoMotor : EV3devKit.Devices.Device {
        /**
         * Gets the name of the driver that loaded this device.
         */
        public string? driver_name {
            owned get {
                return udev_device.get_sysfs_attr ("driver_name");
            }
        }

        /**
         * Gets the name of the port this device is connected to.
         *
         * The port name may or may not correspond to an actual Port object.
         */
        public string? port_name {
            owned get {
                return udev_device.get_sysfs_attr ("port_name");
            }
        }

        /**
         * Gets and sets the current command.
         */
        public string command {
            owned get {
                return try_read_string ("command") ?? "";
            }
            set {
                try_write_string ("command", value);
            }
        }

        /**
         * Gets and sets the calibration value for the maximum value.
         *
         * For example, on a 180 degree servo, 2500 microseconds should be the
         * drive the motor to +90 degrees. If the actual rotation is not +90
         * degrees, this value can be adjusted to correct the error.
         */
        public int max_pulse_ms {
            get {
                return (int)(try_read_int ("max_pulse_ms") ?? 0);
            }
            set {
                try_write_int ("max_pulse_ms", value);
            }
        }

        /**
         * Gets and sets the calibration value for the center value.
         *
         * For example, on a 180 degree servo, 1500 microseconds should be the
         * drive the motor to the center position (0 degrees). If the actual
         * rotation is not 0 degrees, this value can be adjusted to correct the
         * error.
         */
        public int mid_pulse_ms {
            get {
                return (int)(try_read_int ("mid_pulse_ms") ?? 0);
            }
            set {
                try_write_int ("mid_pulse_ms", value);
            }
        }

        /**
         * Gets and sets the calibration value for the minimum value.
         *
         * For example, on a 180 degree servo, 500 microseconds should be the
         * drive the motor to -90 degrees. If the actual rotation is not -90
         * degrees, this value can be adjusted to correct the error.
         */
        public int min_pulse_ms {
            get {
                return (int)(try_read_int ("min_pulse_ms") ?? 0);
            }
            set {
                try_write_int ("min_pulse_ms", value);
            }
        }

        /**
         * Gets and sets the polarity of the motor.
         *
         * This can be used to invert the positive and negative directions.
         * For example, if you have two continuous rotation servos that are
         * used for driving, you can invert the polarity of the left motor so
         * that a positive position causes both servos to drive forwards.
         */
        public string polarity {
            owned get {
                return try_read_string ("polarity") ?? "";
            }
            set {
                try_write_string ("polarity", value);
            }
        }

        /**
         * Gets and sets the current position setpoint.
         *
         * The value is -100 to 100. For example, on a 180 degree servo, -100
         * will drive the motor to -90 degrees, 0 will be the center position
         * and 100 will drive the motor to +90 degrees.
         */
        public int position {
            get {
                return (int)(try_read_int ("position") ?? 0);
            }
            set {
                try_write_int ("position", value);
            }
        }

        /**
         * Gets and sets the current rate for the servo.
         *
         * The rate is how long it takes the servo to move from 0 to 100. In
         * other words, full travel from a position of-100 to a position of
         * 100 will take two times the rate.
         *
         * Units are milliseconds. A rate of 0 means 'as fast as possible'.
         */
        public int rate {
            get {
                return (int)(try_read_int ("rate") ?? 0);
            }
            set {
                try_write_int ("rate", value);
            }
        }

        internal ServoMotor (GUdev.Device udev_device) {
            base (udev_device);
        }
    }
}