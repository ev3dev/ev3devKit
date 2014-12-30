/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
 *
 * Copyright 2014 WasabiFan
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
    public class I2CSensor : Sensor {
        public I2CSensor (string port, string[]? types, string? i2c_address) {
            base (port, types, i2c_address);
        }

        //~autogen vala_generic-get-set classes.i2cSensor>currentClass
        public string fw_version {
            owned get {
                return this.read_string ("fw_version");
            }
        }

        public string address {
            owned get {
                return this.read_string ("address");
            }
        }

        public int poll_ms {
            get {
                return this.read_int ("poll_ms");
            }
            set {
                this.write_int ("poll_ms", value);
            }
        }
        //~autogen
    }
}