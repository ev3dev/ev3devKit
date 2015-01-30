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
    public enum DCMotorPolarity {
        NORMAL,
        INVERTED;

        internal string to_string () {
            switch (this) {
            case DCMotorPolarity.NORMAL:
                return "normal";
            case DCMotorPolarity.INVERTED:
                return "inverted";
            default:
                critical ("Unknown DCMotorPolarity");
                return "error";
            }
        }

        internal static DCMotorPolarity from_string (string polarity) {
            switch (polarity) {
            case "normal":
                return DCMotorPolarity.NORMAL;
            case "inverted":
                return DCMotorPolarity.INVERTED;
            default:
                critical ("Unknown DCMotorPolarity");
                return (DCMotorPolarity)(-1);
            }
        }
    }

    public class DCMotor : EV3devKit.Devices.Device {
        /**
         * Get a list of supported commands.
         *
         * Possible commands are ``run``, ``coast`` and ``brake``.
         */
        public string[]? commands {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("commands");
            }
        }

        /**
         * Gets the current duty cycle of the motor.
         *
         * Values are -100 to 100. Units are percent(%).
         */
        public int duty_cycle {
            get {
                return (int)(try_read_int ("duty_cycle") ?? 0);
            }
        }

        /**
         * Gets the current duty cycle sepoint of the motor.
         *
         * Values are -100 to 100. Units are percent(%).
         */
        public int duty_cycle_sp {
            get {
                return (int)(try_read_int ("duty_cycle_sp") ?? 0);
            }
        }

        public string driver_name {
            owned get {
                return udev_device.get_sysfs_attr ("driver_name");
            }
        }

        public string port_name {
            owned get {
                return udev_device.get_sysfs_attr ("port_name");
            }
        }

        public int ramp_down_ms {
            get {
                return (int)(try_read_int ("ramp_down_ms") ?? 0);
            }
            set {
                try_write_int ("ramp_down_ms", value);
            }
        }

        public int ramp_up_ms {
            get {
                return (int)(try_read_int ("ramp_up_ms") ?? 0);
            }
            set {
                try_write_int ("ramp_up_ms", value);
            }
        }

        public DCMotorPolarity polarity {
            get {
                return DCMotorPolarity.from_string (try_read_string ("polarity"));
            }
            set {
                try_write_string ("polarity", value.to_string ());
            }
        }

        internal DCMotor (GUdev.Device udev_device) {
            base (udev_device);
        }

        /**
         * Send a command to the motor controller.
         *
         * @param command One of the commands returned by the {@link commands}
         * property.
         * @throws Error if sending the command failed.
         */
        public void send_command (string command) throws Error {
            write_string ("command", command);
        }

        /**
         * Set the duty cycle setpoint for the motor.
         *
         * If ramping setpoints are > 0, then the motor will ramp from the
         * current duty cycle to the new duty cycle setpoint value.
         *
         * @param duty_cycle The new duty cycle setpoint. Valid values are -100
         * to 100.
         * @throws Error if duty_cycle is out of range or there was an I/O error.
         */
        public void set_duty_cycle_sp (int duty_cycle) throws Error {
            write_int ("duty_cycle_sp", duty_cycle);
        }
    }
}