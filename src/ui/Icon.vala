/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
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

/* Icon.vala - Widget to display an icon */

using Grx;

namespace Ev3devKit.Ui {
    /**
     * Represents available stock icons.
     */
    public enum StockIcon {
        BLUETOOTH_CONNECTED_7X9,
        BLUETOOTH_12X12,
        BLUETOOTH_7X9,
        ETHERNET_12X12,
        LOCK_5X6,
        LOCK_7X9,
        USB_12X12,
        USB_7X9,
        WIFI_IDLE_12X9,
        WIFI_12X12,
        WIFI_12X9,
        WPS_9X9;

        /**
         * Converts StockIcon enum value to corresponding file name.
         *
         * @return The name of the file. Does not include full path.
         */
        public string to_file_name () {
            switch (this) {
            case BLUETOOTH_CONNECTED_7X9:
                return "bluetooth-connected7x9.png";
            case BLUETOOTH_12X12:
                return "bluetooth12x12.png";
            case BLUETOOTH_7X9:
                return "bluetooth7x9.png";
            case ETHERNET_12X12:
                return "ethernet12x12.png";
            case LOCK_5X6:
                return "lock5x6.png";
            case LOCK_7X9:
                return "lock7x9.png";
            case USB_7X9:
                return "usb7x9.png";
            case USB_12X12:
                return "usb12x12.png";
            case WIFI_IDLE_12X9:
                return "wifi-idle12x9.png";
            case WIFI_12X12:
                return "wifi12x12.png";
            case WIFI_12X9:
                return "wifi12x9.png";
            case WPS_9X9:
                return "wps9x9.png";
            default:
                critical ("Unknown StockIcon %d", this);
                return "";
            }
        }
    }

    /**
     * Widget to display text.
     *
     * The text will be automatically wrapped if the parent Container is not
     * wide enough to fit the entire text value.
     */
    public class Icon : Ev3devKit.Ui.Widget {
        static HashTable<string, Context> file_map;

        static construct {
            ensure_file_map ();
        }

        unowned Context context;

        /**
         * Creates a new instance of a Icon widget using the provided Context.
         *
         * The icon does not own the context, so make sure it is not freed.
         *
         * @param context The context to use for the icon.
         */
        public Icon.from_context (Context context) {
            this.context = context;
        }

        /**
         * Creates a new instance of a Icon widget using a stock icon.
         *
         * @param stock_icon The stock icon to use.
         * @throws GLib.IOError.NOT_FOUND if the file does not exist or IOError.FAILED
         * if there was a problem loading the data from the file.
         */
        public Icon.from_stock (StockIcon stock_icon) throws GLib.Error {
            this.from_png (Path.build_filename (DATA_DIR, stock_icon.to_file_name ()));
        }

        /**
         * Creates a new instance of a Icon widget from a PNG file.
         *
         * @param file The name of the file where the icon is stored.
         * @throws GLib.IOError.NOT_FOUND if the file does not exist or IOError.FAILED
         * if there was a problem loading the data from the file.
         */
        public Icon.from_png (string file) throws GLib.Error {
            context = create_context_from_png (file);
        }

        /**
         * Create a context from the specified file.
         *
         * The context is cached so that future calls do not have to reload the
         * data from the file.
         *
         * This is intended for use when you need to load an image but don't
         * need a Widget.
         *
         * @param file The name of the file where the icon is stored.
         * @throws GLib.IOError.NOT_FOUND if the file does not exist or IOError.FAILED
         * if there was a problem loading the data from the file.
         */

        public static unowned Context create_context_from_png (string file) throws GLib.Error {
            ensure_file_map ();
            // see if we have this file already cached.
            if (file_map.contains (file)) {
                return (Context)(void*)file_map[file];
            }
            var full_path = file.dup ();
            if (!Path.is_absolute (full_path)) {
                foreach (var base_path in Environment.get_system_data_dirs ()) {
                    var new_path = Path.build_filename (base_path, full_path);
                    if (FileUtils.test (new_path, FileTest.EXISTS)) {
                        full_path = new_path;
                        break;
                    }
                }
            }
            if (!FileUtils.test (full_path, FileTest.EXISTS)) {
                throw new IOError.NOT_FOUND ("Could not find '%s'", full_path);
            }
            int width, height;
            if (!query_png_file (full_path, out width, out height)) {
                throw new IOError.FAILED ("Error querying '%s'", full_path);
            }
            Context new_context;
            // in desktop app, core fame mode is undefined so we have to specify a frame mode.
            if (FrameMode.get_screen_core () == FrameMode.UNDEFINED) {
                new_context = Context.new_full (FrameMode.get_screen (), width, height);
            } else {
                new_context = Context.new (width, height);
            }
            if (new_context == null)
                throw new IOError.FAILED ("Error allocating context.");
            new_context.load_from_png (full_path);
            unowned Context unowned_context = new_context;
            file_map[file] = (owned)new_context;
            return unowned_context;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            return context.width + get_margin_border_padding_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            return context.height + get_margin_border_padding_height ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            if (parent.draw_children_as_focused) {
                // invert the colors in the icon
                context.clear (Color.WHITE.to_xor_mode ());
                bit_blt (content_bounds.x1, content_bounds.y1, context, 0, 0,
                    context.max_x, context.max_y, Color.BLACK.to_image_mode ());
                // restore the colors in the icon
                context.clear (Color.WHITE.to_xor_mode ());
            } else {
                bit_blt (content_bounds.x1, content_bounds.y1, context, 0, 0,
                    context.max_x, context.max_y, Color.WHITE.to_image_mode ());
            }
        }

        inline static void ensure_file_map () {
            if (file_map == null)
                file_map = new HashTable<string, Context> (null, null);
        }
    }
}
