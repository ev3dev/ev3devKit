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

namespace ev3dev_lang {
    public class ServoMotor : MotorBase {
        public ServoMotor (string port = "") {
            this.motor_device_dir = "/sys/class/servo-motor";
            base (port);
        }

        //PROPERTIES

        //~autogen vala_generic-get-set classes.servoMotor>currentClass
        public string command {
            owned get {
                return this.read_string ("command");
            }
            set {
                this.write_string ("command", value);
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

        public int max_pulse_ms {
            get {
                return this.read_int ("max_pulse_ms");
            }
            set {
                this.write_int ("max_pulse_ms", value);
            }
        }

        public int mid_pulse_ms {
            get {
                return this.read_int ("mid_pulse_ms");
            }
            set {
                this.write_int ("mid_pulse_ms", value);
            }
        }

        public int min_pulse_ms {
            get {
                return this.read_int ("min_pulse_ms");
            }
            set {
                this.write_int ("min_pulse_ms", value);
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

        public int position {
            get {
                return this.read_int ("position");
            }
            set {
                this.write_int ("position", value);
            }
        }

        public int rate {
            get {
                return this.read_int ("rate");
            }
            set {
                this.write_int ("rate", value);
            }
        }

        //~autogen

    }
}