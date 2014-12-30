using GLib;

namespace ev3dev_lang {
    public class Motor : MotorBase {
        public Motor (string port = "", string? type = null) {
            base (port, type);
        }

        public void reset () {
            this.write_int ("reset", 1);
        }

        //PROPERTIES

        //~autogen vala_generic-get-set classes.motor>currentClass
        public int duty_cycle {
            get {
                return this.read_int ("duty_cycle");
            }
        }

        public int duty_cycle_sp {
            get {
                return this.read_int ("duty_cycle_sp");
            }
            set {
                this.write_int ("duty_cycle_sp", value);
            }
        }

        public string encoder_mode {
            owned get {
                return this.read_string ("encoder_mode");
            }
            set {
                this.write_string ("encoder_mode", value);
            }
        }

        public string emergency_stop {
            owned get {
                return this.read_string ("estop");
            }
            set {
                this.write_string ("estop", value);
            }
        }

        public string debug_log {
            owned get {
                return this.read_string ("log");
            }
        }

        public string polarity_mode {
            owned get {
                return this.read_string ("polarity_mode");
            }
            set {
                this.write_string ("polarity_mode", value);
            }
        }

        public string port_name {
            owned get {
                return this.read_string ("port_name");
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

        public string position_mode {
            owned get {
                return this.read_string ("position_mode");
            }
            set {
                this.write_string ("position_mode", value);
            }
        }

        public int position_sp {
            get {
                return this.read_int ("position_sp");
            }
            set {
                this.write_int ("position_sp", value);
            }
        }

        public int pulses_per_second {
            get {
                return this.read_int ("pulses_per_second");
            }
        }

        public int pulses_per_second_sp {
            get {
                return this.read_int ("pulses_per_second_sp");
            }
            set {
                this.write_int ("pulses_per_second_sp", value);
            }
        }

        public int ramp_down_sp {
            get {
                return this.read_int ("ramp_down_sp");
            }
            set {
                this.write_int ("ramp_down_sp", value);
            }
        }

        public int ramp_up_sp {
            get {
                return this.read_int ("ramp_up_sp");
            }
            set {
                this.write_int ("ramp_up_sp", value);
            }
        }

        public string regulation_mode {
            owned get {
                return this.read_string ("regulation_mode");
            }
            set {
                this.write_string ("regulation_mode", value);
            }
        }

        public int run {
            get {
                return this.read_int ("run");
            }
            set {
                this.write_int ("run", value);
            }
        }

        public string run_mode {
            owned get {
                return this.read_string ("run_mode");
            }
            set {
                this.write_string ("run_mode", value);
            }
        }

        public int speed_regulation_p {
            get {
                return this.read_int ("speed_regulation_P");
            }
            set {
                this.write_int ("speed_regulation_P", value);
            }
        }

        public int speed_regulation_i {
            get {
                return this.read_int ("speed_regulation_I");
            }
            set {
                this.write_int ("speed_regulation_I", value);
            }
        }

        public int speed_regulation_d {
            get {
                return this.read_int ("speed_regulation_D");
            }
            set {
                this.write_int ("speed_regulation_D", value);
            }
        }

        public int speed_regulation_k {
            get {
                return this.read_int ("speed_regulation_K");
            }
            set {
                this.write_int ("speed_regulation_K", value);
            }
        }

        public string state {
            owned get {
                return this.read_string ("state");
            }
        }

        public string stop_mode {
            owned get {
                return this.read_string ("stop_mode");
            }
            set {
                this.write_string ("stop_mode", value);
            }
        }

        public int time_sp {
            get {
                return this.read_int ("time_sp");
            }
            set {
                this.write_int ("time_sp", value);
            }
        }

        public string motor_type {
            owned get {
                return this.read_string ("type");
            }
        }

        //~autogen

        public string[] stop_modes {
            owned get {
                return this.read_string ("stop_modes").split (" ");
            }
        }
    }
}