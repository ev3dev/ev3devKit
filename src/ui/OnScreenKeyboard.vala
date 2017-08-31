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

/* OnScreenKeyboard.vala - Window that provides an on-screen keyboard for user intput. */

using Grx;

namespace Ev3devKit.Ui {
    /**
     * Specifies the type of keyboard.
     */
    public enum Keyboard {
        /**
         * Uppercase alphabet.
         */
        UPPER_ALPHA,
        /**
         * Lowercase alphabet.
         */
        LOWER_ALPHA,
        /**
         * Numeric.
         */
        NUMERIC,
        /**
         * Other symbols.
         */
        SYMBOL
    }

    /**
     * An on screen keyboard for getting user input.
     */
    public class OnScreenKeyboard : Ev3devKit.Ui.Window {
        const int KEYBOARD_ROWS = 4;
        const int KEYBOARD_COLS = 10;

        TextEntry text_entry;
        Grid upper_alpha_grid;
        Grid lower_alpha_grid;
        Grid numeric_grid;
        Grid symbol_grid;
        Box vbox;
        HashTable<ulong, weak Object> signal_id_map;

        /**
         * Gets and sets the user text.
         */
        public string text {
            owned get { return text_entry.text[0:text_entry.text.length-1]; }
            set {
                text_entry.text = value + " ";
                text_entry.cursor_offset = value.length;
            }
        }

        Grid? current_keyboard { get; set; }

        /**
         * Emitted when the user presses the Accept button.
         */
        public signal void accepted ();

        /**
         * Emitted when the user presses the Cancel button.
         */
        public signal void canceled ();

        construct {
            signal_id_map = new HashTable<ulong, weak Object> (null, null);
            vbox = new Box.vertical () {
                spacing = 3
            };
            text_entry = new TextEntry (" ") {
                vertical_align = WidgetAlign.START,
                use_on_screen_keyboard = false,
                editing = true,
                insert = true,
                margin_top = 3,
                padding = 3
            };
            text_entry.notify["has-focus"].connect (() => {
                if (text_entry.has_focus) {
                    text_entry.border = 2;
                    text_entry.padding = 2;
                } else {
                    text_entry.border = 1;
                    text_entry.padding = 3;
                }
            });
            text_entry.key_pressed.connect ((key_code) => {
                if (key_code == Key.UP)
                    text_entry.focus_next (FocusDirection.UP);
                else if (key_code == Key.DOWN)
                    text_entry.focus_next (FocusDirection.DOWN);
                else if (key_code == Key.BACK_SPACE)
                    text_entry.delete_char (true);
                else if (key_code != Key.RETURN)
                    return false;
                Signal.stop_emission_by_name (text_entry, "key-pressed");
                return true;
            });
            vbox.add (text_entry);
            var nav_grid = new Grid (1, 5) {
                vertical_align = WidgetAlign.START,
                border = 2
            };
            nav_grid.add (create_change_keyboard_button ("ABC", Keyboard.UPPER_ALPHA));
            nav_grid.add (create_change_keyboard_button ("abc", Keyboard.LOWER_ALPHA));
            nav_grid.add (create_change_keyboard_button ("123", Keyboard.NUMERIC));
            nav_grid.add (create_change_keyboard_button ("!@#", Keyboard.SYMBOL));
            nav_grid.add (create_insert_button ());
            vbox.add (nav_grid);
            add (vbox);
            shown.connect_after (() => text_entry.focus_next (FocusDirection.UP));
            weak_ref (before_finalize);
        }

        /**
         * Creates a new on screen keyboard.
         *
         * @param inital_keyboard The type of keyboard to display first.
         */
        public OnScreenKeyboard (Keyboard inital_keyboard = Keyboard.UPPER_ALPHA) {
            set_keyboard (inital_keyboard);
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            base.do_layout ();
        }

