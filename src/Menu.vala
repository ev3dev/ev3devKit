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

/* Menu.vala - Menu widget */

namespace EV3devKit {
    public class Menu : EV3devKit.Scroll {
        Box menu_vbox;

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

        public MenuItem? get_menu_item (Object represented_object) {
            foreach (var widget in menu_vbox._children) {
                var obj = widget.weak_represented_object as MenuItem;
                if (obj != null && obj.represented_object == represented_object) {
                    return obj;
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
    }
}