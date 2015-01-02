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

using GUdev;

namespace EV3DevLang {
    public class DeviceManager : Object {
        const string LEGO_PORT_CLASS = "lego-port";
        const string LEGO_SENSOR_CLASS = "lego-sensor";
        const string LEDS_CLASS = "leds";
        const string DC_MOTOR_CLASS = "dc-motor";
        const string SERVO_MOTOR_CLASS = "servo-motor";
        const string TACHO_MOTOR_CLASS = "tacho-motor";

        static string[] subsystems = {
            LEGO_PORT_CLASS,
            LEGO_SENSOR_CLASS,
            LEDS_CLASS,
            DC_MOTOR_CLASS,
            SERVO_MOTOR_CLASS,
            TACHO_MOTOR_CLASS
        };

        Gee.Map<string, EV3DevLang.Device> device_map;
        Client udev_client;

        public signal void port_added (Port port);
        public signal void sensor_added (Sensor sensor);

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

        public GenericArray<Port> get_ports () {
            var array = new GenericArray<Port> ();
            foreach (var device in device_map.values) {
                var port = device as Port;
                if (port != null)
                    array.add (port);
            }
            return array;
        }

        public GenericArray<Sensor> get_sensors () {
            var array = new GenericArray<Sensor> ();
            foreach (var device in device_map.values) {
                var sensor = device as Sensor;
                if (sensor != null)
                    array.add (sensor);
            }
            return array;
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