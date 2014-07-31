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

/* Container.vala - Base class widgets that contain other widgets*/

using Gee;
using U8g;

namespace EV3devTk {

    /**
     * Specifies the number of children a container can have.
     */
    public enum ContainerType {
        /**
         * Container can only have one child.
         */
        SINGLE,
        /**
         * Container can have more than one child.
         */
        MULTIPLE
    }

    public abstract class Container : EV3devTk.Widget {
        protected LinkedList<Widget> _children;

        /**
         * Gets the first child of the Container.
         *
         * Useful when container_type == ContainerType.SINGLE
         */
        public Widget? child {
            owned get {
                if (_children.size == 0)
                    return null;
                return _children.first ();
            }
        }

        /**
         * Gets a read-only list of children of the Container.
         */
        public Gee.List<Widget> children {
            owned get { return _children.read_only_view; }
        }

        public bool descendant_has_focus {
            get {
                foreach (var item in children) {
                    var focused = item.do_recursive_children ((widget) => {
                        if (widget.has_focus)
                            return widget;
                        return null;
                    });
                    if (focused != null)
                        return true;
                }
                return false;
            }
        }

        public virtual ushort max_width {
            get {
                if (parent != null)
                    return parent.max_width - parent.margin_left
                        -parent.margin_right - parent.border_left
                        - parent.border_right - parent.padding_left
                        - parent.padding_right;
                return 0;
            }
        }

        public virtual ushort max_height {
            get {
                if (parent != null)
                    return parent.max_height - parent.margin_left
                        -parent.margin_right - parent.border_left
                        - parent.border_right - parent.padding_left
                        - parent.padding_right;
                return 0;
            }
        }

        public ContainerType container_type { get; private set; }

        public signal void child_added (Widget child);
        public signal void child_removed (Widget child);

        protected Container (ContainerType type) {
            container_type = type;
            _children = new LinkedList<Widget> ();
        }

        public void add (Widget widget) {
            if (widget.parent != null)
                widget.parent.remove (widget);
            if (container_type == ContainerType.SINGLE) {
                if (_children.size > 0)
                    remove (_children.first ());
                _children.offer_head (widget);
            } else
                _children.add (widget);
            widget.parent = this;
            redraw ();
            child_added (widget);
        }

        public void remove (Widget widget) {
            if (_children.remove (widget)) {
                widget.parent = null;
                redraw ();
                child_removed (widget);
            }
        }

        protected override void on_draw (Graphics u8g) {
            foreach (var widget in children)
                widget.draw (u8g);
        }

        internal virtual ushort get_child_x (Widget child)
            requires (children.contains (child))
        {
            switch (child.horizontal_align) {
                case WidgetAlign.FILL:
                case WidgetAlign.START:
                    return x + margin_left + border_left + padding_left;
                case WidgetAlign.CENTER:
                    return x + (width - get_child_width (child)) / 2;
                case WidgetAlign.END:
                    return x + width - margin_right - border_right
                        - padding_right - get_child_width (child);
                default:
                    critical ("Unhandled case");
                    return x;
            }
        }

        internal virtual ushort get_child_y (Widget child)
            requires (children.contains (child))
        {
            switch (child.vertical_align) {
                case WidgetAlign.FILL:
                case WidgetAlign.START:
                    return y + margin_top + border_top + padding_top;
                case WidgetAlign.CENTER:
                    return y + (height - get_child_height (child)) / 2;
                case WidgetAlign.END:
                    return y + height - margin_bottom - border_bottom
                        - padding_bottom - get_child_height (child);
                default:
                    critical ("Unhandled case");
                    return y;
            }
        }

        internal virtual ushort get_child_width (Widget child)
            requires (children.contains (child))
        {
            if (child.horizontal_align == WidgetAlign.FILL)
                return width - margin_left - margin_right - border_left
                    - border_right - padding_left - padding_right;
            return ushort.min (child.preferred_width, max_width);
        }

        internal virtual ushort get_child_height (Widget child)
            requires (children.contains (child))
        {
            if (child.vertical_align == WidgetAlign.FILL)
                return height - margin_top - margin_bottom - border_top
                    - border_bottom - padding_top - padding_bottom;
            return ushort.min (child.preferred_height, max_height);
        }
    }
}
