/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
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

/*
 * This is a demo application to show how to use the ev3dev-lang-glib library.
 * It is overly documented to make it easier to understand.
 */

using EV3devKit.Devices;

namespace EV3devKit.Demo {
    // Not acutally used. This is a workaround for a bug that causes compiler error:
    // "EV3devKit.UI.Window.key_pressed: no suitable method found to override"
    public EV3devKit.UI.Window dummy;

    /**
     * Demo application
     *
     * We are using the GLib Application class so we can have an event driven
     * application. The Application class takes care of stuff like setting up
     * the main loop. It can also handle command line options if we want to
     * set some up. Basically, it lets us skip the boilerplate code and get
     * strait to our application logic.
     *
     * The Demo application itself is a simple menu driven program that lets
     * the user browse all of the devices connected to the EV3.
     */
    public class Demo : Application {

        // The DeviceManager is how we get objects for hardware devices
        DeviceManager manager;
        // There is a variable for each type of supported device to keep a
        // reference to the currently selected device.
        Port? selected_port;
        Sensor? selected_sensor;
        LED? selected_led;
        TachoMotor? selected_tacho_motor;
        DCMotor? selected_dc_motor;
        ServoMotor? selected_servo_motor;
        PowerSupply? selected_power_supply;

        Demo () {
            // Application class does not support chaining to base(), so this
            // accomplishes the same thing. The flag tell the application to
            // use the command_line signal instead of the usual activate signal
            // on startup.
            Object (flags: ApplicationFlags.HANDLES_COMMAND_LINE);

            // Get a DeviceManager instance. Signal handlers are used to handle
            // devices that are attached after the program has started and
            // get_* is used to load all of the devices that are already
            // connected.
            manager = new DeviceManager ();
            manager.port_added.connect (on_port_added);
            manager.get_ports ().foreach (on_port_added);
            manager.sensor_added.connect (on_sensor_added);
            manager.get_sensors ().foreach (on_sensor_added);
            manager.led_added.connect (on_led_added);
            manager.get_leds ().foreach (on_led_added);
            manager.tacho_motor_added.connect (on_tacho_motor_added);
            manager.get_tacho_motors ().foreach (on_tacho_motor_added);
            manager.dc_motor_added.connect (on_dc_motor_added);
            manager.get_dc_motors ().foreach (on_dc_motor_added);
            manager.servo_motor_added.connect (on_servo_motor_added);
            manager.get_servo_motors ().foreach (on_servo_motor_added);
            manager.power_supply_added.connect (on_power_supply_added);
            manager.get_power_supplies ().foreach (on_power_supply_added);
        }

        /**
         * Prints a numbered list using items from an enum.
         */
        void print_menu_items<T> (ApplicationCommandLine command_line) {
            var enum_class = (EnumClass) typeof (T).class_ref ();
            command_line.print ("\n");
            foreach (var enum_value in enum_class.values) {
                var text = enum_value.value_nick.replace ("-", " ");
                command_line.print ("%d. %s\n", enum_value.value, text);
            }
        }

        /**
         * Wait for user to type something and press [Enter].
         */
        async int get_input (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            command_line.print ("\nSelect an item: ");
            return int.parse (yield stdin.read_line_async ());
        }

        /**
         * Gets input from user or cancel if device is disconnected.
         *
         * @throws IOError.CANCELLED if device was disconnected.
         */
        async string? get_input_cancel_on_remove (EV3devKit.Devices.Device device,
            DataInputStream stdin) throws IOError
        {
            var cancellable = new Cancellable ();
            var handler_id = device.notify["connected"].connect (() => {
                cancellable.cancel ();
            });
            try {
                return yield stdin.read_line_async (Priority.DEFAULT, cancellable);
            } finally {
                device.disconnect (handler_id);
            }
        }

        /**
         * List of items used for Main Menu
         */
        enum MainMenu {
            PORTS = 1,
            SENSORS,
            LEDS,
            TACHO_MOTORS,
            DC_MOTORS,
            SERVO_MOTORS,
            POWER_SUPPLIES,
            QUIT
        }

