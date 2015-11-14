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

using GLib;

namespace Ev3devKit.Devices {
    /**
     * Represents a power supply, like a battery.
     */
    public class PowerSupply : Device {
        /**
         * Gets the maximum voltage.
         *
         * A full battery should be somewhere around this value.
         */
        public double voltage_max {
            get {
                // TODO: could also look at voltage_max attribute if voltage_max_design is not present.
                return udev_device.get_sysfs_attr_as_int ("voltage_max_design")
                    / 1000000d;
            }
        }

        /**
         * Gets the minimum voltage.
         *
         * An empty battery should be somewhere around this value.
         */
        public double voltage_min {
            get {
                // TODO: could also look at voltage_min attribute if voltage_min_design is not present.
                return udev_device.get_sysfs_attr_as_int ("voltage_min_design")
                    / 1000000d;
            }
        }

        /**
         * Gets the power supply type.
         */
        public SupplyType supply_type {
            get {
                var type = udev_device.get_sysfs_attr ("type");
                return SupplyType.from_string (type ?? "Unknown");
            }
        }

        /**
         * Gets the technology type.
         */
        public Technology technology {
            get {
                var tech = udev_device.get_sysfs_attr ("technology");
                return Technology.from_string (tech ?? "Unknown");
            }
        }

        /**
         * Gets the scope.
         */
        public Scope scope {
            get {
                var scope = udev_device.get_sysfs_attr ("scope");
                return Scope.from_string (scope ?? "Unknown");
            }
        }

        /**
         * Gets the capacity level.
         */
        public CapacityLevel capacity_level {
            get {
                var level = udev_device.get_sysfs_attr ("capacity_level");
                // TODO: Use voltage_min/max_design to calculate if available and level == null
                return CapacityLevel.from_string (level ?? "Unknown");
            }
        }

