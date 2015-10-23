/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
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
 * InputDialog.vala:
 *
 * Dialog for getting user input (text).
 */

using Curses;
using Grx;

namespace Ev3devKit.Ui {
    public class InputDialog : Ev3devKit.Ui.Dialog {
        Label message_label;
        TextEntry value_entry;
        Button accept_button;
        Button cancel_button;

        public string text_value { get { return value_entry.text; } }

        public signal void responded (bool accepted);

        construct {
            var content_vbox = new Box.vertical () {
                padding = 3,
                spacing = 6
            };
            message_label = new Label ();
            content_vbox.add (message_label);
            value_entry = new TextEntry ();
            content_vbox.add (value_entry);
            content_vbox.add (new Spacer ());
            var button_vbox = new Box.vertical ();
            content_vbox.add (button_vbox);
            var button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER
            };
            button_vbox.add (button_hbox);
            cancel_button = new Button.with_label ("Cancel");
            cancel_button.pressed.connect (on_cancel_button_pressed);
            button_hbox.add (cancel_button);
            accept_button = new Button.with_label ("Accept");
            accept_button.pressed.connect (on_accept_button_pressed);
            button_hbox.add (accept_button);
            add (content_vbox);
        }

        public InputDialog (string message, string inital_value = "") {
            message_label.text = message;
            value_entry.text = inital_value;
        }

        void on_accept_button_pressed () {
            responded (true);
            close ();
        }

        void on_cancel_button_pressed () {
            responded (false);
            close ();
        }

        /**
         * Default handler for the key_pressed signal.
         */
        protected override bool key_pressed (uint key_code) {
            if (key_code == Curses.Key.BACKSPACE) {
                Signal.stop_emission_by_name (this, "key-pressed");
                on_cancel_button_pressed ();
                return true;
            }
            return base.key_pressed (key_code);
        }
    }
}