        static void before_finalize (Object obj) {
            weak OnScreenKeyboard instance = obj as OnScreenKeyboard;
            // We are affected by https://bugzilla.gnome.org/show_bug.cgi?id=624624
            // We workaround this by unrefefernecing "this" each time we create
            // a lambda that references "this", then we have to put those references
            // back before the signals are disconnected to prevent problems.
            // We also have to manually disconnect the signals here or the
            // finalization will be canceled because ref_count is no longer 0.
            foreach (var id in instance.signal_id_map.get_keys ()) {
                instance.ref ();
                SignalHandler.disconnect (instance.signal_id_map[id], id);
            }
            instance.dispose ();
        }

        void set_keyboard (Keyboard keyboard) {
            if (current_keyboard != null)
                vbox.remove (current_keyboard);
            switch (keyboard) {
            case Keyboard.UPPER_ALPHA:
                if (upper_alpha_grid == null)
                    init_upper_alpha_grid ();
                vbox.add (upper_alpha_grid);
                break;
            case Keyboard.LOWER_ALPHA:
                if (lower_alpha_grid == null)
                    init_lower_alpha_grid ();
                vbox.add (lower_alpha_grid);
                break;
            case Keyboard.NUMERIC:
                if (numeric_grid == null)
                    init_numeric_grid ();
                vbox.add (numeric_grid);
                break;
            case Keyboard.SYMBOL:
                if (symbol_grid == null)
                    init_symbol_grid ();
                vbox.add (symbol_grid);
                break;
            default:
                critical ("Bad keyboard type.");
                return;
            }
            current_keyboard = (Grid)vbox.children.last ().data;
        }

        void init_upper_alpha_grid () {
            upper_alpha_grid = new Grid (KEYBOARD_ROWS, KEYBOARD_COLS) {
                border = 1
            };
            int row = 0;
            int col = 0;
            foreach (var c in "QWERTYUIOP".data)
                upper_alpha_grid.add_at (create_char_button ((char)c), row, col++);
            row = 1;
            col = 0;
            foreach (var c in "ASDFGHJKL".data)
                upper_alpha_grid.add_at (create_char_button ((char)c), row, col++);
            row = 2;
            col = 1;
            foreach (var c in "ZXCVBNM".data)
                upper_alpha_grid.add_at (create_char_button ((char)c), row, col++);
            upper_alpha_grid.add_at (create_accept_button (), 3, 0, 1, 3);
            upper_alpha_grid.add_at (create_char_button (' '), 3, 3, 1, 4);
            upper_alpha_grid.add_at (create_cancel_button (), 3, 7, 1, 3);
        }

        void init_lower_alpha_grid () {
            lower_alpha_grid = new Grid (KEYBOARD_ROWS, KEYBOARD_COLS) {
                border = 1
            };
            lower_alpha_grid.add_at (create_insert_button (), 0, 8, 1, 2);
            int row = 0;
            int col = 0;
            foreach (var c in "qwertyuiop".data)
                lower_alpha_grid.add_at (create_char_button ((char)c), row, col++);
            row = 1;
            col = 0;
            foreach (var c in "asdfghjkl".data)
                lower_alpha_grid.add_at (create_char_button ((char)c), row, col++);
            row = 2;
            col = 1;
            foreach (var c in "zxcvbnm".data)
                lower_alpha_grid.add_at (create_char_button ((char)c), row, col++);
            lower_alpha_grid.add_at (create_accept_button (), 3, 0, 1, 3);
            lower_alpha_grid.add_at (create_char_button (' '), 3, 3, 1, 4);
            lower_alpha_grid.add_at (create_cancel_button (), 3, 7, 1, 3);
        }

        void init_numeric_grid () {
            numeric_grid = new Grid (KEYBOARD_ROWS, KEYBOARD_COLS) {
                border = 1
            };
            int row = 0;
            int col = 3;
            foreach (var c in "789".data)
                numeric_grid.add_at (create_char_button ((char)c), row, col++);
            row = 1;
            col = 3;
            foreach (var c in "456".data)
                numeric_grid.add_at (create_char_button ((char)c), row, col ++);
            row = 2;
            col = 3;
            foreach (var c in "123".data)
                numeric_grid.add_at (create_char_button ((char)c), row, col++);
            numeric_grid.add_at (create_accept_button (), 3, 0, 1, 3);
            numeric_grid.add_at (create_char_button ('0'), 3, 3, 1, 2);
            numeric_grid.add_at (create_char_button ('.'), 3, 5);
            numeric_grid.add_at (create_cancel_button (), 3, 7, 1, 3);
        }

