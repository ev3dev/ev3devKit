/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
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

using GLib;

namespace EV3DevLang {
    public class PowerSupply : Device {
        /**
         * Gets the maximum design voltage.
         *
         * A full battery should be somewhere around this value.
         */
        public double voltage_max_design {
            get {
                return udev_device.get_sysfs_attr_as_int ("voltage_max_design")
                    / 1000000d;
            }
        }

        /**
         * Gets the minimum design voltage.
         *
         * A empty battery should be somewhere around this value.
         */
        public double voltage_min_design {
            get {
                return udev_device.get_sysfs_attr_as_int ("voltage_min_design")
                    / 1000000d;
            }
        }

        /**
         * Gets the power supply type.
         *
         * The legoev3-battery device will return "Battery".
         *
         * TODO: Convert string to enum.
         */
        public string? supply_type {
            owned get {
                return udev_device.get_sysfs_attr ("type");
            }
        }

        /**
         * Gets the technology type.
         *
         * If the LEGO EV3 rechargable battery pack is being used, it will
         * return "Li-ion", otherwise it will return "Unknown".
         *
         * TODO: Convert string to enum.
         */
        public string? technology {
            owned get {
                return udev_device.get_sysfs_attr ("technology");
            }
        }

        /**
         * Gets the scope.
         *
         * The legoev3-battery device will return "System".
         *
         * TODO: Convert string to enum.
         */
        public string? scope {
            owned get {
                return udev_device.get_sysfs_attr ("scope");
            }
        }

        /**
         * Gets the capacity level.
         *
         * Possible values are "Unknown", "Critical", "Low", "Normal", "High",
         * and "Full"
         *
         * TODO: Convert string to enum.
         */
        public string? capacity_level {
            owned get {
                return udev_device.get_sysfs_attr ("capacity_level");
            }
        }

        /**
         * Gets the current battery voltage in volts.
         */
        public double voltage {
            get {
                return (double)(try_read_int ("voltage_now") ?? 0) / 1000000d;
            }
        }

        /**
         * Gets the current battery current in amps
         */
        public double current {
            get {
                return (double)(try_read_int ("current_now") ?? 0) / 1000000d;
            }
        }

        /**
         * Gets the current battery power in watts
         */
        public double power {
            get {
                var p = try_read_int ("power_now");
                if (p != null)
                    return (double)(p) / 1000000d;
                return voltage * current;
            }
        }

        internal PowerSupply (GUdev.Device udev_device) {
            base (udev_device);
        }
    }
}