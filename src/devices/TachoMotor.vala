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
         * then stop using the command specified by {@link stop_command}.
         *
         * ``run-to-rel-pos`` -
         * Runs to a position relative to the current {@link position} value.
         * The new position will be the current {@link position} + {@link position_sp}.
         * When the new position is reached, the motor will stop using the command
         * specified by {@link stop_command}.
         *
         * ``run-timed`` -
         * Runs the motor for the amount of time specified by {@link time_sp}
         * and then stop the motor using the command specified by {@link stop_command}.
         *
         * ``run-direct`` -
         * Runs the motor at the duty cycle specified by {@link duty_cycle_sp}.
         * Unlike other run commands, changing {@link duty_cycle_sp} while
         * running will take effect immediately. {@link speed_regulation} is
         * ignored.
         *
         * ``stop`` -
         * Stops any of the ``run-*`` commands before they are completed using
         * the command specified by {@link stop_command}.
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
                return udev_device.get_sysfs_attr ("driver_name");
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
         * The duty cycle setpoint is only used when {@link speed_regulation}
         * is off (``false``). Changes do not take effect until a ``run-*``
         * command is sent (except when using ``run-direct``).
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
         * Gets and sets the shaft encoder polarity of the motor.
         *
         * This is used as a workaround for motors whose shaft encoder has
         * inverted signals. Most likely you don't need this unless you are
         * using an unsupported motor.
         */
        public MotorPolarity encoder_polarity {
            get {
                return MotorPolarity.from_string (try_read_string ("encoder_polarity"));
            }
            set {
                try_write_string ("encoder_polarity", value.to_string ());
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
                return udev_device.get_sysfs_attr ("address");
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
         * The speed setpoint is only used when {@link speed_regulation} is on
         * (``true``). Units are in tachometer counts. Use {@link count_per_rot}
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
         * Gets and sets the speed regulation control state.
         *
         * Speed regulation uses a PID to ensure that the motor turns at a
         * constant speed regardless of the load on the motor and the state
         * of the batteries.
         *
         * Setting to ``true`` will turn speed regulation on. Setting to ``false``
         * will turn speed regulation off.
         *
         * Changing this value will not have an effect until a new ``run-*``
         * command is sent.
         */
        public bool speed_regulation {
            get {
                return (try_read_string ("speed_regulation") ?? "") == "on";
            }
            set {
                try_write_string ("speed_regulation", value ? "on" : "off");
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
         * Gets the current stop command.
         *
         * The stop command tells the motor how it should stop when the ``stop``
         * command is sent or a ``run-*`` command ends on its own. See
         * {@link stop_commands} for a description of possible values.
         */
        public string stop_command {
            owned get {
                return try_read_string ("stop_command") ?? "";
            }
        }

        /**
         * Gets a list of supported stop commands.
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
        public string[]? stop_commands {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("stop_commands");
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
         * Set the stop command for the motor.
         *
         * This command will be used when the motor is stopped. Check
         * {@link stop_commands} to get a list of valid values. Changes to stop
         * command will not take effect until a new ``run-*`` command has been
         * sent using {@link send_command}.
         *
         * @param command The new stop command.
         * @throws Error is command is not a valid command.
         */
        public void set_stop_command (string command) throws Error {
            write_string ("stop_command", command);
        }
    }
}