        /**
         * Checks to see if this power supply can provide {@link voltage}.
         */
        public bool has_voltage {
            get {
                return udev_device.has_property ("POWER_SUPPLY_VOLTAGE_NOW");
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
         * Checks to see if this power supply can provide {@link current}.
         */
        public bool has_current {
            get {
                return udev_device.has_property ("POWER_SUPPLY_CURRENT_NOW");
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
         * Checks to see if this power supply can provide {@link power}.
         */
        public bool has_power {
            get {
                return udev_device.has_property ("POWER_SUPPLY_POWER_NOW") ||
                    (has_voltage && has_current);
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

        /**
         * Represents a battery technology.
         */
        public enum Technology {
            /**
             * Unknown type.
             */
            UNKNOWN,

            /**
             * Nickel–metal hydride battery.
             */
            NIMH,

            /**
             * Lithium-ion battery.
             */
            LION,

            /**
             * Lithium polymer battery.
             */
            LIPO,

            /**
             * Lithium iron phosphate battery.
             */
            LIFE,

            /**
             * Nickel–cadmium battery.
             */
            NICD,

            /**
             * Lithium ion manganese oxide battery.
             */
            LIMN;

            /**
             * Converts a string to a battery technology.
             *
             * Possible values are ``NiMH``, ``Li-ion``, ``Li-poly``, ``LiFe``,
             * ``NiCd``, and ``LiMn``. Anything else will return {@link UNKNOWN}.
             */
            public static Technology from_string (string technology) {
                switch (technology) {
                case "NiMH":
                    return NIMH;
                case "Li-ion":
                    return LION;
                case "Li-poly":
                    return LIPO;
                case "LiFe":
                    return LIFE;
                case "NiCd":
                    return NICD;
                case "LiMn":
                    return LIMN;
                default:
                    return UNKNOWN;
                }
            }

            /**
             * Converts the Technology to a string for display.
             */
            public string to_string () {
                switch (this) {
                case NIMH:
                    return "NiMH";
                case LION:
                    return "Li-ion";
                case LIPO:
                    return "Li-poly";
                case LIFE:
                    return "LiFe";
                case NICD:
                    return "NiCd";
                case LIMN:
                    return "LiMn";
                default:
                    return "Unknown";
                }
            }
        }

        /**
         * Represents the capacity level of a power supply.
         */
        public enum CapacityLevel {
            UNKNOWN,
            CRITICAL,
            LOW,
            NORMAL,
            HIGH,
            FULL;

            /**
             * Converts a string to a capacity level.
             *
             * Possible values are ``Critical``, ``Low``, ``Normal``, ``High``,
             * and ``Full``. Anything else will return {@link UNKNOWN}.
             */
            public static CapacityLevel from_string (string level) {
                switch (level) {
                case "Critical":
                    return CRITICAL;
                case "Low":
                    return LOW;
                case "Normal":
                    return NORMAL;
                case "High":
                    return HIGH;
                case "Full":
                    return FULL;
                default:
                    return UNKNOWN;
                }
            }

            /**
             * Convert the capacity level to a string for display.
             */
            public string to_string () {
                switch (this) {
                case CRITICAL:
                    return "Critical";
                case LOW:
                    return "Low";
                case NORMAL:
                    return "Normal";
                case HIGH:
                    return "High";
                case FULL:
                    return "Full";
                default:
                    return "Unknown";
                }
            }
        }

        /**
         * Represents the type of a power supply.
         */
        public enum SupplyType {
            /**
             * Unknown type.
             */
            UNKNOWN,

            /**
             * Battery.
             */
            BATTERY,

            /**
             * Uninterpretable power supply.
             */
            UPS,

            /**
             * Line power.
             */
            MAINS,

            /**
             * Standard Downstream Port.
             */
            USB,

            /**
             * Dedicated Charging Port.
             */
            USB_DCP,

            /**
             * Charging Downstream Port
             */
            USB_CDP,

            /*
             * Accessory Charger Adapters
             */
            USB_ACA;

            /**
             * Converts a string to a supply type.
             *
             * Possible values are ``Battery``, ``UPS``, ``Mains``, ``USB``,
             * ``USB_DCP``, ``USB_CDP``, and ``USB_ACA``. Anything else will
             * return {@link UNKNOWN}.
             */
            public static SupplyType from_string (string type) {
                switch (type) {
                case "Battery":
                    return BATTERY;
                case "UPS":
                    return UPS;
                case "Mains":
                    return MAINS;
                case "USB":
                    return USB;
                case "USB_DCP":
                    return USB_DCP;
                case "USB_CDP":
                    return USB_CDP;
                case "USB_ACA":
                    return USB_ACA;
                default:
                    return UNKNOWN;
                }
            }

            /**
             * Convert the supply type to a string for display.
             */
            public string to_string () {
                switch (this) {
                case BATTERY:
                    return "Battery";
                case UPS:
                    return "UPS";
                case MAINS:
                    return "Mains";
                case USB:
                    return "USB";
                case USB_DCP:
                    return "USB_DCP";
                case USB_CDP:
                    return "USB_CDP";
                case USB_ACA:
                    return "USB_ACA";
                default:
                    return "Unknown";
                }
            }
        }

        /**
         * Represents the scope of a power supply.
         */
        public enum Scope {
            /**
             * Unknown scope.
             */
            UNKNOWN,

            /**
             * Supplies power to the entire system.
             */
            SYSTEM,

            /**
             * Supplies power to a device attached to the system.
             */
            DEVICE;

            /**
             * Converts a string to a scope.
             *
             * Possible values are ``System`` and ``Device``. Anything else will
             * return {@link UNKNOWN}.
             */
            public static Scope from_string (string scope) {
                switch (scope) {
                case "System":
                    return SYSTEM;
                case "Device":
                    return DEVICE;
                default:
                    return UNKNOWN;
                }
            }

            /**
             * Convert the scope to a string for display.
             */
            public string to_string () {
                switch (this) {
                case SYSTEM:
                    return "System";
                case DEVICE:
                    return "Device";
                default:
                    return "Unknown";
                }
            }
        }
    }
}
