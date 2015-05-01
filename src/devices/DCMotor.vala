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
     * Represents a simple DC motor.
     */
    public class DCMotor : EV3devKit.Devices.Device {
        /**
         * Get a list of supported commands.
         *
         * Possible commands are ``run-forever``, ``run-timed``, and ``stop``.
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
         * Gets the current duty cycle setpoint of the motor.
         *
         * Values are -100 to 100. Units are percent(%).
         */
        public int duty_cycle_sp {
            get {
                return (int)(try_read_int ("duty_cycle_sp") ?? 0);
            }
        }

        public string? driver_name {
            owned get {
                return udev_device.get_sysfs_attr ("driver_name");
            }
        }

        public string? port_name {
            owned get {
                return udev_device.get_sysfs_attr ("port_name");
            }
        }

        public int ramp_down_sp {
            get {
                return (int)(try_read_int ("ramp_down_sp") ?? 0);
            }
            set {
                try_write_int ("ramp_down_sp", value);
            }
        }

        public int ramp_up_sp {
            get {
                return (int)(try_read_int ("ramp_up_sp") ?? 0);
            }
            set {
                try_write_int ("ramp_up_sp", value);
            }
        }

        /**
         * Gets and sets the polarity of the motor.
         *
         * This can be used to invert the positive and negative directions.
         * For example, if you have two motors that are used for driving (left
         * and right), you can invert the polarity of the left motor so
         * that a positive position causes both servos to drive forwards.
         */
        public MotorPolarity polarity {
            get {
                return MotorPolarity.from_string (try_read_string ("polarity"));
            }
            set {
                try_write_string ("polarity", value.to_string ());
            }
        }

        /**
         * Gets flags that indicate the state of the motor.
         *
         * Supported flags are {@link MotorStateFlags.RUNNING} and
         * {@link MotorStateFlags.RAMPING}.
         */
        public MotorStateFlags state {
            get {
                return MotorStateFlags.from_strv(try_read_string("state").split(" "));
            }
        }

        public string[]? stop_commands {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("stop_commands");
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

        /**
         * Set the time setpoint in milliseconds for the motor.
         *
         * The time setpoint is used by the `run-timed` command.
         *
         * @param time The new time setpoint in milliseconds.
         * @throws Error if time is out of range or there was an I/O error.
         */
        public void set_time_sp (int time) throws Error {
            write_int ("time_sp", time);
        }

        /**
         * Set the stop command for the motor.
         *
         * This command will be used when the motor is stopped. Check
         * {@link stop_commands} to get a list of valid values. Changes to stop
         * command will not take effect until a new command has been sent using
         * {@link send_command}.
         *
         * @param command The new stop command.
         * @throws Error is command is not a valid command.
         */
        public void set_stop_command (string command) throws Error {
            write_string ("stop_command", command);
        }
    }
}