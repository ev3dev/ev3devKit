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

using Gee;
using GRX;

namespace EV3devKit.UI {
    public enum StockIcon {
        BLUETOOTH,
        ETHERNET,
        USB,
        WIFI;

        public string to_file_name () {
            switch (this) {
            case BLUETOOTH:
                return "bluetooth.png";
            case ETHERNET:
                return "ethernet.png";
            case USB:
                return "usb.png";
            case WIFI:
                return "wifi.png";
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
    public class Icon : EV3devKit.UI.Widget {
        static HashTable<string, Context> file_map;

        static construct {
            file_map = new HashTable<string, Context> (null, null);
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
         * @throws IOError.NOT_FOUND if the file does not exist or IOError.FAILED
         * if there was a problem loading the data from the file.
         */
        public Icon.from_stock (StockIcon stock_icon) throws IOError {
            this.from_png (stock_icon.to_file_name ());
        }

        /**
         * Creates a new instance of a Icon widget from a PNG file.
         *
         * @param file The name of the file where the icon is stored.
         * @throws IOError.NOT_FOUND if the file does not exist or IOError.FAILED
         * if there was a problem loading the data from the file.
         */
        public Icon.from_png (string file) throws IOError {
            // see if we have this file already cached.
            if (file_map.contains (file)) {
                context = (Context)(void*)file_map[file];
                return;
            }
            int width, height;
            if (!FileUtils.test (file, FileTest.EXISTS))
                throw new IOError.NOT_FOUND ("Could not find '%s'", file);
            if (query_png (file, out width, out height) == Result.ERROR)
                throw new IOError.FAILED ("Error querying '%s'", file);
            Context new_context;
            // in desktop app, core fame mode is undefined so we have to specify a frame mode.
            if (core_frame_mode () == FrameMode.UNDEFINED)
                new_context = Context.create_with_mode (FrameMode.RAM24, width, height);
            else
                new_context = Context.create (width, height);
            if (new_context == null)
                throw new IOError.FAILED ("Error allocating context.");
            if (new_context.load_from_png (file) == Result.ERROR)
                throw new IOError.FAILED ("Error loading '%s'", file);
            context = new_context;
            file_map[file] = (owned)new_context;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            return context.x_max + 1 + get_margin_border_padding_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            return context.y_max + 1 + get_margin_border_padding_height ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            if (parent.draw_children_as_focused) {
                // invert the colors in the icon
                context.clear (Color.white.to_xor_mode ());
                bit_blt (Context.current, content_bounds.x1, content_bounds.y1,
                    context, 0, 0, context.x_max, context.y_max, Color.black.to_image_mode ());
                // restore the colors in the icon
                context.clear (Color.white.to_xor_mode ());
            } else {
                bit_blt (Context.current, content_bounds.x1, content_bounds.y1,
                    context, 0, 0, context.x_max, context.y_max, Color.white.to_image_mode ());
            }
        }
    }
}