        /**
         * Print the main menu and handle user input.
         *
         * Loops until user selects Quit.
         */
        async void do_main_menu (ApplicationCommandLine command_line) throws IOError {
            var stdin = new DataInputStream (command_line.get_stdin ());
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
                case MainMenu.LEDS:
                    yield do_leds_menu (command_line, stdin);
                    break;
                case MainMenu.TACHO_MOTORS:
                    yield do_tacho_motors_menu (command_line, stdin);
                    break;
                case MainMenu.DC_MOTORS:
                    yield do_dc_motors_menu (command_line, stdin);
                    break;
                case MainMenu.SERVO_MOTORS:
                    yield do_servo_motors_menu (command_line, stdin);
                    break;
                case MainMenu.POWER_SUPPLIES:
                    yield do_power_supply_menu (command_line, stdin);
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

        /**
         * List of items in the Ports submenu.
         */
        enum PortsMenu {
            SELECT_PORT = 1,
            SHOW_PORT_INFO,
            SELECT_MODE,
            SET_DEVICE,
            MAIN_MENU
        }

        /**
         * Print the Ports menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
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

        /**
         * Print a list of all lego-port class devices and get user selection.
         *
         * DeviceManager.get_ports () is used to get a list of ports.
         *
         * If the user selects a valid port, selected_port is set.
         */
        async void do_select_port (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var ports = manager.get_ports ();
            int i = 1;
            ports.foreach ((port) => {
                command_line.print ("%d. %s (%s)\n", i, port.port_name,
                    port.device_name);
                i++;
            });
            command_line.print ("\nSelect Port: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_port = ports[input - 1];
        }

        /**
         * Print all of the property values for selected_port.
         */
        void do_show_port_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_port == null) {
                command_line.print ("No port selected.\n");
                return;
            }
            command_line.print ("device name: %s\n", selected_port.device_name);
            command_line.print ("driver name: %s\n", selected_port.driver_name);
            command_line.print ("port name: %s\n", selected_port.port_name);
            command_line.print ("connected: %s\n", selected_port.connected ? "true" : "false");
            command_line.print ("modes: %s\n",string.joinv (", ", selected_port.modes));
            command_line.print ("mode: %s\n", selected_port.mode);
            command_line.print ("status: %s\n", selected_port.status);
        }

