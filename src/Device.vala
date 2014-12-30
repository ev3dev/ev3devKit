using GLib;

namespace ev3dev_lang {
    public errordomain DeviceError {
        NOT_CONNECTED,
        IO_ERROR
    }

    public class Device : GLib.Object {
        public string device_root { get; protected set; }
        public bool connected { get; protected set; }

        private string connect_error = "You must connect to a device before you can read from it.";
        private string read_error = "There was an error reading from the file";
        private string write_error = "There was an error writing to the file";

        public Device () {}

        public void connect (string device_root_path) {
            this.device_root = device_root_path;
            this.connected = true;
        }

        private string construct_property_path (string property) {
            return GLib.Path.build_filename (this.device_root, property);
        }

        public int read_int (string property) throws DeviceError {
            string str_value = this.read_string (property);

            int result;
            result = int.parse (str_value);

            return result;
        }

        public string read_string (string property) throws DeviceError {
            if (!this.connected)
                throw new DeviceError.NOT_CONNECTED (this.connect_error);

            string result;
            try {
                var file = File.new_for_path (this.construct_property_path (property));
                var input_stream = new DataInputStream (file.read ());
                result = input_stream.read_line ();
            }
            catch (Error error) {
                this.connected = false;
                throw new DeviceError.IO_ERROR (this.read_error + ": " + error.message);
            }

            return result;
        }

        /* Note: All write methods have a limit of 256 bytes to increase write speed */

        public void write_int (string property, int value) throws DeviceError {
            this.write_string (property, value.to_string ());
        }

        public void write_string (string property, string value) throws DeviceError {
            if (!this.connected)
                throw new DeviceError.NOT_CONNECTED (this.connect_error);

            try {
                string property_path = this.construct_property_path (property);
                var file = File.new_for_path (property_path);
                var read_write_stream = file.open_readwrite ();
                var out_stream = new DataOutputStream (new BufferedOutputStream.sized (read_write_stream.output_stream, 256));
                out_stream.put_string (value);
                out_stream.flush ();
            }
            catch (Error error) {
                this.connected = false;
                throw new DeviceError.IO_ERROR (this.write_error + ": " + error.message);
            }
        }
    }
}