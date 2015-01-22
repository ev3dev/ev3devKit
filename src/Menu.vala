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

/* Menu.vala - Menu widget */

namespace EV3devKit {
    public class Menu : EV3devKit.Scroll {
        Box menu_vbox;

        public int spacing {
            get { return menu_vbox.spacing; }
            set { menu_vbox.spacing = value; }
        }

        /**
         * Used by find_menu_item<T> (MenuItem, T) method.
         *
         * @return true if "value" matches "menu_item".
         */
        public delegate bool FindFunc<T> (MenuItem menu_item, T value);

        public Menu () {
            base.vertical ();
            can_focus = false;
            menu_vbox = new Box.vertical () {
                spacing = 0
            };
            menu_vbox.child_added.connect ((child) => {
                var id = child.notify["has-focus"].connect (() => {
                    if (child.has_focus)
                        scroll_to_child (child);
                });
                var menu_item = child.weak_represented_object as MenuItem;
                menu_item.notify_has_focus_signal_id = id;
                // Break reference cycle
                unref ();
            });
            menu_vbox.child_removed.connect ((child) => {
                // restore missing reference from above
                ref ();
                var menu_item = child.weak_represented_object as MenuItem;
                var id = menu_item.notify_has_focus_signal_id;
                if (id != 0) {
                    SignalHandler.disconnect (child, id);
                    menu_item.notify_has_focus_signal_id = 0;
                }
            });
            add (menu_vbox);
            weak_ref (weak_notify);
        }

        static void weak_notify (Object obj) {
            var menu = obj as Menu;
            while (menu.menu_vbox._children.size > 0) {
                var child = menu.menu_vbox._children.last ();
                // if we still have children at this point, the child_removed handler
                // is no longer connected, so we have to restore the missing reference
                // here as well to prevent crashes.
                menu.ref ();
                menu.remove_menu_item (child.weak_represented_object as MenuItem);
            }
        }

        /**
         * Find a MenuItem that matches "value".
         *
         * @param value The value to pass to "func".
         * @param func The function that compares "value" to each MenuItem in
         * in the Menu.
         * @return The MenuItem if a match was found, otherwise "null".
         */
        public MenuItem? find_menu_item<T> (T value, FindFunc<T> func) {
            foreach (var widget in menu_vbox._children) {
                var menu_item = widget.weak_represented_object as MenuItem;
                if (menu_item != null && func (menu_item, value)) {
                    return menu_item;
                }
            }
            return null;
        }

        public bool has_menu_item (MenuItem item) {
            foreach (var widget in menu_vbox._children) {
                var obj = widget.weak_represented_object as MenuItem;
                if (obj == item) {
                    return true;
                }
            }
            return false;
        }

        public void add_menu_item (MenuItem item)
            requires (item.button.weak_represented_object == item)
        {
            if (item.menu != null)
                item.menu.remove_menu_item (item);
            item.ref ();
            menu_vbox.add (item.button);
            item.menu = this;
        }

        public bool remove_menu_item (MenuItem item) {
            foreach (var child in menu_vbox._children) {
                var obj = child.weak_represented_object as MenuItem;
                if (obj == item) {
                    if (child.has_focus)
                        child.focus_next (child == menu_vbox._children.last ()
                            ? FocusDirection.UP : FocusDirection.DOWN);
                    item.menu = null;
                    menu_vbox.remove (child);
                    item.unref ();
                    return true;
                }
            }
            return false;
        }

        public void remove_all_menu_items () {
            var iter = menu_item_iter ();
            while (iter.size > 0)
                remove_menu_item (iter[0]);
        }

        public void sort_menu_items (CompareDataFunc<MenuItem> func) {
            menu_vbox.sort ((a, b) => {
                var menu_item_a = a.weak_represented_object as MenuItem;
                var menu_item_b = b.weak_represented_object as MenuItem;
                return func (menu_item_a, menu_item_b);
            });
        }

        public MenuItemIterator menu_item_iter () {
            return new MenuItemIterator (this);
        }

        public class MenuItemIterator {
            Menu menu;

            internal MenuItemIterator (Menu menu) {
                this.menu = menu;
            }

            public int size { get { return menu.menu_vbox.children.size; } }

            public MenuItem get (int index) {
                return menu.menu_vbox.children[index].weak_represented_object as MenuItem;
            }
        }
    }
}