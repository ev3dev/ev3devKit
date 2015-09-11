/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
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

/* MessageDialog.vala - Dialog that displays message to user */

using Curses;
using Grx;

namespace Ev3devKit.Ui {
    /**
     * A dialog for displaying a message.
     *
     * The dialog contains a title and message separated by a horizontal line.
     */
    public class MessageDialog : Ev3devKit.Ui.Dialog {
        Scroll vscroll;
        Label title_label;
        Label message_label;

        construct {
            var content_vbox = new Box.vertical ();
            add (content_vbox);
            title_label = new Label () {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            content_vbox.add (title_label);
            vscroll = new Scroll.vertical () {
                can_focus = false,
                margin_bottom = 9
            };
            content_vbox.add (vscroll);
            message_label = new Label ();
            vscroll.add (message_label);
        }

        /**
         * Creates a new message dialog.
         *
         * @param title The title text.
         * @param message The message text.
         */
        public MessageDialog (string title, string message) {
            title_label.text = title;
            message_label.text = message;
        }

        /**
         * Default handler for the key_pressed signal.
         */
        public override bool key_pressed (uint key_code) {
            switch (key_code) {
            case Key.UP:
                vscroll.scroll_backward ();
                break;
            case Key.DOWN:
                vscroll.scroll_forward ();
                break;
            case '\n':
                return base.key_pressed (Key.BACKSPACE);
            default:
                return base.key_pressed (key_code);
            }
            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }
    }
}
