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

/* Box.vala - Container for displaying widgets horizontally or vertically */

using Gee;
using GRX;

namespace EV3devTk {

    /**
     * Specifies the number of children a container can have.
     */
    public enum BoxDirection {
        /**
         * Container can only have one child.
         */
        HORIZONTAL,
        /**
         * Container can have more than one child.
         */
        VERTICAL;
    }

    public class Box : EV3devTk.Container {
        public BoxDirection direction { get; private set; }
        public int spacing { get; set; default = 2; }

         public Box (BoxDirection direction = BoxDirection.VERTICAL) {
             base (ContainerType.MULTIPLE);
             this.direction = direction;
             notify["spacing"].connect (redraw);
             child_added.connect ((c) => {
                 if (c is Spacer)
                    spacer_count++;
             });
             child_removed.connect ((c) => {
                 if (c is Spacer)
                    spacer_count--;
             });
        }

        public override int preferred_width {
            get {
                int width = 0;
                if (direction == BoxDirection.HORIZONTAL) {
                    foreach (var item in children)
                        width += item.preferred_width + spacing;
                    width -= spacing;
                } else {
                    foreach (var item in children)
                        width = int.max (width, item.preferred_width);
                }
                return width + base.preferred_width;
            }
        }

        public override int preferred_height {
            get {
                int height = 0;
                if (direction == BoxDirection.VERTICAL) {
                    foreach (var item in children)
                        height += item.preferred_height + spacing;
                    height -= spacing;
                } else {
                    foreach (var item in children)
                        height = int.max (height, item.preferred_height);
                }
                return height + base.preferred_height;
            }
        }

        int extra_width {
            get {
                if (direction == BoxDirection.VERTICAL || parent == null)
                    return 0;
                return parent.content_width - preferred_width;
            }
        }

        int extra_height {
            get {
                if (direction == BoxDirection.HORIZONTAL || parent == null)
                    return 0;
                return parent.content_height - preferred_height;
            }
        }

        int spacer_count { get; set; default = 0; }

        internal override int get_child_x (Widget child)
            requires (children.contains (child))
        {
            if (direction == BoxDirection.VERTICAL)
                return base.get_child_x (child);
            int _x = content_x;
            foreach (var item in children) {
                if (item == child)
                    break;
                _x += get_child_width (item) + spacing;
            }
            return _x;
        }

        internal override int get_child_y (Widget child)
            requires (children.contains (child))
        {
            if (direction == BoxDirection.HORIZONTAL)
                return base.get_child_y (child);
            int _y = content_y;
            foreach (var item in children) {
                if (item == child)
                    break;
                _y += get_child_height (item) + spacing;
            }
            return _y;
        }

        internal override int get_child_width (Widget child)
            requires (children.contains (child))
        {
            if (direction == BoxDirection.VERTICAL
                && child.horizontal_align == WidgetAlign.FILL)
                return width - base.preferred_width;
            return child.preferred_width
                + (int)((child is Spacer) ? extra_width / spacer_count : 0);
        }

        internal override int get_child_height (Widget child)
            requires (children.contains (child))
        {
            if (direction == BoxDirection.HORIZONTAL
                && child.vertical_align == WidgetAlign.FILL)
                return height - base.preferred_height;
            return child.preferred_height
                + (int)((child is Spacer) ? extra_height / spacer_count : 0);
        }

        public override bool focus_next (FocusDirection direction) {
            var widgets_after_focused_list = new LinkedList<Widget> ();
            if (children.size > 0) {
                var iter = children.list_iterator ();
                iter.first ();
                do {
                    if (iter.get ().has_focus)
                        break;
                    var container = iter.get () as Container;
                    if (container != null && container.descendant_has_focus)
                        break;
                } while (iter.next ());
                if (iter.index () < children.size) {
                    var current = iter.get ();
                    var widgets_before_focused_list = new LinkedList<Widget> ();
                    if ((this.direction == BoxDirection.VERTICAL
                        && direction == FocusDirection.UP)
                        || (this.direction == BoxDirection.HORIZONTAL
                        && direction == FocusDirection.LEFT))
                    {
                        while (iter.previous ())
                            widgets_before_focused_list.add (iter.get ());
                        iter.last ();
                        while (iter.get () != current) {
                            widgets_after_focused_list.add (iter.get ());
                            iter.previous ();
                        }
                    } else if ((this.direction == BoxDirection.VERTICAL
                        && direction == FocusDirection.DOWN)
                        || (this.direction == BoxDirection.HORIZONTAL
                        && direction == FocusDirection.RIGHT))
                    {
                        while (iter.next ())
                            widgets_before_focused_list.add (iter.get ());
                        iter.first ();
                        while (iter.get () != current) {
                            widgets_after_focused_list.add (iter.get ());
                            iter.next ();
                        }
                    }
                    foreach (var item in widgets_before_focused_list) {
                        var new_focus = item.do_recursive_children ((widget) => {
                            if (widget.focus ())
                                return widget;
                            return null;
                        });
                        if (new_focus != null)
                            return true;
                    }
                }
            }

            if (parent != null && parent.focus_next (direction))
                return true;

            foreach (var item in widgets_after_focused_list) {
                var new_focus = item.do_recursive_children ((widget) => {
                    if (widget.focus ())
                        return widget;
                    return null;
                });
                if (new_focus != null)
                    return true;
            }
            return false;
        }
    }
}
