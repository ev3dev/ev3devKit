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
using GRX;

namespace EV3devKit {
    public class MessageDialog : EV3devKit.Dialog {
        Scroll vscroll;

        public MessageDialog (string title, string message) {
            var content_vbox = new Box.vertical ();
            add (content_vbox);
            var title_label = new Label (title) {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            content_vbox.add (title_label);
            vscroll = new Scroll.vertical () {
                can_focus = false,
                border = 0,
                margin_bottom = 9
            };
            content_vbox.add (vscroll);
            var message_label = new Label (message);
            vscroll.add (message_label);
        }

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
