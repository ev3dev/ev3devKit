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

namespace EV3devTk {

    public class DemoWindow : Window {

        public signal void quit ();

        public DemoWindow () {
            var show_dialog_button = new Button.with_label ("Dialog") {
                border = ButtonBorder.NONE
            };
            show_dialog_button.pressed.connect (on_show_dialog_button_pressed);
            var show_check_button_window_button = new Button.with_label ("CheckButton") {
                border = ButtonBorder.NONE
            };
            show_check_button_window_button.pressed.connect (
                on_show_check_button_window_button_pressed);
            var quit_button = new Button.with_label ("Quit");
            quit_button.border = ButtonBorder.NONE;
            quit_button.pressed.connect (() => quit ());
            var box1 = new Box (BoxDirection.VERTICAL) {
                padding_top = 10,
                padding_bottom = 10,
                padding_left = 10,
                padding_right = 10,
                spacing = 0
            };
            box1.add (show_dialog_button);
            box1.add (show_check_button_window_button);
            box1.add (quit_button);
            add (box1);
        }

        void on_show_dialog_button_pressed () {
            var dialog = new Window (WindowType.DIALOG);
            dialog.key_pressed.connect ((key_code) => {
                if (key_code == Key.BACKSPACE) {
                    screen.pop_window ();
                    return true;
                }
                return false;
            });
            var title_label = new Label ("Dialog");
            var title_line = new Line () {
                margin_bottom = 4
            };
            var message_label = new Label (
                "You pressed the show_dialog_button. "
                + "This is what a dialog looks like.");
            var button_spacer = new Spacer ();
            var ok_button = new Button.with_label ("OK") {
                border = ButtonBorder.BOX,
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.END
            };
            ok_button.pressed.connect (() =>
                screen.pop_window ());
            var vbox = new Box () {
                padding_top = 2,
                padding_bottom = 2,
                spacing = 2
            };
            vbox.add (title_label);
            vbox.add (title_line);
            vbox.add (message_label);
            vbox.add (button_spacer);
            vbox.add (ok_button);
            dialog.add (vbox);
            screen.push_window (dialog);
        }

        void on_show_check_button_window_button_pressed () {
            var window = new Window ();
            window.key_pressed.connect ((key_code) => {
                if (key_code == Key.BACKSPACE) {
                    screen.pop_window ();
                    return true;
                }
                return false;
            });
            var vbox = new Box ();
            var checkbox1 = new CheckButton () {
                horizontal_align = WidgetAlign.START,
                margin_left = 2
            };
            var checkbox1_label = new Label ("Unchecked") {
                vertical_align = WidgetAlign.END
            };
            var checkbox1_hbox = new Box (BoxDirection.HORIZONTAL) {
                spacing = 4
            };
            checkbox1_hbox.add (checkbox1);
            checkbox1_hbox.add (checkbox1_label);
            checkbox1.notify["checked"].connect (() =>
                checkbox1_label.text = checkbox1.checked ? "Checked" : "Unchecked");
            var checkbox2 = new CheckButton () {
                horizontal_align = WidgetAlign.START,
                can_focus = false
            };
            var checkbox2_label = new Label ("Unchecked") {
                vertical_align = WidgetAlign.END
            };
            var checkbox2_hbox = new Box (BoxDirection.HORIZONTAL) {
                spacing = 4
            };
            checkbox2_hbox.add (checkbox2);
            checkbox2_hbox.add (checkbox2_label);
            var checkbox2_button = new Button (checkbox2_hbox) {
                border = ButtonBorder.NONE
            };
            checkbox2.notify["checked"].connect (() =>
                checkbox2_label.text = checkbox2.checked ? "Checked" : "Unchecked");
            checkbox2_button.pressed.connect (() =>
                checkbox2.checked = !checkbox2.checked);
            var radiobutton_group1 = new CheckButtonGroup ();
            var group1_label = new Label ("Group 1:");
            var group1_selected_label = new Label ();
            var group1_label_hbox = new Box (BoxDirection.HORIZONTAL) {
                spacing = 4
            };
            group1_label_hbox.add (group1_label);
            group1_label_hbox.add (group1_selected_label);
            var radiobutton1 = new CheckButton (CheckButtonType.RADIO, radiobutton_group1) {
                represented_object_pointer = 1.to_pointer ()
            };
            var radiobutton1_label = new Label ("Item 1");
            var radiobutton1_hbox = new Box (BoxDirection.HORIZONTAL);
            radiobutton1_hbox.add (radiobutton1);
            radiobutton1_hbox.add (radiobutton1_label);
            var radiobutton2 = new CheckButton (CheckButtonType.RADIO, radiobutton_group1) {
                represented_object_pointer = 2.to_pointer ()
            };
            var radiobutton2_label = new Label ("Item 2");
            var radiobutton2_hbox = new Box (BoxDirection.HORIZONTAL);
            radiobutton2_hbox.add (radiobutton2);
            radiobutton2_hbox.add (radiobutton2_label);
            var radiobutton3 = new CheckButton (CheckButtonType.RADIO, radiobutton_group1) {
                represented_object_pointer = 3.to_pointer ()
            };
            var radiobutton3_label = new Label ("Item 3");
            var radiobutton3_hbox = new Box (BoxDirection.HORIZONTAL);
            radiobutton3_hbox.add (radiobutton3);
            radiobutton3_hbox.add (radiobutton3_label);
            radiobutton_group1.notify["selected-item"].connect (() => {
                var selected = radiobutton_group1.selected_item;
                group1_selected_label.text = selected == null ? "none" 
                    : "#%d".printf ((int)selected.represented_object_pointer);
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
    }
}
