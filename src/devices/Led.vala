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
     * Represents an LED device.
     */
    public class Led : Device {
        /**
         * Device name of the left LEDs on the EV3 brick.
         */
        public const string EV3_LEFT = "led0";

        /**
         * Device name of the right LEDs on the EV3 brick.
         */
        public const string EV3_RIGHT = "led1";

        string _name;
        /**
         * Gets the name of the LED.
         */
        public string name {
            get {
                if (_name == null) {
                    _name = udev_device.get_name ();
                    // strip off the ":brick-status" suffix
                    _name = _name[0:_name.last_index_of (":")];
                    // strip off the color
                    _name = _name[0:_name.last_index_of (":")];
                }
                return _name;
            }
        }

        string _color;
        /**
         * Gets the color of the LED.
         *
         * Returns an empty string if the color is unknown.
         */
        public string color {
            get {
                if (_color == null) {
                    _color = udev_device.get_name ();
                    // strip off the ":brick-status" suffix
                    _color = _color[0:_color.last_index_of (":")];
                    // strip off the name
                    _color = _color.substring (_color.last_index_of (":") + 1);
                }
                return _color;
            }
        }

        /**
         * Gets the maximum allowable brightness value.
         */
        public int max_brightness {
            get {
                return udev_device.get_sysfs_attr_as_int ("max_brightness");
            }
        }

        /**
         * Gets the current brightness value.
         *
         * There is no ``notify`` signal when the brightness value is changed.
         */
        public int brightness {
            get {
                try {
                    return read_int ("brightness");
                } catch {
                    return 0;
                }
            }
        }

        /**
         * Gets the list of available triggers.
         */
        public string[]? triggers {
            owned get {
                var triggers = udev_device.get_sysfs_attr ("trigger");
                if (triggers == null)
                    return null;
                triggers = triggers.replace ("[", "").replace ("]", "");
                return triggers.strip ().split (" ");
            }
        }

        /**
         * Gets the active trigger.
         */
        public string trigger {
            owned get {
                var triggers = udev_device.get_sysfs_attr ("trigger");
                var start_index = triggers.index_of ("[");
                var end_index = triggers.index_of ("]");
                return triggers[start_index + 1:end_index];
            }
        }

        internal Led (GUdev.Device udev_device) {
            base (udev_device);
        }

        /**
         * Sets the brightness.
         *
         * @param brightness Brighness level between 0 and max_brightness.
         * @throws Error if setting the brightness failed or the device was
         * removed.
         */
        public void set_brightness (int brightness) throws Error {
            write_int ("brightness", brightness);
        }

        /**
         * Sets the trigger.
         *
         * @param trigger The name of the trigger. Check {@link triggers} for
         * allowable values.
         * @throws Error if setting the trigger failed or the device was removed.
         */
        public void set_trigger (string trigger) throws Error {
            write_string ("trigger", trigger);
        }

        internal override void change (GUdev.Device udev_device) {
            base.change (udev_device);
            notify_property ("trigger");
        }
    }
}