/*
 * ev3dev-tk - graphical toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * FakeEV3LCDDevice.vala:
 *
 * U8g.Device that simulates the EV3 LCD.
 */

using Gee;
using Gtk;
using U8g;

namespace EV3devTk {
    public class FakeEV3LCDDevice : Gtk.EventBox {
        const uint16 WIDTH = 178;
        const uint16 HEIGHT = 128;

        const uint8 BACKGROUND_RED = 195;
        const uint8 BACKGROUND_GREEN = 212;
        const uint8 BACKGROUND_BLUE = 202;

        static HashMap<unowned Device, weak FakeEV3LCDDevice> device_map;

        static construct {
            device_map = new HashMap<unowned Device, weak FakeEV3LCDDevice> ();
        }

        Gdk.Pixbuf u8g_pixbuf;
        PageBuffer buffer;
        Image image;

        Device _u8g_device;
        public unowned Device u8g_device { get { return _u8g_device; } }
        public bool u8g_active { get; private set; default = false; }

        public FakeEV3LCDDevice () {
            can_focus = true;
            button_press_event.connect ((event) => {
                grab_focus ();
                return true;
            });
            image = new Image.from_pixbuf(new Gdk.Pixbuf (
                    Gdk.Colorspace.RGB, false, 8,
                    WIDTH * 2, HEIGHT * 2));
            u8g_pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8,
                WIDTH, HEIGHT);
            buffer = new PageBuffer () {
                width = (uint16)u8g_pixbuf.width,
                data = u8g_pixbuf.pixels
            };
            /* page height is 1 because pixmap rowstride is not word
             * aligned as required by u8g */
            buffer.page.init(1, (uint16)u8g_pixbuf.height);
            _u8g_device = Device.create ((DeviceFunc)u8g_device_func, buffer);
            device_map[_u8g_device] = this;
            add (image);
        }

        ~FakeEV3LCDDevice () {
            device_map.unset (_u8g_device);
        }

        public static FakeEV3LCDDevice from_device (Device device) {
            return device_map[device];
        }

        static uint8 u8g_device_func (Graphics u8g, Device device,
            DeviceMessage msg, void* arg)
        {
            var lcd = from_device (device);
            switch (msg) {

            case DeviceMessage.INIT:
                lcd.u8g_active = true;
                return 1;
            case DeviceMessage.STOP:
                lcd.u8g_active = false;
                return 1;
            case DeviceMessage.PAGE_FIRST:
                lcd.buffer.data = (char *)lcd.u8g_pixbuf.pixels;
                break;
            case DeviceMessage.PAGE_NEXT:
                lcd.buffer.data = (char *)lcd.buffer.data + lcd.u8g_pixbuf.rowstride;
                break;
            case DeviceMessage.SET_TPIXEL:
            case DeviceMessage.SET_4TPIXEL:
            case DeviceMessage.SET_PIXEL:
            case DeviceMessage.SET_8PIXEL:
                /* convert monochrome to truecolor */
                unowned Pixel pixel = (Pixel)arg;
                if (pixel.color == u8g.get_default_background_color ()) {
                    pixel.red = BACKGROUND_RED;
                    pixel.green = BACKGROUND_GREEN;
                    pixel.blue = BACKGROUND_BLUE;
                } else {
                    pixel.green = pixel.color;
                    pixel.blue = pixel.color;
                }
                break;
            }
            var result = Device.pbxh24_base (u8g, device, msg, arg);

            if (msg == DeviceMessage.PAGE_FIRST
                || (msg == DeviceMessage.PAGE_NEXT && result == 1))
            {
                var i = 0;
                while (i < lcd.u8g_pixbuf.width * 3) {
                    ((uint8*)lcd.buffer.data)[i++] = BACKGROUND_RED;
                    ((uint8*)lcd.buffer.data)[i++] = BACKGROUND_GREEN;
                    ((uint8*)lcd.buffer.data)[i++] = BACKGROUND_BLUE;
                }
            } else if (msg == DeviceMessage.PAGE_NEXT && result == 0) {
                lcd.image.set_from_pixbuf(lcd.u8g_pixbuf.scale_simple(
                    lcd.u8g_pixbuf.width * 2, lcd.u8g_pixbuf.height * 2,
                    Gdk.InterpType.TILES));
            } else if (msg == DeviceMessage.SET_TPIXEL
                || msg == DeviceMessage.SET_4TPIXEL
                || msg == DeviceMessage.SET_PIXEL
                || msg == DeviceMessage.SET_8PIXEL)
            {
                /* have to put pixel back the way it was or else we mess stuff up */
                unowned Pixel pixel = (Pixel)arg;
                if (pixel.red == BACKGROUND_RED)
                    pixel.color = u8g.get_default_background_color ();
            }
            return result;
        }
    }
}
