# ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
#
# Copyright 2015 David Lechner <david@lechnology.com>
#
# This program is free software you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation either version 2 of the License, or
#(at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

# ui_demo_window.py - Main window for widget demos

import curses

from gi.repository import Ev3devKit
from gi.repository import GObject
from gi.repository import GLib

class UiDemoWindow(Ev3devKit.UiWindow):
    """Used to demonstrate most of the UI components in ev3devKit."""

    __gsignals__ = {
        # Emitted when the use selects the Quit menu item.
        'quit':(GObject.SIGNAL_RUN_LAST, None,())
    }

    def __init__(self):
        """Creates a new instance of a demo window."""

        Ev3devKit.UiWindow.__init__(self)

        menu = Ev3devKit.UiMenu.new()
        menu.set_padding_right(10)
        menu.set_padding_left(10)
        self.add(menu)

        icon_menu_item = Ev3devKit.UiMenuItem.with_right_arrow("Icon")
        icon_menu_item.get_button().connect('pressed', self.on_icon_menu_item_pressed)
        menu.add_menu_item(icon_menu_item)

        input_dialog_menu_item = Ev3devKit.UiMenuItem.new("InputDialog...")
        input_dialog_menu_item.get_button().connect('pressed', self.on_input_dialog_menu_item_pressed)
        menu.add_menu_item(input_dialog_menu_item)

        message_dialog_menu_item = Ev3devKit.UiMenuItem.new("MessageDialog...")
        message_dialog_menu_item.get_button().connect('pressed', self.on_message_dialog_menu_item_pressed)
        menu.add_menu_item(message_dialog_menu_item)

        stack_menu_item = Ev3devKit.UiMenuItem.with_right_arrow("Stack")
        stack_menu_item.get_button().connect('pressed', self.on_stack_menu_item_pressed)
        menu.add_menu_item(stack_menu_item)

        notebook_menu_item = Ev3devKit.UiMenuItem.with_right_arrow("Notebook")
        notebook_menu_item.get_button().connect('pressed', self.on_notebook_menu_item_pressed)
        menu.add_menu_item(notebook_menu_item)

        status_bar_menu_item = Ev3devKit.UiMenuItem.with_right_arrow("StatusBar")
        status_bar_menu_item.get_button().connect('pressed', self.on_status_bar_menu_item_pressed)
        menu.add_menu_item(status_bar_menu_item)

        dialog_menu_item = Ev3devKit.UiMenuItem.with_right_arrow("Dialog...")
        dialog_menu_item.get_button().connect('pressed', self.on_dialog_menu_item_pressed)
        menu.add_menu_item(dialog_menu_item)

        quit_menu_item = Ev3devKit.UiMenuItem.new("Quit")
        quit_menu_item.get_button().connect('pressed', self.quit)
        menu.add_menu_item(quit_menu_item)

        # don't close the window when we press back
        self.connect('key-pressed', self.do_key_pressed)

    def do_key_pressed(self, window, key_code):
        # ignore the backspace key press
        if key_code == curses.KEY_BACKSPACE:
            GObject.signal_stop_emission_by_name(self, 'key-pressed')
            return True
        return False

    def quit(self, button):
        self.emit('quit')

    def on_icon_menu_item_pressed(self, button):
        window = Ev3devKit.UiWindow.new()

        vbox = Ev3devKit.UiBox.vertical()
        vbox.set_margin(6)
        window.add(vbox)

        # TODO: figure out a way to introspect enum values
        # Need some way to cast GObject.TypeClass to GObject.EnumClass
        # type_class = GObject.type_class_ref(Ev3devKit.UiIcon)
        # for value in enum_class:
        for stock_icon in range(0, 9):
            try:
                icon = Ev3devKit.UiIcon.from_stock(stock_icon)
                vbox.add(icon)
            except Exception as e:
                print(e)

        window.show()

    def on_input_dialog_menu_item_pressed(self, button):
        input_dialog = Ev3devKit.UiInputDialog.new("How much is 1+1?", "3")
        def on_input_dialog_responded(dialog, accepted):
            if not accepted:
                return
            if dialog.get_text_value() == '2':
                response_dialog = Ev3devKit.UiMessageDialog.new("Correct!", "yes, 1+1 == 2.")
            else:
                response_dialog = Ev3devKit.UiMessageDialog.new("Seriously?", "nope, 1+1 == 2.")
            response_dialog.show()
        input_dialog.connect('responded', on_input_dialog_responded)

        input_dialog.show()

    def on_message_dialog_menu_item_pressed(self, button):
        dialog = Ev3devKit.UiMessageDialog.new("Message!", "This is the message text." \
            + " It is really long so that we can test out the scroll feature" \
            + " of the MessageDialog. I really don't know what else to say" \
            + " about it.")
        dialog.show()

    def on_stack_menu_item_pressed(self, button):
        window = Ev3devKit.UiWindow.new()

        stack = Ev3devKit.UiStack.new()
        window.add(stack)

        child1_box = Ev3devKit.UiBox.vertical()
        child1_box.set_can_focus(True)
        stack.add(child1_box)
        child1_label = Ev3devKit.UiLabel.new("First Child")
        child1_box.add(child1_label)
        child1_message = Ev3devKit.UiLabel.new("Use < > arrow keys.")
        child1_box.add(child1_message)

        child2_box = Ev3devKit.UiBox.vertical()
        child2_box.set_can_focus(True)
        stack.add(child2_box)
        child2_label = Ev3devKit.UiLabel.new("Second Child")
        child2_box.add(child2_label)
        child2_message = Ev3devKit.UiLabel.new("Use < > arrow keys.")
        child2_box.add(child2_message)

        child3_box = Ev3devKit.UiBox.vertical()
        child3_box.set_can_focus(True)
        stack.add(child3_box)
        child3_label = Ev3devKit.UiLabel.new("Last Child")
        child3_box.add(child3_label)
        child3_message = Ev3devKit.UiLabel.new("Use < > arrow keys.")
        child3_box.add(child3_message)

        def child1_key_pressed_handler(widget, key_code):
            if key_code == curses.KEY_LEFT:
                stack.set_active_child(child3_box)
            elif key_code == curses.KEY_RIGHT:
                stack.set_active_child(child2_box)
            else:
                return False

            stack.focus_first()
            GObject.signal_stop_emission_by_name(child1_box, "key-pressed")
            return True

        child1_handler_id = child1_box.connect("key-pressed",
            child1_key_pressed_handler)

        def child2_key_pressed_handler(widget, key_code):
            if key_code == curses.KEY_LEFT:
                stack.set_active_child(child1_box)
            elif key_code == curses.KEY_RIGHT:
                stack.set_active_child(child3_box)
            else:
                return False

            stack.focus_first()
            GObject.signal_stop_emission_by_name(child2_box, "key-pressed")
            return True

        child2_handler_id = child2_box.connect("key-pressed",
            child2_key_pressed_handler)

        def child3_key_pressed_handler(widget, key_code):
            if key_code == curses.KEY_LEFT:
                stack.set_active_child(child2_box)
            elif key_code == curses.KEY_RIGHT:
                stack.set_active_child(child1_box)
            else:
                return False

            stack.focus_first()
            GObject.signal_stop_emission_by_name(child3_box, "key-pressed")
            return True

        child3_handler_id = child3_box.connect("key-pressed",
            child3_key_pressed_handler)

        def window_closed_handler(window):
            child1_box.disconnect(child1_handler_id)
            child2_box.disconnect(child2_handler_id)
            child3_box.disconnect(child3_handler_id)
            window.disconnect(window_handler_id)

        window_handler_id = window.connect("closed", window_closed_handler)

        window.show()

    def on_notebook_menu_item_pressed(self, button):
        window = Ev3devKit.UiWindow.new()

        notebook = Ev3devKit.UiNotebook.new()
        window.add(notebook)

        tab1 = Ev3devKit.UiNotebookTab.new("Tab 1")
        notebook.add_tab(tab1)
        tab1_label = Ev3devKit.UiLabel.new("This is Tab 1.")
        tab1_label.set_margin(10)
        tab1.add(tab1_label)

        tab2 = Ev3devKit.UiNotebookTab.new("Tab 2")
        notebook.add_tab(tab2)
        tab2_label = Ev3devKit.UiLabel.new("This is Tab 2.")
        tab2_label.set_margin(10)
        tab2.add(tab2_label)

        tab3 = Ev3devKit.UiNotebookTab.new("Tab 3")
        notebook.add_tab(tab3)
        tab3_vbox = Ev3devKit.UiBox.vertical()
        tab3_vbox.set_margin(10)
        tab3.add(tab3_vbox)
        tab3_label = Ev3devKit.UiLabel.new("This is Tab 3.")
        tab3_vbox.add(tab3_label)
        tab3_button = Ev3devKit.UiButton.new()
        tab3_vbox.add(tab3_button)
        tab3_button_label = Ev3devKit.UiLabel.new("Do Nothing")
        tab3_button.add(tab3_button_label)

        window.show()

    def on_status_bar_menu_item_pressed(self, button):
        window = Ev3devKit.UiWindow.new()

        vbox = Ev3devKit.UiBox.vertical()
        vbox.set_padding(6)
        window.add(vbox)

        hbox = Ev3devKit.UiBox.horizontal()
        hbox.set_spacing(6)
        vbox.add (hbox)

        label = Ev3devKit.UiLabel.new("Status bar visible")
        hbox.add(label)

        visible_checkbox = Ev3devKit.UiCheckButton.checkbox()
        visible_checkbox.set_checked(self.get_screen().get_status_bar().get_visible())
        def on_checked_changed(checkbox, pspec):
            checkbox.get_window().get_screen().get_status_bar().set_visible(checkbox.get_checked())
        visible_checkbox.connect('notify::checked', on_checked_changed)
        hbox.add(visible_checkbox)

        window.show()

    def on_dialog_menu_item_pressed(self, button):
        dialog = Ev3devKit.UiDialog.new()

        # make us a nice little title bar
        title_label = Ev3devKit.UiLabel.new("Dialog")
        title_label.set_padding_bottom(2)
        title_label.set_border_bottom(1)
        message_spacer = Ev3devKit.UiSpacer.new()
        message_label = Ev3devKit.UiLabel.new(
            "You pressed the dialog_menu_item. "
            + "This is what a dialog looks like.")
        message_label.set_margin(4)

        # a little trick to have twice as much space below the message as above the message.
        button_spacer1 = Ev3devKit.UiSpacer.new()
        button_spacer2 = Ev3devKit.UiSpacer.new()
        ok_button = Ev3devKit.UiButton.new()
        ok_button.set_horizontal_align(Ev3devKit.UiWidgetAlign.CENTER)
        ok_button.set_vertical_align(Ev3devKit.UiWidgetAlign.END)
        ok_label = Ev3devKit.UiLabel.new("OK")
        ok_button.add(ok_label)

        # pressing the button closes the dialog
        def on_button_pressed(button):
            dialog.close()
        handler_id = ok_button.connect('pressed', on_button_pressed)
        # have to disconnect this signal when the dialog is closed to break
        # the reference cycle on the dialog object.
        def on_dialog_closed(dialog):
            ok_button.disconnect(handler_id)
        dialog.connect('closed', on_dialog_closed)
        vbox = Ev3devKit.UiBox.vertical()
        vbox.set_padding_top(2)
        vbox.set_padding_bottom(2)
        vbox.set_spacing(2)

        vbox.add(title_label)
        vbox.add(message_spacer)
        vbox.add(message_label)
        vbox.add(button_spacer1)
        vbox.add(button_spacer2)
        vbox.add(ok_button)
        dialog.add(vbox)

        dialog.show()
