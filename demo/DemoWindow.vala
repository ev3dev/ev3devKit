/*
 * ev3dev-tk - graphical toolkit for LEGO MINDSTORMS EV3
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

/* DemoWindow.vala - Main window for widget demos */

using Curses;
using GRX;

namespace EV3devTk {

    public class DemoWindow : Window {

        public signal void quit ();

        public DemoWindow () {
            var vbox = new Box.vertical () {
                padding_left = 10,
                padding_right = 10,
                spacing = 0
            };
            var show_grid_window_button = new Button.with_label ("Grid") {
                border = 0
            };
            show_grid_window_button.pressed.connect (on_show_grid_window_button_pressed);
            vbox.add (show_grid_window_button);
            var show_text_entry_button = new Button.with_label ("TextEntry") {
                border = 0
            };
            show_text_entry_button.pressed.connect (on_show_text_entry_window_button_pressed);
            vbox.add (show_text_entry_button);
            var show_dialog_button = new Button.with_label ("Dialog") {
                border = 0
            };
            show_dialog_button.pressed.connect (on_show_dialog_button_pressed);
            vbox.add (show_dialog_button);
            var show_check_button_window_button = new Button.with_label ("CheckButton") {
                border = 0
            };
            vbox.add (show_check_button_window_button);
            show_check_button_window_button.pressed.connect (on_show_check_button_window_button_pressed);
            var show_scroll_window_button = new Button.with_label ("Scroll") {
                border = 0
            };
            vbox.add (show_scroll_window_button);
            show_scroll_window_button.pressed.connect (on_show_scroll_button_pressed);
            var quit_button = new Button.with_label ("Quit") {
                border = 0
            };
            quit_button.pressed.connect (() => quit ());
            vbox.add (quit_button);

            var vscroll = new Scroll.vertical () {
                scrollbar_visible = ScrollbarVisibility.ALWAYS_SHOW,
                can_focus = false,
                margin = 10
            };
            foreach (var child in vbox.children) {
                var button = child as Button;
                if (button == null)
                    continue;
                button.notify["has-focus"].connect (() => {
                    if (button.has_focus)
                        vscroll.scroll_to_child (button);
                });
            }
            vscroll.add (vbox);
            add (vscroll);
        }

        public override bool key_pressed (uint key_code) {
            // ignore back button otherwise we end up with no windows in the stack
            if (key_code == Key.BACKSPACE)
                return false;
            return base.key_pressed (key_code);
        }

        void on_show_dialog_button_pressed () {
            var dialog = new Window.dialog ();
            // make us a nice little title bar
            var title_label = new Label ("Dialog") {
                padding_bottom = 2,
                border_bottom = 1
            };
            var message_spacer = new Spacer ();
            var message_label = new Label (
                "You pressed the show_dialog_button. "
                + "This is what a dialog looks like.");
            // a little trick to have twice as much space below the message as above the message.
            var button_spacer1 = new Spacer ();
            var button_spacer2 = new Spacer ();
            var ok_button = new Button.with_label ("OK") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.END
            };
            // pressing the button closes the dialog
            ok_button.pressed.connect (() =>
                screen.pop_window ());
            var vbox = new Box.vertical () {
                padding_top = 2,
                padding_bottom = 2,
                spacing = 2
            };
            vbox.add (title_label);
            vbox.add (message_spacer);
            vbox.add (message_label);
            vbox.add (button_spacer1);
            vbox.add (button_spacer2);
            vbox.add (ok_button);
            dialog.add (vbox);
            screen.push_window (dialog);
        }

