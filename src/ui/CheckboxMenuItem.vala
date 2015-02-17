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

/* CheckboxMenuItem.vala - Menu item used by Menu widget that has a checkbox */

namespace EV3devKit.UI {
    /**
     * {@link MenuItem} with a checkbox.
     */
    public class CheckboxMenuItem : EV3devKit.UI.MenuItem {
        /**
         * Gets the checkbox widget for this menu item.
         */
        public CheckButton checkbox { get; construct; }

        construct {
            var hbox = new Box.horizontal ();
            button.add (hbox);
            label.horizontal_align = WidgetAlign.START;
            hbox.add (label);
            hbox.add (new Spacer ());
            if (checkbox == null) {
                critical ("checkbox is null");
            } else {
                hbox.add (checkbox);
                button.pressed.connect (() => checkbox.checked = !checkbox.checked);
            }
        }

        /**
         * Creates a new checkbox menu item.
         *
         * @param text The text for the label of the menu item.
         */
        public CheckboxMenuItem (string text) {
            Object (button: new Button () {
                border = 0,
                border_radius = 0
            }, label: new Label (text),
            checkbox: new CheckButton.checkbox () {
                padding = 0,
                can_focus = false
            });
        }
    }
}