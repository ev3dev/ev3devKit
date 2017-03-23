/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014 WasabiFan
 * Copyright 2015-2016 David Lechner <david@lechnology.com>
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

namespace Ev3devKit.Devices {
    /**
     * Represents a motor with tachometer feedback.
     *
     * The EV3 Large and Medium and NXT motors are this type of motor.
     */
    public class TachoMotor : Ev3devKit.Devices.Device {

        /**
         * Get a list of supported commands.
         *
         * Possible commands are:
         *
         * ``run-forever`` -
         * Causes the motor to run until another command is sent.
         *
         * ``run-to-abs-pos`` -
         * Runs to an absolute position specified by {@link position_sp} and
         * then stop using the command specified by {@link stop_action}.
         *
         * ``run-to-rel-pos`` -
         * Runs to a position relative to the current {@link position} value.
         * The new position will be the current {@link position} + {@link position_sp}.
         * When the new position is reached, the motor will stop using the command
         * specified by {@link stop_action}.
         *
         * ``run-timed`` -
         * Runs the motor for the amount of time specified by {@link time_sp}
         * and then stop the motor using the command specified by {@link stop_action}.
         *
         * ``run-direct`` -
         * Runs the motor at the duty cycle specified by {@link duty_cycle_sp}.
         * Unlike other run commands, changing {@link duty_cycle_sp} while
         * running will take effect immediately.
         *
         * ``stop`` -
         * Stops any of the ``run-*`` commands before they are completed using
         * the command specified by {@link stop_action}.
         *
         * ``reset`` -
         * Resets all of the motor parameter attributes to their default values.
         * This also has the effect of stopping the motor.
         */
        public string[]? commands {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("commands");
            }
        }

        /**
         * Gets the number of tachometer counts in one rotation of the motor.
         *
         * This value is used to convert {@link position} and {@link speed}
         * to/from other units of measurement, such as degrees/s or RPM.
         */
        public int count_per_rot {
            get {
                return udev_device.get_sysfs_attr_as_int ("count_per_rot");
            }
        }

        /**
         * Gets the name of the driver used by the motor.
         *
         * This can be used to identify the type of motor (i.e. EV3 Large motor
         * or EV3 medium motor).
         */
        public string? driver_name {
            owned get {
                return udev_device.get_property ("LEGO_DRIVER_NAME");
            }
        }

        /**
         * Gets the current duty cycle the motor controller is sending to the
         * motor.
         *
         * Value range is 0 to 100%.
         */
        public int duty_cycle {
            get {
                return (int)(try_read_int ("duty_cycle") ?? 0);
            }
        }

        /**
         * Gets and sets the duty cycle setpoint.
         *
         * The duty cycle setpoint is only used with the ``run-direct`` command.
         */
        public int duty_cycle_sp {
            get {
                return (int)(try_read_int ("duty_cycle_sp") ?? 0);
            }
            set {
                try_write_int ("duty_cycle_sp", value);
            }
        }

        /**
         * Gets and sets the position PID constant for the hold PID.
         *
         * You probably don't need to change this unless your are using an
         * unsupported motor.
         */
        public int hold_position_p {
            get {
                return (int)(try_read_int ("hold_pid/Kp") ?? 0);
            }
            set {
                try_write_int ("hold_pid/Kp", value);
            }
        }

        /**
         * Gets and sets the integral PID constant for the hold PID.
         *
         * You probably don't need to change this unless your are using an
         * unsupported motor.
         */
        public int hold_position_i {
            get {
                return (int)(try_read_int ("hold_pid/Ki") ?? 0);
            }
            set {
                try_write_int ("hold_pid/Ki", value);
            }
        }