        void init_symbol_grid () {
            symbol_grid = new Grid (KEYBOARD_ROWS, KEYBOARD_COLS) {
                border = 1
            };
            symbol_grid.add_at (create_insert_button (), 0, 8, 1, 2);
            int row = 0;
            int col = 0;
            foreach (var c in "!@#$%^&*()".data)
                symbol_grid.add_at (create_char_button ((char)c), row, col++);
            row = 1;
            col = 0;
            foreach (var c in "~-_=+\\|/[]".data)
                symbol_grid.add_at (create_char_button ((char)c), row, col++);
            row = 2;
            col = 0;
            foreach (var c in "`'\";:,.?{}".data)
                symbol_grid.add_at (create_char_button ((char)c), row, col++);
            symbol_grid.add_at (create_accept_button (), 3, 0, 1, 3);
            symbol_grid.add_at (create_char_button (' '), 3, 3, 1, 2);
            row = 3;
            col = 5;
            foreach (var c in "<>".data)
                symbol_grid.add_at (create_char_button ((char)c), row, col++);
            symbol_grid.add_at (create_cancel_button (), 3, 7, 1, 3);
        }

        Button create_char_button (char c) {
            var button = new Button.with_label (c.to_string ()) {
                border = 0,
                border_radius = 0
            };
            var id = button.pressed.connect (() => {
                set_char (c);
            });
            // break reference cycle cause by lambda (see before_finalize method)
            unref ();
            signal_id_map[id] = button;
            return button;
        }

        Button create_change_keyboard_button (string label, Keyboard keyboard) {
            var button = new Button.with_label (label) {
                border = 0,
                border_radius = 0,
                padding = 0,
                padding_bottom = 2
            };
            (button.child as Label).font = Fonts.get_small ();
            var id = button.pressed.connect (() => {
                set_keyboard (keyboard);
            });
            // break reference cycle cause by lambda (see before_finalize method)
            unref ();
            signal_id_map[id] = button;
            return button;
        }

        Button create_insert_button () {
            var button = new Button.with_label ("INS") {
                border = 0,
                border_radius = 0
            };
            (button.child as Label).font = Fonts.get_small ();
            var id = button.pressed.connect (() => {
                text_entry.insert = !text_entry.insert;
                (button.child as Label).text = text_entry.insert ? "INS" : "OVR";
            });
            // break reference cycle cause by lambda (see before_finalize method)
            unref ();
            signal_id_map[id] = button;
            return button;
        }

        Button create_accept_button () {
            var button = new Button.with_label ("OK") {
                border_radius = 0
            };
            (button.child as Label).font = Fonts.get_small ();
            button.pressed.connect (() => {
                // trim trailing space
                if (text[text.length - 1] == ' ')
                    text = text[0:text.length - 1];
                accepted ();
                close ();
            });
            return button;
        }

        Button create_cancel_button () {
            var button = new Button.with_label ("Cancel") {
                border_radius = 0
            };
            (button.child as Label).font = Fonts.get_small ();
            button.pressed.connect (() => {
                canceled ();
                close ();
            });
            return button;
        }

        void set_char (char c) {
            text_entry.set_char (c, true);
            if (text_entry.text[text_entry.text.length-1] != ' ')
                text_entry.text += " ";
        }

        /**
         * Default handler for the key_pressed signal.
         */
        internal override bool key_pressed (uint key_code) {
            if (key_code == Key.BACK_SPACE)
                text_entry.delete_char (true);
            else if (key_code == Key.DELETE)
                text_entry.delete_char ();
            else if (key_code >= 32 && key_code < 127)
                set_char ((char)key_code);
            else
                return false;
            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }
    }
}