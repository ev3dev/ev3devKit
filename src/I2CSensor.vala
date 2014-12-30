using GLib;

namespace ev3dev_lang {
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