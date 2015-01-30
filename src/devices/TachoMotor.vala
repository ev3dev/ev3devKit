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
    public class TachoMotor : EV3devKit.Devices.Device {
        public int duty_cycle {
            get {
                return (int)(try_read_int ("duty_cycle") ?? 0);
            }
        }

        public int duty_cycle_sp {
            get {
                return (int)(try_read_int ("duty_cycle_sp") ?? 0);
            }
            set {
                try_write_int ("duty_cycle_sp", value);
            }
        }

        public string encoder_mode {
            owned get {
                return try_read_string ("encoder_mode") ?? "";
            }
            set {
                try_write_string ("encoder_mode", value);
            }
        }

        public string[]? encoder_modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("encoder_modes");
            }
        }

        public string emergency_stop {
            owned get {
                return try_read_string ("estop") ?? "";
            }
            set {
                try_write_string ("estop", value);
            }
        }

        public string polarity_mode {
            owned get {
                return try_read_string ("polarity_mode") ?? "";
            }
            set {
                try_write_string ("polarity_mode", value);
            }
        }

        public string[]? polarity_modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("polarity_modes");
            }
        }

        public string? port_name {
            owned get {
                return udev_device.get_sysfs_attr ("port_name");
            }
        }

        public int position {
            get {
                return (int)(try_read_int ("position") ?? 0);
            }
            set {
                try_write_int ("position", value);
            }
        }

        public string position_mode {
            owned get {
                return try_read_string ("position_mode") ?? "";
            }
            set {
                try_write_string ("position_mode", value);
            }
        }

        public string[]? position_modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("position_modes");
            }
        }

        public int position_sp {
            get {
                return (int)(try_read_int ("position_sp") ?? 0);
            }
            set {
                try_write_int ("position_sp", value);
            }
        }

        public int pulses_per_second {
            get {
                return (int)(try_read_int ("pulses_per_second") ?? 0);
            }
        }

        public int pulses_per_second_sp {
            get {
                return (int)(try_read_int ("pulses_per_second_sp") ?? 0);
            }
            set {
                try_write_int ("pulses_per_second_sp", value);
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

        public string regulation_mode {
            owned get {
                return try_read_string ("regulation_mode") ?? "";
            }
            set {
                try_write_string ("regulation_mode", value);
            }
        }

        public string[]? regulation_modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("regulation_modes");
            }
        }

        public int run {
            get {
                return (int)(try_read_int ("run") ?? 0);
            }
            set {
                try_write_int ("run", value);
            }
        }

        public string run_mode {
            owned get {
                return try_read_string ("run_mode") ?? "";
            }
            set {
                try_write_string ("run_mode", value);
            }
        }

        public string[]? run_modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("run_modes");
            }
        }

        public int speed_regulation_p {
            get {
                return (int)(try_read_int ("speed_regulation_P") ?? 0);
            }
            set {
                try_write_int ("speed_regulation_P", value);
            }
        }

        public int speed_regulation_i {
            get {
                return (int)(try_read_int ("speed_regulation_I") ?? 0);
            }
            set {
                try_write_int ("speed_regulation_I", value);
            }
        }

        public int speed_regulation_d {
            get {
                return (int)(try_read_int ("speed_regulation_D") ?? 0);
            }
            set {
                try_write_int ("speed_regulation_D", value);
            }
        }

        public int speed_regulation_k {
            get {
                return (int)(try_read_int ("speed_regulation_K") ?? 0);
            }
            set {
                try_write_int ("speed_regulation_K", value);
            }
        }

        public string state {
            owned get {
                return try_read_string ("state") ?? "";
            }
        }

        public string stop_mode {
            owned get {
                return try_read_string ("stop_mode") ?? "";
            }
            set {
                try_write_string ("stop_mode", value);
            }
        }

        public string[]? stop_modes {
            owned get {
                return udev_device.get_sysfs_attr_as_strv ("stop_modes");
            }
        }

        public int time_sp {
            get {
                return (int)(try_read_int ("time_sp") ?? 0);
            }
            set {
                try_write_int ("time_sp", value);
            }
        }

        public string? motor_type {
            owned get {
                return udev_device.get_sysfs_attr ("type");
            }
        }

        internal TachoMotor (GUdev.Device udev_device) {
            base (udev_device);
        }

        public void reset () {
            try_write_int ("reset", 1);
        }
    }
}