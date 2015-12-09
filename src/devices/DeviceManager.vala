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

using GUdev;

namespace Ev3devKit.Devices {
    /**
     * Used to get instances of Device objects.
     */
    public class DeviceManager : Object {
        // TODO: Hard coding paths like this is not a good idea, but not sure
        // how to handle this one since it is a driver and not a device.
        const string NXT_ANALOG_SENSOR_PATH = "/sys/bus/lego/drivers/nxt-analog-sensor";

        const string LEGO_PORT_CLASS = "lego-port";
        const string LEGO_SENSOR_CLASS = "lego-sensor";
        const string LEDS_CLASS = "leds";
        const string DC_MOTOR_CLASS = "dc-motor";
        const string SERVO_MOTOR_CLASS = "servo-motor";
        const string TACHO_MOTOR_CLASS = "tacho-motor";
        const string POWER_SUPPLY_CLASS = "power_supply";
        const string INPUT_CLASS = "input";

        static string[] subsystems = {
            LEGO_PORT_CLASS,
            LEGO_SENSOR_CLASS,
            LEDS_CLASS,
            DC_MOTOR_CLASS,
            SERVO_MOTOR_CLASS,
            TACHO_MOTOR_CLASS,
            POWER_SUPPLY_CLASS,
            INPUT_CLASS
        };

        HashTable<string, Ev3devKit.Devices.Device> device_map;
        Client udev_client;

        /**
         * Emitted when a new Port device is connected.
         *
         * @param port The Port that was added.
         */
        public signal void port_added (Port port);

        /**
         * Emitted when a new Sensor device is connected.
         *
         * @param sensor The Sensor that was added.
         */
        public signal void sensor_added (Sensor sensor);

        /**
         * Emitted when a new Led device is connected.
         *
         * @param led The Led that was added.
         */
        public signal void led_added (Led led);

        /**
         * Emitted when a new DcMotor device is connected.
         *
         * @param motor The DcMotor that was added.
         */
        public signal void dc_motor_added (DcMotor motor);

        /**
         * Emitted when a new ServoMotor device is connected.
         *
         * @param motor The ServoMotor that was added.
         */
        public signal void servo_motor_added (ServoMotor motor);

        /**
         * Emitted when a new TachoMotor device is connected.
         *
         * @param motor The TachoMotor that was added.
         */
        public signal void tacho_motor_added (TachoMotor motor);

        /**
         * Emitted when a new PowerSupply device is connected.
         *
         * @param power_supply The PowerSupply that was added.
         */
        public signal void power_supply_added (PowerSupply power_supply);

        /**
         * Emitted when an Input device is connected.
         */
        public signal void input_added (Input input);

        construct {
            device_map = new HashTable<string, Ev3devKit.Devices.Device> (str_hash, str_equal);
            udev_client = new Client (subsystems);
            udev_client.uevent.connect (on_uevent);
            foreach (var subsystem in subsystems) {
                var device_list = udev_client.query_by_subsystem (subsystem);
                foreach (var device in device_list) {
                    on_uevent("add", device);
                }
            }
        }

        /**
         * Create new instance of DeviceManager.
         */
        public DeviceManager () {
        }

        /**
         * Get a list of all Port devices.
         *
         * @return A GenericArray containing all connected port devices.
         */
        public GenericArray<Port> get_ports () {
            var array = new GenericArray<Port> ();
            foreach (var device in device_map.get_values ()) {
                var port = device as Port;
                if (port != null)
                    array.add (port);
            }
            return array;
        }

        /**
         * Get a list of all Sensor devices.
         *
         * @return A GenericArray containing all connected sensor devices.
         */
        public GenericArray<Sensor> get_sensors () {
            var array = new GenericArray<Sensor> ();
            foreach (var device in device_map.get_values ()) {
                var sensor = device as Sensor;
                if (sensor != null)
                    array.add (sensor);
            }
            return array;
        }

        /**
         * Get an Led device by name.
         *
         * @param name The sysfs device name.
         * @return The Led object for the device.
         * @throws DeviceError.NOT_FOUND if a Led device with the specified name
         * is not found.
         */
        public Led get_led (string name) throws DeviceError {
            foreach (var device in device_map.get_values ()) {
                var led = device as Led;
                if (led != null && led.name == name)
                    return led;
            }
            throw new DeviceError.NOT_FOUND ("Could not find Led '%s'", name);
        }

        /**
         * Get a list of all Led devices.
         *
         * @return A GenericArray containing all connected Led devices.
         */
        public GenericArray<Led> get_leds () {
            var array = new GenericArray<Led> ();
            foreach (var device in device_map.get_values ()) {
                var led = device as Led;
                if (led != null)
                    array.add (led);
            }
            return array;
        }

        /**
         * Get a list of all DcMotor devices.
         *
         * @return A GenericArray containing all connected DcMotor devices.
         */
        public GenericArray<DcMotor> get_dc_motors () {
            var array = new GenericArray<DcMotor> ();
            foreach (var device in device_map.get_values ()) {
                var motor = device as DcMotor;
                if (motor != null)
                    array.add (motor);
            }
            return array;
        }

