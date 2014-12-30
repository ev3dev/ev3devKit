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
    public class DCMotor : MotorBase {

        public DCMotor (string port = "") {
            this.motor_device_dir = "/sys/class/dc-motor";
            base (port);
        }

        //PROPERTIES

        //~autogen vala_generic-get-set classes.dcMotor>currentClass
        public string command {
            set {
                this.write_string ("command", value);
            }
        }

        public int duty_cycle {
            get {
                return this.read_int ("duty_cycle");
            }
            set {
                this.write_int ("duty_cycle", value);
            }
        }

        public string device_name {
            owned get {
                return this.read_string ("device_name");
            }
        }

        public string port_name {
            owned get {
                return this.read_string ("port_name");
            }
        }

        public int ramp_down_ms {
            get {
                return this.read_int ("ramp_down_ms");
            }
            set {
                this.write_int ("ramp_down_ms", value);
            }
        }

        public int ramp_up_ms {
            get {
                return this.read_int ("ramp_up_ms");
            }
            set {
                this.write_int ("ramp_up_ms", value);
            }
        }

        public string polarity {
            owned get {
                return this.read_string ("polarity");
            }
            set {
                this.write_string ("polarity", value);
            }
        }
        //~autogen
    }
}