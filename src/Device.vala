/*
 * ev3dev-lang-glib - GLib library for interacting with ev3dev kernel drivers
 *
 * Copyright 2014 WasabiFan
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

using GUdev;

namespace EV3DevLang {
    public errordomain DeviceError {
        NOT_CONNECTED
    }

    public abstract class Device : Object {
        const string connect_error = "You must connect to a device before you can read from it.";
        const string read_error = "There was an error reading from the file";
        const string write_error = "There was an error writing to the file";

        Gee.Map<string, DataInputStream> read_attr_map;
        Gee.Map<string, DataOutputStream> write_attr_map;

        protected GUdev.Device udev_device;

        /**
         * Gets the connection status of the device.
         *
         * Returns false if the device has been removed otherwise returns true.
         */
        public bool connected { get; internal set; }

        public string device_name {
            get {
                return udev_device.get_name ();
            }
        }

        protected Device (GUdev.Device udev_device) {
            read_attr_map = new Gee.HashMap<string, DataInputStream?> ();
            write_attr_map = new Gee.HashMap<string, DataOutputStream?> ();
            this.udev_device = udev_device;
            connected = true;
        }

        /**
         * This is called when udev receives a ``change`` event from the kernel.
         *
         * The udev_device object is replaced so that we get the new cached
         * property and attribute values from udev.
         *
         * Overrideing methods must call the base () method.
         */
        internal virtual void change (GUdev.Device udev_device) {
            this.udev_device = udev_device;
        }

        /**
         * Test if device is still connected.
         *
         * Since GObject properties cannot throw exceptions, this method can be
         * used to confirm that a device is still connected before reading
         * properties.
         *
         * @throws DeviceError.NOT_CONNECTED if device is not connected.
         */
        public void assert_connected () throws DeviceError {
            if (!_connected)
                throw new DeviceError.NOT_CONNECTED (connect_error);
        }

        string get_property_path (string property) {
            return Path.build_filename (udev_device.get_sysfs_path (), property);
        }

        /**
         * Reads an attribute value as an int.
         *
         * For values that do not change or if a change is signaled by a kernel
         * uevent, then GUdev.get_sysattr_as_int should be used instead.
         *
         * @param property The name of the sysfs attribute to write to.
         * @return The value that was read.
         * @throws Error if there was an error while reading.
         */
        protected int read_int (string property) throws Error {
            var str_value = read_string (property);
            return int.parse (str_value);
        }

        /**
         * Reads an attribute value as an int.
         *
         * @param property The name of the sysfs attribute to write to.
         * @return The value that was read or ``null`` if there was an error
         * while reading.
         */
        protected int? try_read_int (string property) {
            try {
                return read_int (property);
            } catch (Error err) {
                return null;
            }
        }

        /**
         * Reads an attribute value as a string.
         *
         * For values that do not change or if a change is signaled by a kernel
         * uevent, then GUdev.get_sysattr should be used instead.
         *
         * @param property The name of the sysfs attribute to write to.
         * @return The value that was read.
         * @throws Error if there was an error while reading.
         */
        protected string read_string (string property) throws Error {
            assert_connected ();
            DataInputStream stream;
            if (read_attr_map.has_key (property)) {
                stream = read_attr_map[property];
                stream.seek (0, SeekType.SET);
            } else {
                var file = File.new_for_path (get_property_path (property));
                stream = new DataInputStream (file.read ());
                read_attr_map[property] = stream;
            }
            return stream.read_line ();
        }

        /**
         * Reads an attribute value as a string.
         *
         * @param property The name of the sysfs attribute to write to.
         * @return The value that was read or ``null`` if there was an error
         * while reading.
         */
        protected string? try_read_string (string property) {
            try {
                return read_string (property);
            } catch (Error err) {
                return null;
            }
        }

        /* Note: All write methods have a limit of 256 bytes to increase write speed */

        /**
         * Writes an int value to a sysfs attribute.
         *
         * @param property The name of the sysfs attribute to write to.
         * @param value The value to write to the attribute.
         * @throws Error if writing failed.
         */
        protected void write_int (string property, int value) throws Error {
            write_string (property, value.to_string ());
        }

        /**
         * Writes an int value to a sysfs attribute.
         *
         * @param property The name of the sysfs attribute to write to.
         * @param value The value to write to the attribute.
         * @return False if there was an error while writing, otherwise true.
         */
        protected bool try_write_int (string property, int value) {
            try {
                write_int (property, value);
                return true;
            } catch (Error err) {
                return false;
            }
        }

        /**
         * Writes a string value to a sysfs attribute.
         *
         * @param property The name of the sysfs attribute to write to.
         * @param value The value to write to the attribute.
         * @throws Error if writing failed.
         */
        protected void write_string (string property, string value) throws Error {
            assert_connected ();
            string property_path = get_property_path (property);
            var file = File.new_for_path (property_path);
            var output_stream = file.replace (null, false, FileCreateFlags.NONE);
            var buffered_stream = new BufferedOutputStream.sized (output_stream, 256);
            var out_stream = new DataOutputStream (buffered_stream);
            out_stream.put_string (value);
            out_stream.flush ();
        }

        /**
         * Writes a string value to a sysfs attribute.
         *
         * @param property The name of the sysfs attribute to write to.
         * @param value The value to write to the attribute.
         * @return False if there was an error while writing, otherwise true.
         */
        protected bool try_write_string (string property, string value) {
            try {
                write_string (property, value);
                return true;
            } catch (Error err) {
                return false;
            }
        }
    }
}