        /**
         * Gets and sets the derivative PID constant for the hold PID.
         *
         * You probably don't need to change this unless your are using an
         * unsupported motor.
         */
        public int hold_position_d {
            get {
                return (int)(try_read_int ("hold_pid/Kd") ?? 0);
            }
            set {
                try_write_int ("hold_pid/Kd", value);
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
         * Gets the name of the port the motor is connected to.
         *
         * For example, a motor connected to output port A on the EV3 will
         * return ``outA``.
         */
        public string? address {
            owned get {
                return udev_device.get_property ("LEGO_ADDRESS");
            }
        }

        /**
         * Gets the maximum speed of the motor in tachometer counts per second.
         *
         * Use {@link count_per_rot} to convert to other units.
         */
        public int max_speed {
            get {
                return (int)(try_read_int ("max_speed") ?? 0);
            }
        }

        /**
         * Gets and sets the position of the motor.
         *
         * Units are in tachometer counts. Use {@link count_per_rot} to convert
         * to other units. position cannot be set while the motor is running.
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
         * Gets and sets the position setpoint.
         *
         * This setpoint is used by the ``run-to-*-pos`` commands. Units are in
         * tachometer counts. Use {@link count_per_rot} to convert to/from other
         * units. Setting the value will not take effect until a new ``run-*``
         * command is sent.
         */
        public int position_sp {
            get {
                return (int)(try_read_int ("position_sp") ?? 0);
            }
            set {
                try_write_int ("position_sp", value);
            }
        }

        /**
         * Gets the current speed of the motor.
         *
         * Units are in tachometer counts. Use {@link count_per_rot} to convert
         * to other units.
         */
        public int speed {
            get {
                return (int)(try_read_int ("speed") ?? 0);
            }
        }

        /**
         * Gets and sets the speed setpoint.
         *
         * The speed setpoint is used by all of the ``run-*`` commands except for
         * ``run-direct``. Units are in tachometer counts. Use {@link count_per_rot}
         * to convert to/from other units.
         */
        public int speed_sp {
            get {
                return (int)(try_read_int ("speed_sp") ?? 0);
            }
            set {
                try_write_int ("speed_sp", value);
            }
        }

        /**
         * Gets the ramp down time setpoint.
         *
         * Units are in milliseconds. The time specified is the time it will
         * take to ramp the motor down from 100 to 0% duty cycle.
         */
        public int ramp_down_sp {
            get {
                return (int)(try_read_int ("ramp_down_sp") ?? 0);
            }
            set {
                try_write_int ("ramp_down_sp", value);
            }
        }

        /**
         * Gets the ramp up time setpoint.
         *
         * Units are in milliseconds. The time specified is the time it will
         * take to ramp the motor up from 0 to 100% duty cycle.
         */
        public int ramp_up_sp {
            get {
                return (int)(try_read_int ("ramp_up_sp") ?? 0);
            }
            set {
                try_write_int ("ramp_up_sp", value);
            }
        }

        /**
         * Gets and sets the proportional PID constant for the speed regulation PID.
         *
         * You probably don't need to change this unless your are using an
         * unsupported motor.
         */
        public int speed_regulation_p {
            get {
                return (int)(try_read_int ("speed_pid/Kp") ?? 0);
            }
            set {
                try_write_int ("speed_pid/Kp", value);
            }
        }

        /**
         * Gets and sets the integral PID constant for the speed regulation PID.
         *
         * You probably don't need to change this unless your are using an
         * unsupported motor.
         */
        public int speed_regulation_i {
            get {
                return (int)(try_read_int ("speed_pid/Ki") ?? 0);
            }
            set {
                try_write_int ("speed_pid/Ki", value);
            }
        }

        /**
         * Gets and sets the derivative PID constant for the speed regulation PID.
         *
         * You probably don't need to change this unless your are using an
         * unsupported motor.
         */
        public int speed_regulation_d {
            get {
                return (int)(try_read_int ("speed_pid/Kd") ?? 0);
            }
            set {
                try_write_int ("speed_pid/Kd", value);
            }
        }

        /**
         * Gets flags that indicate the state of the motor.
         *
         * Supported flags are {@link MotorStateFlags.RUNNING},
         * {@link MotorStateFlags.RAMPING}, {@link MotorStateFlags.HOLDING},
         * and {@link MotorStateFlags.STALLED}.
         */
        public MotorStateFlags state {
            get {
                return MotorStateFlags.from_strv(try_read_string("state").split(" "));
            }
        }

        /**
         * Gets the current stop action.
         *
         * The stop action tells the motor how it should stop when the ``stop``
         * command is sent or a ``run-*`` command ends on its own. See
         * {@link stop_actions} for a description of possible values.
         */
        public string stop_action {
            owned get {
                return try_read_string ("stop_action") ?? "";
            }
        }

        /**
         * Gets a list of supported stop actions.
         *
         * Possible values are:
         *
         * ``coast`` -
         * Power is removed from the the motor and it will coast to a stop.
         *
         * ``brake`` -
         * Power is removed from the motor and the passive brake function of the
         * motor controller will be enabled. Generally, this means that an
         * electrical load is placed on the motor, causing it to stop more
         * quickly and making it more difficult to turn manually.
         *
         * ``hold`` -
         * Does not remove power from the motor, but rather enables a PID to
         * hold the motor at it's last position. The motor will not be able to
         * be turned manually.
         */
        public string[]? stop_actions {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("stop_actions");
            }
        }

        /**
         * Gets and sets the time setpoint.
         *
         * Units are in milliseconds. The time setpoint is only used by the
         * ``run-timed`` command.
         */
        public int time_sp {
            get {
                return (int)(try_read_int ("time_sp") ?? 0);
            }
            set {
                try_write_int ("time_sp", value);
            }
        }

        internal TachoMotor (GUdev.Device udev_device) {
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
         * Set the stop action for the motor.
         *
         * This action will be used when the motor is stopped. Check
         * {@link stop_actions} to get a list of valid values. Changes to stop
         * action will not take effect until a new ``run-*`` command has been
         * sent using {@link send_command}.
         *
         * @param action The new stop action.
         * @throws Error is action is not a valid action.
         */
        public void set_stop_action (string action) throws Error {
            write_string ("stop_action", action);
        }
    }
}