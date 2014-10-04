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

namespace EV3devKit {
    public class CheckboxMenuItem : EV3devKit.MenuItem {
        public CheckButton checkbox { get; private set; }

        public CheckboxMenuItem (string text) {
            base.with_button (new Button () {
                border = 0,
                border_radius = 0
            }, new Label (text));
            var hbox = new Box.horizontal ();
            button.add (hbox);
            label.horizontal_align = WidgetAlign.START;
            hbox.add (label);
            hbox.add (new Spacer ());
            checkbox = new CheckButton.checkbox () {
                padding = 0,
                can_focus = false
            };
            hbox.add (checkbox);
            button.pressed.connect (() => checkbox.checked = !checkbox.checked);
        }
    }
}