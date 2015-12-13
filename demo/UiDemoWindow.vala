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

/* UiDemoWindow.vala - Main window for widget demos */

using Curses;
using Ev3devKit.Ui;
using Grx;

namespace Ev3devKit.Demo {
    /**
     * Used to demonstrate most of the UI components in ev3devKit.
     */
    public class UiDemoWindow : Ui.Window {

        /**
         * Emitted when the use selects the Quit menu item.
         */
        public signal void quit ();

        /**
         * Creates a new instance of a demo window.
         */
        public UiDemoWindow () {
            var menu = new Ui.Menu () {
                padding_left = 10,
                padding_right = 10
            };
            add (menu);
            var icon_menu_item = new Ui.MenuItem ("Icon");
            icon_menu_item.button.pressed.connect (on_icon_menu_item_button_pressed);
            menu.add_menu_item (icon_menu_item);
            var input_dialog_menu_item = new Ui.MenuItem ("InputDialog...");
            input_dialog_menu_item.button.pressed.connect (on_input_dialog_menu_item_button_pressed);
            menu.add_menu_item (input_dialog_menu_item);
            var message_dialog_menu_item = new Ui.MenuItem ("MessageDialog...");
            message_dialog_menu_item.button.pressed.connect (on_message_dialog_menu_item_button_pressed);
            menu.add_menu_item (message_dialog_menu_item);
            var stack_menu_item = new Ui.MenuItem.with_right_arrow ("Stack");
            stack_menu_item.button.pressed.connect (on_stack_menu_item_button_pressed);
            menu.add_menu_item (stack_menu_item);
            var status_bar_menu_item = new Ui.MenuItem.with_right_arrow ("StatusBar");
            status_bar_menu_item.button.pressed.connect (on_status_bar_menu_item_button_pressed);
            menu.add_menu_item (status_bar_menu_item);
            var fonts_menu_item = new Ui.MenuItem.with_right_arrow ("Fonts");
            fonts_menu_item.button.pressed.connect (on_fonts_menu_item_button_pressed);
            menu.add_menu_item (fonts_menu_item);
            var menu_menu_item = new Ui.MenuItem.with_right_arrow ("Menu");
            menu_menu_item.button.pressed.connect (on_menu_menu_item_button_pressed);
            menu.add_menu_item (menu_menu_item);
            var grid_menu_item = new Ui.MenuItem.with_right_arrow ("Grid");
            grid_menu_item.button.pressed.connect (on_grid_menu_item_button_pressed);
            menu.add_menu_item (grid_menu_item);
            var text_entry_menu_item = new Ui.MenuItem.with_right_arrow ("TextEntry");
            text_entry_menu_item.button.pressed.connect (on_text_entry_menu_item_button_pressed);
            menu.add_menu_item (text_entry_menu_item);
            var dialog_menu_item = new Ui.MenuItem ("Dialog...");
            dialog_menu_item.button.pressed.connect (on_dialog_menu_item_pressed);
            menu.add_menu_item (dialog_menu_item);
            var check_button_menu_item = new Ui.MenuItem.with_right_arrow ("CheckButton");
            menu.add_menu_item (check_button_menu_item);
            check_button_menu_item.button.pressed.connect (on_check_button_menu_item_button_pressed);
            var scroll_menu_item = new Ui.MenuItem.with_right_arrow ("Scroll");
            menu.add_menu_item (scroll_menu_item);
            scroll_menu_item.button.pressed.connect (on_show_scroll_button_pressed);
            var quit_menu_item = new Ui.MenuItem ("Quit");
            quit_menu_item.button.pressed.connect (() => quit ());
            menu.add_menu_item (quit_menu_item);
        }

        internal override bool key_pressed (uint key_code) {
            // ignore back button otherwise we end up with no windows in the stack
            if (key_code == Key.BACKSPACE)
                return false;
            return base.key_pressed (key_code);
        }

