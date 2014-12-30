using GLib;

namespace ev3dev_lang {
    public class LED : Device {
        private string led_device_dir = "/sys/class/leds/";
        public string device_name = "";

        public LED (string device_name) {
            //if (device_name != null)
            this.device_name = device_name;

            try {
                var directory = File.new_for_path (this.led_device_dir);
                var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
                FileInfo device_file;
                while ((device_file = enumerator.next_file ()) != null) {
                    if (device_file.get_file_type () == FileType.DIRECTORY)
                        continue;
                    string device_file_name = device_file.get_name ();
                    if (device_file_name == this.device_name) {
                        this.connect (Path.build_path ("/", this.led_device_dir, device_file_name));
                        return;
                    }
                }
            } catch {}

            this.connected = false;
        }

        //~autogen vala_generic-get-set classes.led>currentClass

        public int max_brightness {
            get {
                return this.read_int ("max_brightness");
            }
        }

        public int brightness {
            get {
                return this.read_int ("brightness");
            }
            set {
                this.write_int ("brightness", value);
            }
        }

        public string trigger {
            owned get {
                return this.read_string ("trigger");
            }
            set {
                this.write_string ("trigger", value);
            }
        }

    //~autogen
    }
}