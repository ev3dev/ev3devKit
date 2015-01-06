/*
 * ev3dev-lang-glib - GLib library for interacting with ev3dev kernel drivers
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

namespace EV3DevLang {
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

        static string[] subsystems = {
            LEGO_PORT_CLASS,
            LEGO_SENSOR_CLASS,
            LEDS_CLASS,
            DC_MOTOR_CLASS,
            SERVO_MOTOR_CLASS,
            TACHO_MOTOR_CLASS,
            POWER_SUPPLY_CLASS
        };

        Gee.Map<string, EV3DevLang.Device> device_map;
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
         * Emitted when a new LED device is connected.
         *
         * @param led The LED that was added.
         */
        public signal void led_added (LED led);

        /**
         * Emitted when a new DCMotor device is connected.
         *
         * @param motor The DCMotor that was added.
         */
        public signal void dc_motor_added (DCMotor motor);

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
         * Create new instance of DeviceManager.
         */
        public DeviceManager () {
            device_map = new Gee.HashMap<string, EV3DevLang.Device> ();
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
         * Get a list of all Port devices.
         *
         * @return A GenericArray containing all connected port devices.
         */
        public GenericArray<Port> get_ports () {
            var array = new GenericArray<Port> ();
            foreach (var device in device_map.values) {
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
            foreach (var device in device_map.values) {
                var sensor = device as Sensor;
                if (sensor != null)
                    array.add (sensor);
            }
            return array;
        }

        /**
         * Get a list of all LED devices.
         *
         * @return A GenericArray containing all connected LED devices.
         */
        public GenericArray<LED> get_leds () {
            var array = new GenericArray<LED> ();
            foreach (var device in device_map.values) {
                var led = device as LED;
                if (led != null)
                    array.add (led);
            }
            return array;
        }

        /**
         * Get a list of all DCMotor devices.
         *
         * @return A GenericArray containing all connected DCMotor devices.
         */
        public GenericArray<DCMotor> get_dc_motors () {
            var array = new GenericArray<DCMotor> ();
            foreach (var device in device_map.values) {
                var motor = device as DCMotor;
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
            foreach (var device in device_map.values) {
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
            foreach (var device in device_map.values) {
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
            foreach (var device in device_map.values) {
                var power_supply = device as PowerSupply;
                if (power_supply != null)
                    array.add (power_supply);
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
                    var led = new LED (udev_device);
                    device_map[sysfs_path] = led;
                    led_added (led);
                    break;
                case DC_MOTOR_CLASS:
                    var motor = new DCMotor (udev_device);
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
                }
                break;
            case "remove":
                var device = device_map[sysfs_path];
                device_map.unset (sysfs_path);
                device.connected = false;
                break;
            case "change":
                var device = device_map[sysfs_path];
                device.change (udev_device);
                break;
            }
        }
    }
}