        void on_icon_menu_item_button_pressed () {
            var window = new Ui.Window ();
            var vbox = new Box.vertical () {
                margin = 6
            };
            window.add (vbox);
            var enum_class = (EnumClass) typeof (StockIcon).class_ref ();
            foreach (unowned EnumValue val in enum_class.values) {
                try {
                    var icon = new Ui.Icon.from_stock ((StockIcon)val.@value);
                    vbox.add (icon);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
            window.show ();
        }

        void on_input_dialog_menu_item_button_pressed () {
            var dialog = new InputDialog ("How much is 1+1?", "3");
            weak InputDialog weak_dialog = dialog;
            dialog.responded.connect ((accepted) => {
                if (!accepted) {
                    return;
                }
                var text = weak_dialog.text_value;
                MessageDialog response;
                if (text == "2") {
                    response = new MessageDialog ("Correct!", "yes, 1+1 == 2.");
                } else {
                    response = new MessageDialog ("Seriously?", "nope, 1+1 == 2.");
                }
                response.show ();
            });
            dialog.show ();
        }

        void on_message_dialog_menu_item_button_pressed () {
            var dialog = new MessageDialog ("Message!", "This is the message text."
                + " It is really long so that we can test out the scroll feature"
                + " of the MessageDialog. I really don't know what else to say"
                + " about it.");
            dialog.show ();
        }

        void on_stack_menu_item_button_pressed () {
            var window = new Ui.Window ();
            var stack  = new Stack ();
            window.add (stack);

            var child1_box = new Box.vertical () { can_focus = true };
            stack.add (child1_box);
            var child1_label = new Label ("First Child");
            child1_box.add (child1_label);
            var child1_message = new Label ("Use < > arrow keys.");
            child1_box.add (child1_message);

            var child2_box = new Box.vertical () { can_focus = true };
            stack.add (child2_box);
            var child2_label = new Label ("Second Child");
            child2_box.add (child2_label);
            var child2_message = new Label ("Use < > arrow keys.");
            child2_box.add (child2_message);

            var child3_box = new Box.vertical () { can_focus = true };
            stack.add (child3_box);
            var child3_label = new Label ("Last Child");
            child3_box.add (child3_label);
            var child3_message = new Label ("Use < > arrow keys.");
            child3_box.add (child3_message);

            var child1_handler_id = child1_box.key_pressed.connect ((key_code) => {
                if (key_code == Key.LEFT) {
                    stack.active_child = child3_box;
                } else if (key_code == Key.RIGHT) {
                    stack.active_child = child2_box;
                } else {
                    return false;
                }
                stack.focus_first ();
                Signal.stop_emission_by_name (child1_box, "key-pressed");
                return true;
            });
            var child2_handler_id = child2_box.key_pressed.connect ((key_code) => {
                if (key_code == Key.LEFT) {
                    stack.active_child = child1_box;
                } else if (key_code == Key.RIGHT) {
                    stack.active_child = child3_box;
                } else {
                    return false;
                }
                stack.focus_first ();
                Signal.stop_emission_by_name (child2_box, "key-pressed");
                return true;
            });
            var child3_handler_id = child3_box.key_pressed.connect ((key_code) => {
                if (key_code == Key.LEFT) {
                    stack.active_child = child2_box;
                } else if (key_code == Key.RIGHT) {
                    stack.active_child = child1_box;
                } else {
                    return false;
                }
                stack.focus_first ();
                Signal.stop_emission_by_name (child3_box, "key-pressed");
                return true;
            });
            // have to manually disconnect because of reference cycles.
            ulong window_handler_id = 0;
            window_handler_id = window.closed.connect (() => {
                SignalHandler.disconnect (child1_box, child1_handler_id);
                SignalHandler.disconnect (child2_box, child2_handler_id);
                SignalHandler.disconnect (child3_box, child3_handler_id);
                SignalHandler.disconnect (window, window_handler_id);
            });

            window.show ();
        }

        void on_status_bar_menu_item_button_pressed () {
            var window = new Ui.Window ();
            var vbox = new Box.vertical () {
                padding = 6
            };
            window.add (vbox);
            var hbox = new Box.horizontal () {
                spacing = 6
            };
            vbox.add (hbox);
            var label = new Label ("Status bar visible");
            hbox.add (label);
            var visible_checkbox = new CheckButton.checkbox () {
                checked = screen.status_bar.visible
            };
            weak CheckButton weak_visible_checkbox = visible_checkbox;
            visible_checkbox.notify["checked"].connect (() =>
                screen.status_bar.visible = weak_visible_checkbox.checked);
            hbox.add (visible_checkbox);
            window.show ();
        }

        void on_dialog_menu_item_pressed () {
            var dialog = new Dialog ();
            var message_label = new Label ("This is a dialog.") {
                margin = 2
            };
            var ok_button = new Ui.Button.with_label ("OK") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.END
            };
            // pressing the button closes the dialog
            weak Dialog weak_dialog = dialog;
            ok_button.pressed.connect (() => weak_dialog.close ());
            var vbox = new Box.vertical () {
                padding_top = 2,
                padding_bottom = 6,
                spacing = 2
            };
            vbox.add (message_label);
            vbox.add (ok_button);
            dialog.add (vbox);
            dialog.show ();
        }

        void on_check_button_menu_item_button_pressed () {
            var window = new Ui.Window ();
            var vbox = new Box.vertical () {
                margin = 10
            };
            // just a plain checkbox
            var checkbox1 = new CheckButton.checkbox () {
                margin_left = 2 //to match button padding
            };
            var checkbox1_label = new Label ("Unchecked") {
                horizontal_align = WidgetAlign.START
            };
            var checkbox1_hbox = new Box.horizontal () {
                spacing = 4
            };
            checkbox1_hbox.add (checkbox1);
            checkbox1_hbox.add (checkbox1_label);
            weak CheckButton weak_checkbox1 = checkbox1;
            checkbox1.notify["checked"].connect (() =>
                checkbox1_label.text = weak_checkbox1.checked ? "Checked" : "Unchecked");
            // or you can put the checkbox in a button so that the text is selected as well
            var checkbox2 = new CheckButton.checkbox () {
                can_focus = false
            };
            var checkbox2_label = new Label ("Unchecked"){
                horizontal_align = WidgetAlign.START
            };
            var checkbox2_hbox = new Box.horizontal () {
                spacing = 4
            };
            checkbox2_hbox.add (checkbox2);
            checkbox2_hbox.add (checkbox2_label);
            var checkbox2_button = new Ui.Button (checkbox2_hbox) {
                border = 0,
                border_radius = 0
            };
            weak CheckButton weak_checkbox2 = checkbox2;
            checkbox2.notify["checked"].connect (() =>
                checkbox2_label.text = weak_checkbox2.checked ? "Checked" : "Unchecked");
            checkbox2_button.pressed.connect (() =>
                weak_checkbox2.checked = !weak_checkbox2.checked);
            // radio buttons require a group
            var radiobutton_group1 = new CheckButtonGroup ();
            var group1_label = new Label ("Group 1:") {
                horizontal_align = WidgetAlign.START
            };
            var group1_selected_label = new Label () {
                horizontal_align = WidgetAlign.START
            };
            var group1_label_hbox = new Box.horizontal () {
                spacing = 4,
                margin_bottom = 2
            };
            group1_label_hbox.add (group1_label);
            group1_label_hbox.add (group1_selected_label);
            // represented object is used to pass arbitrary information back to the group.
            var radiobutton1 = new CheckButton.radio (radiobutton_group1) {
                weak_represented_object = 1.to_pointer ()
            };
            var radiobutton1_label = new Label ("Item 1") {
                horizontal_align = WidgetAlign.START,
                vertical_align = WidgetAlign.CENTER
            };
            var radiobutton1_hbox = new Box.horizontal ();
            radiobutton1_hbox.add (radiobutton1);
            radiobutton1_hbox.add (radiobutton1_label);
            var radiobutton2 = new CheckButton.radio (radiobutton_group1) {
                weak_represented_object = 2.to_pointer ()
            };
            var radiobutton2_label = new Label ("Item 2") {
                horizontal_align = WidgetAlign.START,
                vertical_align = WidgetAlign.CENTER
            };
            var radiobutton2_hbox = new Box.horizontal ();
            radiobutton2_hbox.add (radiobutton2);
            radiobutton2_hbox.add (radiobutton2_label);
            var radiobutton3 = new CheckButton.radio (radiobutton_group1) {
                weak_represented_object = 3.to_pointer ()
            };
            var radiobutton3_label = new Label ("Item 3") {
                horizontal_align = WidgetAlign.START,
                vertical_align = WidgetAlign.CENTER
            };
            var radiobutton3_hbox = new Box.horizontal ();
            radiobutton3_hbox.add (radiobutton3);
            radiobutton3_hbox.add (radiobutton3_label);
            weak CheckButtonGroup weak_radiobutton_group1 = radiobutton_group1;
            radiobutton_group1.notify["selected-item"].connect (() => {
                var selected = weak_radiobutton_group1.selected_item;
                group1_selected_label.text = selected == null ? "none"
                    : "#%d selected".printf ((int)selected.weak_represented_object);
            });
            radiobutton1.checked = true;
            vbox.add (checkbox1_hbox);
            vbox.add (checkbox2_button);
            vbox.add (group1_label_hbox);
            vbox.add (radiobutton1_hbox);
            vbox.add (radiobutton2_hbox);
            vbox.add (radiobutton3_hbox);
            window.add (vbox);
            window.show ();
        }

        void on_show_scroll_button_pressed () {
            var window = new Ui.Window ();
            var vbox = new Box.vertical () {
                margin = 10,
                spacing = 5
            };
            var vscroll = new Scroll.vertical () {
                border = 1
            };
            var vscroll_content = new Label ("This is a vertical scroll container."
                + " It can be used when you have too much stuff to fit on the screen"
                + " at one time. It is best to not have anything else that can_focus"
                + " on the same screen, because it makes navigation weird. For"
                + " example, pressing right or left moves to the scroll box below.")
            {
                text_horizontal_align = TextHorizAlign.LEFT
            };
            vscroll.add (vscroll_content);
            vbox.add (vscroll);
            var hscroll = new Scroll.horizontal () {
                border = 1
            };
            var hscroll_content = new Label ("You can also scroll stuff horizontally.");
            hscroll.add (hscroll_content);
            vbox.add (hscroll);
            window.add (vbox);
            window.show ();
        }

        void on_text_entry_menu_item_button_pressed () {
            var window = new Ui.Window ();
            var vbox = new Box.vertical () {
                margin = 10
            };

            var text_entry_1 = new TextEntry ("Edit me.");
            vbox.add (text_entry_1);
            var text_entry_2 = new TextEntry ("No! Edit me! I have more text than you can see!");
            vbox.add (text_entry_2);
            var numeric_entry = new TextEntry ("000") {
                valid_chars = TextEntry.NUMERIC,
                horizontal_align = WidgetAlign.START,
                use_on_screen_keyboard = false
            };
            vbox.add (numeric_entry);
            vbox.add (new Spacer ());

            window.add (vbox);
            window.show ();
        }

        void on_grid_menu_item_button_pressed () {
            var window = new Ui.Window ();
            var grid = new Grid (3, 4) {
                margin = 5,
                border = 2
            };

            var label1 = new Label ("This spans 3 columns.") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            grid.add_at (label1, 0, 0, 1, 3);
            var label2 = new Label ("This spans 3 rows.") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            grid.add_at (label2, 0, 3, 3, 1);
            var sub_grid = new Grid (2, 3);
            var label3 = new Label ("Sub-"){
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            sub_grid.add (label3);
            var label4 = new Label ("grid"){
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            sub_grid.add (label4);
            var label5 = new Label ("has"){
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            sub_grid.add (label5);
            var label6 = new Label ("no"){
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            sub_grid.add (label6);
            var label7 = new Label ("border"){
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            sub_grid.add_at (label7, 1, 1, 1, 2);
            grid.add_at (sub_grid, 1, 0, 2, 3);

            window.add (grid);
            window.show ();
        }

        void on_menu_menu_item_button_pressed () {
            int count = 1;
            var window = new Ui.Window ();
            var menu = new Ui.Menu () {
                margin = 10
            };
            window.add (menu);
            var checkbox_menu_item = new CheckboxMenuItem ("Checkbox Item");
            menu.add_menu_item (checkbox_menu_item);
            var radio_group = new CheckButtonGroup ();
            var radio1_menu_item = new RadioMenuItem ("Radio1", radio_group);
            menu.add_menu_item (radio1_menu_item);
            var radio2_menu_item = new RadioMenuItem ("Radio2", radio_group);
            menu.add_menu_item (radio2_menu_item);
            radio1_menu_item.radio.checked = true;
            var add_new_menu_item = new Ui.MenuItem ("Add new item");
            weak Ui.Menu weak_menu = menu;
            add_new_menu_item.button.pressed.connect (() => {
                var new_item = new Ui.MenuItem ("Remove me %d".printf (count++));
                weak Ui.MenuItem weak_new_item = new_item;
                new_item.button.pressed.connect (() => {
                    weak_new_item.menu.remove_menu_item (weak_new_item);
                });
                weak_menu.add_menu_item (new_item);
            });
            menu.add_menu_item (add_new_menu_item);
            window.show ();
        }

        Font[] font_storage;
        void on_fonts_menu_item_button_pressed () {
            const string font_dir_path = "/usr/share/grx/fonts";

            try {
                var font_dir = Dir.open (font_dir_path);
                string? file_name = null;
                var font_list = new Sequence<string> ();

                var window = new Ui.Window ();
                var vscroll = new Scroll.vertical () {
                    scroll_amount = 64
                };
                window.add (vscroll);
                var vbox = new Box.vertical ();
                vscroll.add (vbox);
                while ((file_name = font_dir.read_name ()) != null) {
                    font_list.insert_sorted (file_name, (a,b) => strcmp (a,b));
                }
                font_storage = new Font[font_list.get_length ()];
                var index = 0;
                font_list.foreach ((font_name) => {
                    var font = Font.load (font_name);
                    if (font == null) {
                        return; // continue foreach
                    }
                    var label = new Label (font.name.replace (".fnt", "")) {
                        font = font
                    };
                    vbox.add (label);
                    font_storage[index++] = (owned)font;
                });
                window.show ();
            } catch (Error err) {
                var dialog = new Dialog ();
                var vbox = new Box.vertical ();
                dialog.add (vbox);
                var vscroll = new Scroll.vertical () {
                    margin = 10,
                    // FIXME: focus does not work here
                    can_focus = false
                };
                vbox.add (vscroll);
                var label = new Label (err.message);
                vscroll.add (label);
                var ok_button = new Ui.Button.with_label ("OK") {
                    horizontal_align = WidgetAlign.CENTER
                };
                weak Dialog weak_dialog = dialog;
                ok_button.pressed.connect (() => weak_dialog.close ());
                vbox.add (ok_button);
                dialog.show ();
            }
        }
    }
}