        /**
         * Print a list of the available modes and get user input.
         *
         * The mode is set using Port.set_mode (). Prints an error if setting
         * the mode fails. The operation is canceled if the port is removed
         * before the user presses [Enter].
         */
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
            try {
                var input = int.parse (yield get_input_cancel_on_remove (
                    selected_port, stdin));
                if (input <= 0 || input >= i) {
                    command_line.print ("Invalid Selection.\n");
                } else {
                    try {
                        selected_port.set_mode (selected_port.modes[input - 1]);
                    } catch (Error err) {
                        command_line.print ("Error: %s\n", err.message);
                    }
                }
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("Port was disconnected.\n");
                    return;
                }
                throw err;
            }
        }

        /**
         * Gets user input and calls Port.set_device ().
         *
         * Prints error if setting the device fails. The operation is canceled
         * if the port is removed before the user presses [Enter].
         */
        async void do_port_set_device (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_port == null) {
                command_line.print ("No port selected.\n");
                return;
            }
            command_line.print ("\nEnter Device Name: ");
            try {
                var input = yield get_input_cancel_on_remove (selected_port, stdin);
                try {
                    selected_port.set_device (input);
                } catch (Error err) {
                    command_line.print ("Error: %s\n", err.message);
                }
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("Port was disconnected.\n");
                    return;
                }
                throw err;
            }
        }

        /**
         * The list of items in the Sensors Menu
         */
        enum SensorsMenu {
            SELECT_SENSOR = 1,
            SHOW_SENSOR_INFO,
            WATCH_VALUES,
            SELECT_MODE,
            SEND_COMMAND,
            SET_POLL_MS,
            MAIN_MENU
        }

        /**
         * Print the Sensors menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
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

        /**
         * Print a list of all lego-sensor class devices and get user selection.
         *
         * DeviceManager.get_sensors () is used to get a list of sensors.
         *
         * If the user selects a valid sensors, selected_sensor is set.
         */
        async void do_select_sensor (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var sensors = manager.get_sensors ();
            int i = 1;
            sensors.foreach ((sensor) => {
                command_line.print ("%d. %s on %s (%s)\n", i, sensor.driver_name,
                    sensor.port_name, sensor.device_name);
                i++;
            });
            command_line.print ("\nSelect Sensor: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_sensor = sensors[input - 1];
        }

        /**
         * Print all of the property values for selected_sensor.
         */
        void do_show_sensor_info (ApplicationCommandLine command_line) {
            if (selected_sensor == null) {
                command_line.print ("Sensor not selected.\n");
                return;
            }
            command_line.print ("device_name: %s\n", selected_sensor.device_name);
            command_line.print ("driver_name: %s\n", selected_sensor.driver_name);
            command_line.print ("port_name: %s\n", selected_sensor.port_name);
            command_line.print ("connected: %s\n", selected_sensor.connected ? "true" : "false");
            command_line.print ("address: %s\n", selected_sensor.address);
            command_line.print ("fw_version: %s\n", selected_sensor.fw_version);
            command_line.print ("poll_ms: %d\n", selected_sensor.poll_ms);
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

        /**
         * Continuously read and print all value attributes for selected_sensor
         *
         * Reading is stopped when the user presses [Enter]. Reading is also
         * canceled if the sensor is removed before the user presses [Enter].
         */
        async void do_watch_sensor_values (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_sensor == null) {
                command_line.print ("No sensor selected.\n");
                return;
            }
            command_line.print ("\nPress [Enter] to stop:\n");
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
            try {
                yield get_input_cancel_on_remove (selected_sensor, stdin);
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("Sensor was disconnected.\n");
                    return;
                }
                throw err;
            } finally {
                Source.remove (source_id);
            }
        }

        /**
         * Print a list of the available modes and get user input.
         *
         * The mode is set using Sensor.set_mode (). Prints an error if setting
         * the mode fails. The operation is canceled if the sensor is removed
         * before the user presses [Enter].
         */
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
            try {
                var input = int.parse (yield get_input_cancel_on_remove (
                    selected_sensor, stdin));
                if (input <= 0 || input >= i) {
                    command_line.print ("Invalid Selection.\n");
                } else {
                    try {
                        selected_sensor.set_mode (selected_sensor.modes[input - 1]);
                    } catch (Error err) {
                        command_line.print ("Error: %s\n", err.message);
                    }
                }
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("Sensor was disconnected.\n");
                    return;
                }
                throw err;
            }
        }

        /**
         * Print a list of the available commands and get user input.
         *
         * The mode is set using Sensor.send_command (). Prints an error if
         * sending the command fails. The operation is canceled if the sensor
         * is removed before the user presses [Enter].
         */
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

        /**
         * Get user input and set the poll_ms attribute.
         *
         * The polling period is set using Sensor.set_poll_ms (). Prints an
         * error message if setting the value fails. The operation is canceled
         * if the sensor is removed before the user presses [Enter].
         */
        async void do_set_sensor_poll_ms (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_sensor == null) {
                command_line.print ("No sensor selected.\n");
                return;
            }
            command_line.print ("\nEnter polling period in milliseconds: ");
            try {
                var input = int.parse (yield get_input_cancel_on_remove (
                    selected_sensor, stdin));
                if (input < 0) {
                    command_line.print ("Invalid Selection.\n");
                } else {
                    try {
                        selected_sensor.set_poll_ms (input);
                    } catch (Error err) {
                        command_line.print ("Error: %s\n", err.message);
                    }
                }
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("Sensor was disconnected.\n");
                    return;
                }
                throw err;
            }
        }

        /**
         * List of items in the LEDs submenu.
         */
        enum LEDsMenu {
            SELECT_LED = 1,
            SHOW_LED_INFO,
            SET_BRIGHTNESS,
            SET_TRIGGER,
            MAIN_MENU
        }

        /**
         * Print the LEDs menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
        async void do_leds_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<LEDsMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case LEDsMenu.SELECT_LED:
                    yield do_select_led (command_line, stdin);
                    break;
                case LEDsMenu.SHOW_LED_INFO:
                    do_show_led_info (command_line);
                    break;
                case LEDsMenu.SET_BRIGHTNESS:
                    yield do_set_led_brightness (command_line, stdin);
                    break;
                case LEDsMenu.SET_TRIGGER:
                    yield do_set_led_trigger (command_line, stdin);
                    break;
                case LEDsMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        /**
         * Print a list of all leds class devices and get user selection.
         *
         * DeviceManager.get_leds () is used to get a list of LEDs.
         *
         * If the user selects a valid LED, selected_led is set.
         */
        async void do_select_led (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var leds = manager.get_leds ();
            int i = 1;
            leds.foreach ((led) => {
                command_line.print ("%d. %s\n", i, led.name);
                i++;
            });
            command_line.print ("\nSelect LED: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_led = leds[input - 1];
        }

        /**
         * Print all of the property values for selected_led.
         */
        void do_show_led_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_led == null) {
                command_line.print ("No LED selected.\n");
                return;
            }
            command_line.print ("connected: %s\n", selected_led.connected ? "true" : "false");
            command_line.print ("name: %s\n", selected_led.name);
            command_line.print ("brightness: %d\n", selected_led.brightness);
            command_line.print ("max_brightness: %d\n", selected_led.max_brightness);
            command_line.print ("triggers: %s\n",string.joinv (", ", selected_led.triggers));
            command_line.print ("trigger: %s\n", selected_led.trigger);
        }

        /**
         * Print a list of the available triggers and get user input.
         *
         * The trigger is set using LED.set_trigger (). Prints an error if
         * setting the trigger fails. The operation is canceled if the LED is
         * removed before the user presses [Enter].
         */
        async void do_set_led_trigger (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_led == null) {
                command_line.print ("No LED selected.\n");
                return;
            }
            int i = 1;
            foreach (var trigger in selected_led.triggers) {
                command_line.print ("%d. %s\n", i, trigger);
                i++;
            }
            command_line.print ("\nSelect Trigger: ");
            try {
                var input = int.parse (yield get_input_cancel_on_remove (
                    selected_led, stdin));
                if (input <= 0 || input >= i) {
                    command_line.print ("Invalid Selection.\n");
                } else {
                    try {
                        selected_led.set_trigger (selected_led.triggers[input - 1]);
                    } catch (Error err) {
                        command_line.print ("Error: %s\n", err.message);
                    }
                }
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("LED was disconnected.\n");
                    return;
                }
                throw err;
            }
        }

        /**
         * Gets user input and calls LED.set_brightness ().
         *
         * Prints error if setting the brightness fails. The operation is
         * canceled if the LED is removed before the user presses [Enter].
         */
        async void do_set_led_brightness (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            if (selected_led == null) {
                command_line.print ("No LED selected.\n");
                return;
            }
            command_line.print ("\nEnter Device Name: ");
            try {
                var input = int.parse (yield get_input_cancel_on_remove (
                    selected_led, stdin));
                try {
                    selected_led.set_brightness (input);
                } catch (Error err) {
                    command_line.print ("Error: %s\n", err.message);
                }
            } catch (IOError err) {
                if (err is IOError.CANCELLED) {
                    command_line.print ("LED was disconnected.\n");
                    return;
                }
                throw err;
            }
        }

        /**
         * List of items in the TachoMotors submenu.
         */
        enum TachoMotorsMenu {
            SELECT_MOTOR = 1,
            SHOW_MOTOR_INFO,
            MAIN_MENU
        }

        /**
         * Print the TachoMotors menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
        async void do_tacho_motors_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<TachoMotorsMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case TachoMotorsMenu.SELECT_MOTOR:
                    yield do_select_tacho_motor (command_line, stdin);
                    break;
                case TachoMotorsMenu.SHOW_MOTOR_INFO:
                    do_show_tacho_motor_info (command_line);
                    break;
                case TachoMotorsMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        /**
         * Print a list of all tacho-motor class devices and get user selection.
         *
         * DeviceManager.get_tacho_motors () is used to get a list of tacho motors.
         *
         * If the user selects a valid tacho motor, selected_tacho_motor is set.
         */
        async void do_select_tacho_motor (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var motors = manager.get_tacho_motors ();
            int i = 1;
            motors.foreach ((motor) => {
                command_line.print ("%d. %s on %s (%s)\n", i, motor.motor_type,
                    motor.port_name, motor.device_name);
                i++;
            });
            command_line.print ("\nSelect Tacho Motor: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_tacho_motor = motors[input - 1];
        }

        /**
         * Print all of the property values for selected_tacho_motor.
         */
        void do_show_tacho_motor_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_tacho_motor == null) {
                command_line.print ("No Tacho Motor selected.\n");
                return;
            }
            command_line.print ("device_name: %s\n", selected_tacho_motor.device_name);
            command_line.print ("motor_type: %s\n", selected_tacho_motor.motor_type);
            command_line.print ("port_name: %s\n", selected_tacho_motor.port_name);
            command_line.print ("connected: %s\n", selected_tacho_motor.connected ? "true" : "false");
            command_line.print ("duty_cycle: %d\n", selected_tacho_motor.duty_cycle);
            command_line.print ("duty_cycle_sp: %d\n", selected_tacho_motor.duty_cycle_sp);
            command_line.print ("encoder_mode: %s\n", selected_tacho_motor.encoder_mode);
            command_line.print ("encoder_modes: %s\n", string.joinv (", ", selected_tacho_motor.encoder_modes));
            command_line.print ("emergency_stop: %s\n", selected_tacho_motor.emergency_stop);
            command_line.print ("polarity_mode: %s\n", selected_tacho_motor.polarity_mode);
            command_line.print ("polarity_modes: %s\n", string.joinv (", ", selected_tacho_motor.polarity_modes));
            command_line.print ("position: %d\n", selected_tacho_motor.position);
            command_line.print ("position_mode: %s\n", selected_tacho_motor.position_mode);
            command_line.print ("position_modes: %s\n", string.joinv (", ", selected_tacho_motor.position_modes));
            command_line.print ("position_sp: %d\n", selected_tacho_motor.position_sp);
            command_line.print ("pulses_per_second: %d\n", selected_tacho_motor.pulses_per_second);
            command_line.print ("pulses_per_second_sp: %d\n", selected_tacho_motor.pulses_per_second_sp);
            command_line.print ("ramp_down_sp: %d\n", selected_tacho_motor.ramp_down_sp);
            command_line.print ("ramp_up_sp: %d\n", selected_tacho_motor.ramp_up_sp);
            command_line.print ("regulation_mode: %s\n", selected_tacho_motor.regulation_mode);
            command_line.print ("regulation_modes: %s\n", string.joinv (", ", selected_tacho_motor.regulation_modes));
            command_line.print ("run: %d\n", selected_tacho_motor.run);
            command_line.print ("run_mode: %s\n", selected_tacho_motor.run_mode);
            command_line.print ("run_modes: %s\n", string.joinv (", ", selected_tacho_motor.run_modes));
            command_line.print ("speed_regulation_p: %d\n", selected_tacho_motor.speed_regulation_p);
            command_line.print ("speed_regulation_i: %d\n", selected_tacho_motor.speed_regulation_i);
            command_line.print ("speed_regulation_d: %d\n", selected_tacho_motor.speed_regulation_d);
            command_line.print ("speed_regulation_k: %d\n", selected_tacho_motor.speed_regulation_k);
            command_line.print ("state: %s\n", selected_tacho_motor.state);
            command_line.print ("stop_mode: %s\n", selected_tacho_motor.stop_mode);
            command_line.print ("stop_modes: %s\n", string.joinv (", ", selected_tacho_motor.stop_modes));
            command_line.print ("time_sp: %d\n", selected_tacho_motor.time_sp);
        }

        /**
         * List of items in the DCMotors submenu.
         */
        enum DCMotorsMenu {
            SELECT_MOTOR = 1,
            SHOW_MOTOR_INFO,
            MAIN_MENU
        }

        /**
         * Print the DCMotors menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
        async void do_dc_motors_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<DCMotorsMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case DCMotorsMenu.SELECT_MOTOR:
                    yield do_select_dc_motor (command_line, stdin);
                    break;
                case DCMotorsMenu.SHOW_MOTOR_INFO:
                    do_show_dc_motor_info (command_line);
                    break;
                case DCMotorsMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        /**
         * Print a list of all dc-motor class devices and get user selection.
         *
         * DeviceManager.get_dc_motors () is used to get a list of dc motors.
         *
         * If the user selects a valid dc motor, selected_dc_motor is set.
         */
        async void do_select_dc_motor (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var motors = manager.get_dc_motors ();
            int i = 1;
            motors.foreach ((motor) => {
                command_line.print ("%d. %s on %s (%s)\n", i, motor.driver_name,
                    motor.port_name, motor.device_name);
                i++;
            });
            command_line.print ("\nSelect DCMotor: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_dc_motor = motors[input - 1];
        }

        /**
         * Print all of the property values for selected_dc_motor.
         */
        void do_show_dc_motor_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_dc_motor == null) {
                command_line.print ("No DCMotor selected.\n");
                return;
            }
            command_line.print ("device_name: %s\n", selected_dc_motor.device_name);
            command_line.print ("driver_name: %s\n", selected_dc_motor.driver_name);
            command_line.print ("port_name: %s\n", selected_dc_motor.port_name);
            command_line.print ("connected: %s\n", selected_dc_motor.connected ? "true" : "false");
            command_line.print ("commands: %s\n", string.joinv (", ", selected_dc_motor.commands));
            command_line.print ("duty_cycle: %d\n", selected_dc_motor.duty_cycle);
            command_line.print ("duty_cycle_sp: %d\n", selected_dc_motor.duty_cycle_sp);
            command_line.print ("polarity: %s\n", selected_dc_motor.polarity.to_string ());
            command_line.print ("ramp_down_ms: %d\n", selected_dc_motor.ramp_down_ms);
            command_line.print ("ramp_up_ms: %d\n", selected_dc_motor.ramp_up_ms);
        }

        /**
         * List of items in the ServoMotors submenu.
         */
        enum ServoMotorsMenu {
            SELECT_MOTOR = 1,
            SHOW_MOTOR_INFO,
            MAIN_MENU
        }

        /**
         * Print the ServoMotors menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
        async void do_servo_motors_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<ServoMotorsMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case ServoMotorsMenu.SELECT_MOTOR:
                    yield do_select_servo_motor (command_line, stdin);
                    break;
                case ServoMotorsMenu.SHOW_MOTOR_INFO:
                    do_show_servo_motor_info (command_line);
                    break;
                case ServoMotorsMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        /**
         * Print a list of all servo-motor class devices and get user selection.
         *
         * DeviceManager.get_servo_motors () is used to get a list of servo motors.
         *
         * If the user selects a valid servo motor, selected_servo_motor is set.
         */
        async void do_select_servo_motor (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var motors = manager.get_servo_motors ();
            int i = 1;
            motors.foreach ((motor) => {
                command_line.print ("%d. %s on %s (%s)\n", i, motor.driver_name,
                    motor.port_name, motor.device_name);
                i++;
            });
            command_line.print ("\nSelect ServoMotor: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_servo_motor = motors[input - 1];
        }

        /**
         * Print all of the property values for selected_servo_motor.
         */
        void do_show_servo_motor_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_servo_motor == null) {
                command_line.print ("No ServoMotor selected.\n");
                return;
            }
            command_line.print ("device_name: %s\n", selected_servo_motor.device_name);
            command_line.print ("driver_name: %s\n", selected_servo_motor.driver_name);
            command_line.print ("port_name: %s\n", selected_servo_motor.port_name);
            command_line.print ("connected: %s\n", selected_servo_motor.connected ? "true" : "false");
            command_line.print ("command: %s\n", selected_servo_motor.command);
            command_line.print ("max_pulse_ms: %d\n", selected_servo_motor.max_pulse_ms);
            command_line.print ("mid_pulse_ms: %d\n", selected_servo_motor.mid_pulse_ms);
            command_line.print ("min_pulse_ms: %d\n", selected_servo_motor.min_pulse_ms);
            command_line.print ("polarity: %s\n", selected_servo_motor.polarity);
            command_line.print ("position: %d\n", selected_servo_motor.position);
            command_line.print ("rate: %d\n", selected_servo_motor.rate);
        }

        /**
         * List of items in the PowerSupply submenu.
         */
        enum PowerSuppliesMenu {
            SELECT_POWER_SUPPLY = 1,
            SHOW_POWER_SUPPLY_INFO,
            MAIN_MENU
        }

        /**
         * Print the PowerSupply menu and handle user input.
         *
         * Loops until user selects Main Menu
         */
        async void do_power_supply_menu (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var done = false;
            while (!done) {
                print_menu_items<PowerSuppliesMenu> (command_line);
                switch (yield get_input (command_line, stdin)) {
                case PowerSuppliesMenu.SELECT_POWER_SUPPLY:
                    yield do_select_power_supply (command_line, stdin);
                    break;
                case PowerSuppliesMenu.SHOW_POWER_SUPPLY_INFO:
                    do_show_power_supply_info (command_line);
                    break;
                case PowerSuppliesMenu.MAIN_MENU:
                    done = true;
                    break;
                default:
                    command_line.print ("Invalid selection.\n");
                    break;
                }
            }
        }

        /**
         * Print a list of all power_supply class devices and get user selection.
         *
         * DeviceManager.get_power_supplies () is used to get a list of power
         * supplies.
         *
         * If the user selects a valid power supply, selected_power_supply is set.
         */
        async void do_select_power_supply (ApplicationCommandLine command_line,
            DataInputStream stdin) throws IOError
        {
            var power_supplies = manager.get_power_supplies ();
            int i = 1;
            power_supplies.foreach ((power_supply) => {
                command_line.print ("%d. %s\n", i, power_supply.device_name);
                i++;
            });
            command_line.print ("\nSelect PowerSupply: ");
            var input = int.parse (yield stdin.read_line_async ());
            if (input <= 0 || input >= i)
                command_line.print ("Invalid Selection.\n");
            else
                selected_power_supply = power_supplies[input - 1];
        }

        /**
         * Print all of the property values for selected_power_supply.
         */
        void do_show_power_supply_info (ApplicationCommandLine command_line) {
            command_line.print ("\n");
            if (selected_power_supply == null) {
                command_line.print ("No PowerSupply selected.\n");
                return;
            }
            command_line.print ("device_name: %s\n", selected_power_supply.device_name);
            command_line.print ("connected: %s\n", selected_power_supply.connected ? "true" : "false");
            command_line.print ("voltage: %f\n", selected_power_supply.voltage);
            command_line.print ("current: %f\n", selected_power_supply.current);
            command_line.print ("power: %f\n", selected_power_supply.power);
            command_line.print ("voltage_max_design: %f\n", selected_power_supply.voltage_max_design);
            command_line.print ("voltage_min_design: %f\n", selected_power_supply.voltage_min_design);
            command_line.print ("supply_type: %s\n", selected_power_supply.supply_type);
            command_line.print ("technology: %s\n", selected_power_supply.technology);
            command_line.print ("scope: %s\n", selected_power_supply.scope);
            command_line.print ("capacity_level: %s\n", selected_power_supply.capacity_level);
        }

        /**
         * Entry point for application after calling Application.run () in main ()
         *
         * Starts Main Menu and prints error for anything unhandled in the menus.
         */
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

        /**
         * Main entry point for application.
         *
         * Creates a new instance of the Demo application and runs it.
         */
        static int main (string[] args) {
            var demo = new Demo ();
            return demo.run (args);
        }

        /**
         * Display a message whenever a port is connected.
         *
         * Adds handler so message is displayed when the port is disconnected.
         */
        void on_port_added (Port port) {
            message ("Port added: %s (%s)", port.port_name, port.device_name);
            ulong handler_id = 0;
            handler_id = port.notify["connected"].connect (() => {
                message ("Port removed: %s (%s)", port.port_name, port.device_name);
                port.disconnect (handler_id);
            });
        }

        /**
         * Display a message whenever a sensor is connected.
         *
         * Adds handler so message is displayed when the sensor is disconnected.
         */
        void on_sensor_added (Sensor sensor) {
            message ("Sensor added: %s on %s (%s)", sensor.driver_name,
                sensor.port_name, sensor.device_name);
            ulong handler_id = 0;
            handler_id = sensor.notify["connected"].connect (() => {
                message ("Sensor removed: %s on %s (%s)", sensor.driver_name,
                    sensor.port_name, sensor.device_name);
                sensor.disconnect (handler_id);
            });
        }

        /**
         * Display a message whenever a LED is connected.
         *
         * Adds handler so message is displayed when the LED is disconnected.
         */
        void on_led_added (LED led) {
            message ("LED added: %s", led.name);
            ulong handler_id = 0;
            handler_id = led.notify["connected"].connect (() => {
                message ("LED removed: %s", led.name);
                led.disconnect (handler_id);
            });
        }

        /**
         * Display a message whenever a tacho motor is connected.
         *
         * Adds handler so message is displayed when the tacho motor is
         * disconnected.
         */
        void on_tacho_motor_added (TachoMotor motor) {
            message ("TachoMotor added: %s on %s (%s)", motor.motor_type,
                motor.port_name, motor.device_name);
            ulong handler_id = 0;
            handler_id = motor.notify["connected"].connect (() => {
                message ("TachoMotor removed: %s on %s (%s)", motor.motor_type,
                    motor.port_name, motor.device_name);
                motor.disconnect (handler_id);
            });
        }

        /**
         * Display a message whenever a dc motor is connected.
         *
         * Adds handler so message is displayed when the dc motor is
         * disconnected.
         */
        void on_dc_motor_added (DCMotor motor) {
            message ("DCMotor added: %s on %s (%s)", motor.driver_name,
                motor.port_name, motor.device_name);
            ulong handler_id = 0;
            handler_id = motor.notify["connected"].connect (() => {
                message ("DCMotor removed: %s on %s (%s)", motor.driver_name,
                    motor.port_name, motor.device_name);
                motor.disconnect (handler_id);
            });
        }

        /**
         * Display a message whenever a servo motor is connected.
         *
         * Adds handler so message is displayed when the servo motor is
         * disconnected.
         */
        void on_servo_motor_added (ServoMotor motor) {
            message ("ServoMotor added: %s on %s (%s)", motor.driver_name,
                motor.port_name, motor.device_name);
            ulong handler_id = 0;
            handler_id = motor.notify["connected"].connect (() => {
                message ("ServoMotor removed: %s on %s (%s)", motor.driver_name,
                    motor.port_name, motor.device_name);
                motor.disconnect (handler_id);
            });
        }

        /**
         * Display a message whenever a power supply is connected.
         *
         * Adds handler so message is displayed when the power supply is
         * disconnected.
         */
        void on_power_supply_added (PowerSupply power_supply) {
            message ("PowerSupply added: %s", power_supply.device_name);
            ulong handler_id = 0;
            handler_id = power_supply.notify["connected"].connect (() => {
                message ("PowerSupply removed: %s", power_supply.device_name);
                power_supply.disconnect (handler_id);
            });
        }
    }
}