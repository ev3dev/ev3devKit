/*
 * ev3dev-lang-vala - vala library for interacting with LEGO MINDSTORMS EV3
 * hardware on bricks running ev3dev
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
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
        [Compact]
        class MenuItem {
            public string text;
            public Menu? submenu;
        }

        [Compact]
        class Menu {
            public unowned Menu? parent;
            public MenuItem[] menu_items;
        }

        Menu main_menu = new Menu () {
            menu_items = {
                new MenuItem () {
                    text = "Ports",
                    submenu = new Menu () {
                        menu_items = { 
                            new MenuItem () {
                                text = "Select Port"
                            }
                        }
                    }
                },
                new MenuItem () {
                    text = "Sensors",
                    submenu = new Menu () {
                        menu_items = {
                            new MenuItem () {
                                text = "Select Sensor"
                            }
                        }
                    }
                }
            }
        };

        DeviceManager manager;
        unowned Menu current_menu;
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
            current_menu = main_menu;
        }

        async void handle_input (ApplicationCommandLine command_line) {
            var stdin = new DataInputStream (command_line.get_stdin ());
            while (true) {
                command_line.print ("\n");
                int i = 1;
                foreach (unowned MenuItem item in current_menu.menu_items) {
                    command_line.print ("%d. %s\n", i, item.text);
                    i++;
                }
                if (current_menu.parent == null)
                    command_line.print ("%d. Quit\n", i);
                else
                    command_line.print ("%d. Back\n", i);
                command_line.print ("\nSelect an item: ");
                try {
                    var input = int.parse (yield stdin.read_line_async ());
                    if (input <= 0 || input > i) {
                        command_line.print ("Invalid selection.\n");
                    } else if (input == i) {
                        // Quit
                        if (current_menu.parent == null)
                            break;
                        // Back
                        current_menu = current_menu.parent;
                    } else {
                        unowned MenuItem selected_item = current_menu.menu_items[input - 1];
                        if (selected_item.submenu != null) {
                            selected_item.submenu.parent = current_menu;
                            current_menu = selected_item.submenu;
                        } else if (selected_item.text == "Select Port") {
                            yield select_port (command_line, stdin);
                        } else if (selected_item.text == "Select Sensor") {
                            yield select_sensor (command_line, stdin);
                        } else {
                            command_line.print ("Nothing to do.\n");
                        }
                    }
                } catch (IOError err) {
                    command_line.print (err.message);
                    break;
                }
            }
        }

        async void select_port (ApplicationCommandLine command_line,
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

        async void select_sensor (ApplicationCommandLine command_line,
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

        public override int command_line (ApplicationCommandLine command_line) {
            hold ();
            handle_input.begin (command_line, (obj, res) => {
                release ();
            });
            return 0;
        }

        static int main (string[] args) {
            var demo = new Demo ();
            return demo.run (args);
        }

        void on_port_added (Port port) {
             info ("Port added: %s", port.name);
             info ("\tmodes: %s", string.joinv (", ", port.modes));
             info ("\tmode: %s", port.mode);
        }

        void on_sensor_added (Sensor sensor) {
             info ("Sensor added: %s", sensor.device_name);
             info ("\tport_name: %s", sensor.port_name);
             info ("\tmodes: %s", string.joinv (", ", sensor.modes));
             info ("\tmode: %s", sensor.mode);
             info ("\tcommands: %s", string.joinv (", ", sensor.commands));
             info ("\tnum_values: %d", sensor.num_values);
             info ("\tdecimals: %d", sensor.decimals);
             info ("\tunits: %s", sensor.units);
             var values = new string[sensor.num_values];
             for (int i = 0; i < sensor.num_values; i++)
                values[i] = sensor.get_float_value (i).to_string ();
            info ("\tvalues: %s", string.joinv(", ", values));
        }
    }
}