        void on_show_check_button_window_button_pressed () {
            var window = new Window ();
            var vbox = new Box.vertical () {
                margin = 10
            };
            // just a plain checkbox
            var checkbox1 = new CheckButton.checkbox () {
                vertical_align = WidgetAlign.CENTER,
                margin_left = 2 //to match button padding
            };
            var checkbox1_label = new Label ("Unchecked") {
                vertical_align = WidgetAlign.CENTER
            };
            var checkbox1_hbox = new Box.horizontal () {
                spacing = 4
            };
            checkbox1_hbox.add (checkbox1);
            checkbox1_hbox.add (checkbox1_label);
            checkbox1.notify["checked"].connect (() =>
                checkbox1_label.text = checkbox1.checked ? "Checked" : "Unchecked");
            // or you can put the checkbox in a button so that the text is selected as well
            var checkbox2 = new CheckButton.checkbox () {
                vertical_align = WidgetAlign.CENTER,
                can_focus = false
            };
            var checkbox2_label = new Label ("Unchecked") {
                vertical_align = WidgetAlign.CENTER
            };
            var checkbox2_hbox = new Box.horizontal () {
                spacing = 4
            };
            checkbox2_hbox.add (checkbox2);
            checkbox2_hbox.add (checkbox2_label);
            var checkbox2_button = new Button (checkbox2_hbox) {
                border = 0
            };
            checkbox2.notify["checked"].connect (() =>
                checkbox2_label.text = checkbox2.checked ? "Checked" : "Unchecked");
            checkbox2_button.pressed.connect (() =>
                checkbox2.checked = !checkbox2.checked);
            // radio buttons require a group
            var radiobutton_group1 = new CheckButtonGroup ();
            var group1_label = new Label ("Group 1:");
            var group1_selected_label = new Label ();
            var group1_label_hbox = new Box.horizontal () {
                spacing = 4,
                margin_bottom = 2
            };
            group1_label_hbox.add (group1_label);
            group1_label_hbox.add (group1_selected_label);
            // represented object is used to pass arbitrary information back to the group.
            var radiobutton1 = new CheckButton.radio (radiobutton_group1) {
                represented_object_pointer = 1.to_pointer ()
            };
            var radiobutton1_label = new Label ("Item 1") {
                vertical_align = WidgetAlign.CENTER
            };
            var radiobutton1_hbox = new Box.horizontal ();
            radiobutton1_hbox.add (radiobutton1);
            radiobutton1_hbox.add (radiobutton1_label);
            var radiobutton2 = new CheckButton.radio (radiobutton_group1) {
                represented_object_pointer = 2.to_pointer ()
            };
            var radiobutton2_label = new Label ("Item 2") {
                vertical_align = WidgetAlign.CENTER
            };
            var radiobutton2_hbox = new Box.horizontal ();
            radiobutton2_hbox.add (radiobutton2);
            radiobutton2_hbox.add (radiobutton2_label);
            var radiobutton3 = new CheckButton.radio (radiobutton_group1) {
                represented_object_pointer = 3.to_pointer ()
            };
            var radiobutton3_label = new Label ("Item 3") {
                vertical_align = WidgetAlign.CENTER
            };
            var radiobutton3_hbox = new Box.horizontal ();
            radiobutton3_hbox.add (radiobutton3);
            radiobutton3_hbox.add (radiobutton3_label);
            radiobutton_group1.notify["selected-item"].connect (() => {
                var selected = radiobutton_group1.selected_item;
                group1_selected_label.text = selected == null ? "none" 
                    : "#%d selected".printf ((int)selected.represented_object_pointer);
            });
            radiobutton1.checked = true;
            vbox.add (checkbox1_hbox);
            vbox.add (checkbox2_button);
            vbox.add (group1_label_hbox);
            vbox.add (radiobutton1_hbox);
            vbox.add (radiobutton2_hbox);
            vbox.add (radiobutton3_hbox);
            window.add (vbox);
            screen.push_window (window);
        }

        void on_show_scroll_button_pressed () {
            var window = new Window ();
            var vbox = new Box.vertical () {
                margin = 10,
                spacing = 10
            };
            var vscroll = new Scroll.vertical () {
                min_height = 70
            };
            vscroll.key_pressed.connect ((key_code) => {
                if (vscroll.has_focus) {
                    if (key_code == Key.LEFT || key_code == Key.RIGHT) {
                        vscroll.do_recursive_parent ((widget) => {
                            if (widget.focus_next (FocusDirection.DOWN))
                                return widget;
                            return null;
                        });
                        Signal.stop_emission_by_name (vscroll, "key-pressed");
                        return true;
                    }
                }
                return false;
            });
            var vscroll_content = new Label ("This is a vertical scroll container."
                + " It can be used when you have too much stuff to fit on the screen"
                + " at one time. It is best to not have anything else that can_focus"
                + " on the same screen, because it makes navigation weird. For"
                + " example, pressing right or left moves to the scroll box below.")
            {
                padding_right = 2,
                text_horizontal_align = TextHorizAlign.LEFT
            };
            vscroll.add (vscroll_content);
            vbox.add (vscroll);
            var hscroll = new Scroll.horizontal () {
                min_height = 23
            };
            var hscroll_content = new Label ("You can also scroll stuff horizontally.");
            hscroll.add (hscroll_content);
            vbox.add (hscroll);
            window.add (vbox);
            screen.push_window (window);
        }

        void on_show_text_entry_window_button_pressed () {
            var window = new Window ();
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

            window.add (vbox);
            screen.push_window (window);
        }

        void on_show_grid_window_button_pressed () {
            var window = new Window ();
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
            screen.push_window (window);
        }
    }
}