        /**
         * Get a list of all ServoMotor devices.
         *
         * @return A GenericArray containing all connected ServoMotor devices.
         */
        public GenericArray<ServoMotor> get_servo_motors () {
            var array = new GenericArray<ServoMotor> ();
            foreach (var device in device_map.get_values ()) {
                var motor = device as ServoMotor;
                if (motor != null)
                    array.add (motor);
            }
            return array;
        }

        /**
         * Get a list of all TachoMotor devices.
         *
         * @return A GenericArray containing all connected TachoMotor devices.
         */
        public GenericArray<TachoMotor> get_tacho_motors () {
            var array = new GenericArray<TachoMotor> ();
            foreach (var device in device_map.get_values ()) {
                var motor = device as TachoMotor;
                if (motor != null)
                    array.add (motor);
            }
            return array;
        }

        /**
         * Get a list of all PowerSupply devices.
         *
         * @return A GenericArray containing all connected PowerSupply devices.
         */
        public GenericArray<PowerSupply> get_power_supplies () {
            var array = new GenericArray<PowerSupply> ();
            foreach (var device in device_map.get_values ()) {
                var power_supply = device as PowerSupply;
                if (power_supply != null)
                    array.add (power_supply);
            }
            return array;
        }

        /**
         * Gets the system power supply.
         *
         * If there is more than one system power supply, it just returns the
         * first one.
         *
         * @return The power supply or ``null`` if none were found.
         */
         public PowerSupply? get_system_power_supply () {
            var supplies = get_power_supplies ();
            for (int i = 0; i < supplies.length; i++) {
                if (supplies[i].scope == PowerSupply.Scope.SYSTEM) {
                    return supplies[i];
                }
            }
            return null;
         }

        /**
         * Gets the specified Input device.
         *
         * @param name The name of the input device. See {@link Input.name}.
         * @return A the input device object.
         * @throws DeviceError.NOT_FOUND if a device with the specified name was not
         * found.
         */
        public Input get_input_device (string name) throws DeviceError {
            foreach (var device in device_map.get_values ()) {
                var input = device as Input;
                if (input != null && input.name == name)
                    return input;
            }
            throw new DeviceError.NOT_FOUND ("Could not find input device '%s'", name);
        }

        /**
         * Get a list of all Input devices.
         *
         * @return A GenericArray containing all connected Input devices.
         */
        public GenericArray<Input> get_input_devices () {
            var array = new GenericArray<Input> ();
            foreach (var device in device_map.get_values ()) {
                var input = device as Input;
                if (input != null)
                    array.add (input);
            }
            return array;
        }

        /**
         * Gets a list of driver names from the nxt-analog-sensor driver.
         *
         * Returns null if there was an error, such as the module is not loaded.
         */
        public string[]? get_nxt_analog_sensor_driver_names () {
            var device = udev_client.query_by_sysfs_path (NXT_ANALOG_SENSOR_PATH);
            if (device == null)
                return null;
            return device.get_sysfs_attr_as_strv ("driver_names");
        }

        void on_uevent (string action, GUdev.Device udev_device) {
            var sysfs_path = udev_device.get_sysfs_path ();

            switch (action) {
            case "add":
                switch (udev_device.get_subsystem ()) {
                case LEGO_PORT_CLASS:
                    var port = new Port (udev_device);
                    device_map[sysfs_path] = port;
                    port_added (port);
                    break;
                case LEGO_SENSOR_CLASS:
                    var sensor = new Sensor (udev_device);
                    device_map[sysfs_path] = sensor;
                    sensor_added (sensor);
                    break;
                case LEDS_CLASS:
                    // only handle ":ev3dev" LEDs
                    if (!udev_device.get_name ().has_suffix (":ev3dev")) {
                        break;
                    }
                    var led = new Led (udev_device);
                    device_map[sysfs_path] = led;
                    led_added (led);
                    break;
                case DC_MOTOR_CLASS:
                    var motor = new DcMotor (udev_device);
                    device_map[sysfs_path] = motor;
                    dc_motor_added (motor);
                    break;
                case SERVO_MOTOR_CLASS:
                    var motor = new ServoMotor (udev_device);
                    device_map[sysfs_path] = motor;
                    servo_motor_added (motor);
                    break;
                case TACHO_MOTOR_CLASS:
                    var motor = new TachoMotor (udev_device);
                    device_map[sysfs_path] = motor;
                    tacho_motor_added (motor);
                    break;
                case POWER_SUPPLY_CLASS:
                    var power_supply = new PowerSupply (udev_device);
                    device_map[sysfs_path] = power_supply;
                    power_supply_added (power_supply);
                    break;
                case INPUT_CLASS:
                    // Although it is not ideal, GUdev can only traverse the
                    // parent device, so we just look for "event" devices.
                    // The actual Input object will use both the "input" and
                    // "event" sysfs device nodes.
                    if (!udev_device.get_name ().has_prefix ("event"))
                        break;
                    try {
                        var input = new Input (udev_device);
                        device_map[sysfs_path] = input;
                        input_added (input);
                    } catch (Error err) {
                        critical ("%s", err.message);
                    }
                    break;
                }
                break;
            case "remove":
                var device = device_map.take (sysfs_path);
                if (device != null) {
                    device.connected = false;
                }
                break;
            case "change":
                if (device_map.contains (sysfs_path))
                    device_map[sysfs_path].change (udev_device);
                break;
            }
        }
    }
}