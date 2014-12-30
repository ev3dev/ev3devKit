using GLib;

namespace ev3dev_lang {
    public class PowerSupply : Device {
        private string power_device_dir = "/sys/class/power_supply/";
        public string device_name = "legoev3-battery";

        public PowerSupply (string? device_name = "legoev3-battery") {
            if (device_name != null)
                this.device_name = device_name;

            try {
                var directory = File.new_for_path (this.power_device_dir);
                var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

                FileInfo device_file;
                while ((device_file = enumerator.next_file ()) != null) {
                    if (device_file.get_file_type () == FileType.DIRECTORY)
                        continue;

                    string device_file_name = device_file.get_name ();
                    if (device_file_name == this.device_name) {
                        this.connect (Path.build_path ("/", this.power_device_dir, device_file_name));
                        return;
                    }
                }
            }
            catch {}

            this.connected = false;
        }

        //~autogen vala_generic-get-set classes.powerSupply>currentClass

        public int current_now {
            get {
                return this.read_int ("current_now");
            }
        }

        public int voltage_now {
            get {
                return this.read_int ("voltage_now");
            }

        }

        public int voltage_max_design {
            get {
                return this.read_int ("voltage_max_design");
            }
        }

        public int voltage_min_design {
            get {
                return this.read_int ("voltage_min_design");
            }
        }

        public string technology {
            owned get {
                return this.read_string ("technology");
            }
        }

        public string motor_type {
            owned get {
                return this.read_string ("type");
            }
        }

//~autogen

        public double voltage_volts {
            get {
                return (double)this.voltage_now / 1000000d;
            }
        }

        public double current_amps {
            get {
                return (double)this.current_now / 1000000d;
            }
        }
    }
}