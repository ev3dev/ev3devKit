/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
 *
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

namespace EV3DevLang {
    public class Demo : Application {
        DeviceManager manager;
        Port? selected_port;
        Sensor? selected_sensor;

        Demo () {
            Object (application_id: "org.ev3dev.ev3dev-lang-vala-demo",
                flags: ApplicationFlags.HANDLES_COMMAND_LINE);
            manager = new DeviceManager ();
            manager.port_added.connect (on_port_added);
            manager.get_ports ().foreach (on_port_added);
            manager.sensor_added.connect (on_sensor_added);
            manager.get_sensors ().foreach (on_sensor_added);
        }

        void print_menu_items<T> (ApplicationCommandLine command_line) {
            var enum_class = (EnumClass) typeof (T).class_ref ();
            command_line.print ("\n");
            foreach (var enum_value in enum_class.values) {
                var text = enum_value.value_nick.replace ("-", " ");
                command_line.print ("%d. %s\n", enum_value.value, text);
            }
        }

        async int get_input (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            command_line.print ("\nSelect an item: ");
            return int.parse (yield stdin.read_line_async ());
        }

        enum MainMenu {
            PORTS = 1,
            SENSORS,
            QUIT
        }

        async void do_main_menu (ApplicationCommandLine command_line) throws IOError {
            var stdin = new DataInputStream (command_line.get_stdin ());
            // Main Menu
            var done = false;
            while (!done) {
                print_menu_items<MainMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case MainMenu.PORTS:
                    yield do_ports_menu (command_line, stdin);
                    break;
                case MainMenu.SENSORS:
                    yield do_sensors_menu (command_line, stdin);
                    break;
                case MainMenu.QUIT:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        enum PortsMenu {
            SELECT_PORT = 1,
            SHOW_PORT_INFO,
            SELECT_MODE,
            SET_DEVICE,
            MAIN_MENU
        }

        async void do_ports_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<PortsMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case PortsMenu.SELECT_PORT:
                    yield do_select_port (command_line, stdin);
                    break;
                case PortsMenu.SHOW_PORT_INFO:
                    do_show_port_info (command_line);
                    break;
                case PortsMenu.SELECT_MODE:
                    yield do_select_port_mode (command_line, stdin);
                    break;
                case PortsMenu.SET_DEVICE:
                    yield do_port_set_device (command_line, stdin);
                    break;
                case PortsMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        async void do_select_port (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var ports = manager.get_ports ();
            int i = 1;
            ports.foreach ((port) => {
                command_line.print ("%d. %s\n", i, port.name);
                i++;
            });
            command_line.print ("\nSelect Port: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_port = ports[input - 1];
        }

        void do_show_port_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_port == null) {
                command_line.print ("No port selected.\n");
                return;
            }
            command_line.print ("port name: %s\n", selected_port.name);
            command_line.print ("\tmodes: %s\n", string.joinv (", ", selected_port.modes));
            command_line.print ("\tmode: %s\n", selected_port.mode);
            command_line.print ("\tstatus: %s\n", selected_port.status);
        }

        async void do_select_port_mode (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_port == null) {
                command_line.print ("No port selected.\n");
                return;
            }
            int i = 1;
            foreach (var mode in selected_port.modes) {
                command_line.print ("%d. %s\n", i, mode);
                i++;
            }
            command_line.print ("\nSelect Mode: ");
            var cancellable = new Cancellable ();
            var handler_id = selected_port.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            var input = int.parse (yield stdin.read_line_async (Priority.DEFAULT, cancellable));
            selected_port.disconnect (handler_id);
            if (input <= 0 || input >= i) {
                command_line.print ("Invalid Selection.\n");
            } else {
                try {
                    selected_port.set_mode (selected_port.modes[input - 1]);
                } catch (Error err) {
                    command_line.print ("Error: %s\n", err.message);
                }
            }
        }

        async void do_port_set_device (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_port == null) {
                command_line.print ("No port selected.\n");
                return;
            }
            command_line.print ("\nEnter Device Name: ");
            var cancellable = new Cancellable ();
            var handler_id = selected_port.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            var input = yield stdin.read_line_async (Priority.DEFAULT, cancellable);
            selected_port.disconnect (handler_id);
            try {
                selected_port.set_device (input);
            } catch (Error err) {
                command_line.print ("Error: %s\n", err.message);
            }
        }

        enum SensorsMenu {
            SELECT_SENSOR = 1,
            SHOW_SENSOR_INFO,
            WATCH_VALUES,
            SELECT_MODE,
            SEND_COMMAND,
            SET_POLL_MS,
            MAIN_MENU
        }

