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

/* RadioMenuItem.vala - Menu items used by Menu widget with radio button */

namespace EV3devKit.UI {
    /**
     * A menu item that includes a radio button.
     */
    public class RadioMenuItem : EV3devKit.UI.MenuItem {
        /**
         * Gets the radio button for the menu item.
         */
        public CheckButton radio { get; private set; }

        /**
         * Creates a new radio button menu item.
         *
         * @param text The text for the menu item Label.
         * @param group The CheckButtonGroup for the radio button.
         */
        public RadioMenuItem (string text, CheckButtonGroup group) {
            base.with_button (new Button () {
                border = 0,
                border_radius = 0
            }, new Label (text));
            var hbox = new Box.horizontal ();
            button.add (hbox);
            label.horizontal_align = WidgetAlign.START;
            hbox.add (label);
            hbox.add (new Spacer ());
            radio = new CheckButton.radio (group) {
                padding = 0,
                can_focus = false
            };
            hbox.add (radio);
            button.pressed.connect (() => radio.checked = !radio.checked);
        }
    }
}