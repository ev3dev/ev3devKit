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

/* MenuItem.vala - Base class for menu items used by Menu widget */

namespace EV3devKit.UI {
    /**
     * Object used by {@link Menu} to represent a menu item.
     *
     * Note: MenuItems do not inherit from {@link Widget}.
     */
    public class MenuItem : Object {
        static int menu_item_count = 0;

        internal ulong notify_has_focus_signal_id;

        /**
         * Gets the Menu that this menu item belongs to.
         *
         * Returns ``null`` if this MenuItem has not been added to a Menu.
         */
        public weak Menu? menu { get; internal set; }

        /**
         * Gets the Button that is the Container for the menu item.
         */
        public Button button { get; construct set; }

        /**
         * Gets the Lable for the menu item.
         */
        public Label label { get; construct set; }

        /**
         * Gets and sets a user-defined object that the menu item represents.
         */
        public Object? represented_object { get; set; }

        /**
         * Creates a new menu item with the specified text.
         *
         * @param text The text for the menu item's label.
         */
        public MenuItem (string text) {
            this.with_button (new Button () {
                border = 0,
                border_radius = 0
            }, new Label (text));
            button.add (label);
        }

        /**
         * Creates a new menu item using the provided button and label.
         *
         * This is the main constructor that should be called by superclasses.
         *
         * Note: MenuItem uses ``button.weak_represented_object`` internally, so
         * implementations must not set that property.
         */
        protected MenuItem.with_button (Button button, Label label) {
            this.button = button;
            this.label = label;
            // using weak reference to prevent reference cycle.
            button.weak_represented_object = this;
            weak_ref (weak_notify);
            menu_item_count++;
            //debug ("Created MenuItem: %p", this);
        }

        static void weak_notify (Object obj) {
            var menu_item = obj as MenuItem;
            if (menu_item.notify_has_focus_signal_id != 0)
                SignalHandler.disconnect (menu_item.button, menu_item.notify_has_focus_signal_id);
        }

        ~MenuItem () {
            //debug ("Finalized MenuItem: %p", this);
            //debug ("MenuItem count %d", --menu_item_count);
        }
    }
}