        async void do_sensors_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<SensorsMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case SensorsMenu.SELECT_SENSOR:
                    yield do_select_sensor (command_line, stdin);
                    break;
                case SensorsMenu.SHOW_SENSOR_INFO:
                    do_show_sensor_info (command_line);
                    break;
                case SensorsMenu.WATCH_VALUES:
                    yield do_watch_sensor_values (command_line, stdin);
                    break;
                case SensorsMenu.SELECT_MODE:
                    yield do_select_sensor_mode (command_line, stdin);
                    break;
                case SensorsMenu.SEND_COMMAND:
                    yield do_send_sensor_command (command_line, stdin);
                    break;
                case SensorsMenu.SET_POLL_MS:
                    yield do_set_sensor_poll_ms (command_line, stdin);
                    break;
                case SensorsMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        async void do_select_sensor (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var sensors = manager.get_sensors ();
            int i = 1;
            sensors.foreach ((sensor) => {
                command_line.print ("%d. %s on %s\n", i, sensor.device_name,
                    sensor.port_name);
                i++;
            });
            command_line.print ("\nSelect Sensor: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_sensor = sensors[input - 1];
        }

        void do_show_sensor_info (ApplicationCommandLine command_line) {
            if (selected_sensor == null) {
                command_line.print ("Sensor not selected.\n");
                return;
            }
            command_line.print ("address: %s\n", selected_sensor.address);
            command_line.print ("fw_version: %s\n", selected_sensor.fw_version);
            command_line.print ("poll_ms: %d\n", selected_sensor.poll_ms);
            command_line.print ("device_name: %s\n", selected_sensor.device_name);
            command_line.print ("port_name: %s\n", selected_sensor.port_name);
            command_line.print ("modes: %s\n", string.joinv (", ", selected_sensor.modes));
            command_line.print ("mode: %s\n", selected_sensor.mode);
            command_line.print ("commands: %s\n", string.joinv (", ", selected_sensor.commands));
            command_line.print ("num_values: %d\n", selected_sensor.num_values);
            command_line.print ("decimals: %d\n", selected_sensor.decimals);
            command_line.print ("units: %s\n", selected_sensor.units);
            var values = new string[selected_sensor.num_values];
            for (int i = 0; i < selected_sensor.num_values; i++) {
                try {
                    values[i] = selected_sensor.get_float_value (i).to_string ();
                } catch (Error err) {
                    values[i] = err.message;
                }
            }
            command_line.print ("value(s): %s\n", string.joinv(", ", values));
        }

        async void do_watch_sensor_values (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_sensor == null) {
                command_line.print ("No sensor selected.\n");
                return;
            }
            command_line.print ("\nPress [Enter] to stop:\n");
            var cancellable = new Cancellable ();
            var handler_id = selected_sensor.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            var source_id = Timeout.add (100, () => {
                var values = new string[selected_sensor.num_values];
                for (int i = 0; i < selected_sensor.num_values; i++) {
                    try {
                        values[i] = selected_sensor.get_float_value (i).to_string ();
                    } catch (Error err) {
                        values[i] = "err";
                    }
                }
                /* \x1B[2K is an escape code to clear the line */
                command_line.print ("\x1B[2K\rvalue(s): %s", string.joinv(", ", values));
                return Source.CONTINUE;
            });
            yield stdin.read_line_async (Priority.DEFAULT, cancellable);
            selected_sensor.disconnect (handler_id);
            Source.remove (source_id);
        }

        async void do_select_sensor_mode (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_sensor == null) {
                command_line.print ("No sensor selected.\n");
                return;
            }
            int i = 1;
            foreach (var mode in selected_sensor.modes) {
                command_line.print ("%d. %s\n", i, mode);
                i++;
            }
            command_line.print ("\nSelect Mode: ");
            var cancellable = new Cancellable ();
            var handler_id = selected_sensor.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            var input = int.parse (yield stdin.read_line_async (Priority.DEFAULT, cancellable));
            selected_sensor.disconnect (handler_id);
            if (input <= 0 || input >= i) {
                command_line.print ("Invalid Selection.\n");
            } else {
                try {
                    selected_sensor.set_mode (selected_sensor.modes[input - 1]);
                } catch (Error err) {
                    command_line.print ("Error: %s\n", err.message);
                }
            }
        }

        async void do_send_sensor_command (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_sensor == null) {
                command_line.print ("No sensor selected.\n");
                return;
            }
            if (selected_sensor.commands.length == 0) {
                command_line.print ("Selected sensor does not have any commands.\n");
                return;
            }
            int i = 1;
            foreach (var command in selected_sensor.commands) {
                command_line.print ("%d. %s\n", i, command);
                i++;
            }
            command_line.print ("\nSelect Command: ");
            var cancellable = new Cancellable ();
            var handler_id = selected_sensor.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            var input = int.parse (yield stdin.read_line_async (Priority.DEFAULT, cancellable));
            selected_sensor.disconnect (handler_id);
            if (input <= 0 || input >= i) {
                command_line.print ("Invalid Selection.\n");
            } else {
                try {
                    selected_sensor.send_command (selected_sensor.commands[input - 1]);
                } catch (Error err) {
                    command_line.print ("Error: %s\n", err.message);
                }
            }
        }

        async void do_set_sensor_poll_ms (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_sensor == null) {
                command_line.print ("No sensor selected.\n");
                return;
            }
            command_line.print ("\nEnter polling period in milliseconds: ");
            var cancellable = new Cancellable ();
            var handler_id = selected_sensor.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            var input = int.parse (yield stdin.read_line_async (Priority.DEFAULT, cancellable));
            selected_sensor.disconnect (handler_id);
            if (input < 0) {
                command_line.print ("Invalid Selection.\n");
            } else {
                try {
                    selected_sensor.set_poll_ms (input);
                } catch (Error err) {
                    command_line.print ("Error: %s\n", err.message);
                }
            }
        }

        public override int command_line (ApplicationCommandLine command_line) {
            hold ();
            do_main_menu.begin (command_line, (obj, res) => {
                try {
                    do_main_menu.end (res);
                } catch (IOError err) {
                    command_line.print (err.message);
                }
                release ();
            });
            return 0;
        }

        static int main (string[] args) {
            var demo = new Demo ();
            return demo.run (args);
        }

        void on_port_added (Port port) {
            message ("Port added: %s", port.name);
            ulong handler_id = 0;
            handler_id = port.notify["connected"].connect (() => {
                message ("Port removed: %s", port.name);
                port.disconnect (handler_id);
            });
        }

        void on_sensor_added (Sensor sensor) {
            message ("Sensor added: %s on %s", sensor.device_name, sensor.port_name);
            ulong handler_id = 0;
            handler_id = sensor.notify["connected"].connect (() => {
                message ("Sensor removed: %s on %s", sensor.device_name, sensor.port_name);
                sensor.disconnect (handler_id);
            });
        }
    }
}