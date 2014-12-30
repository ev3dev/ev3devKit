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