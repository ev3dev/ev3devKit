/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
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

/* Stack.vala - Container that only displays one child at a time. */

using Curses;
using Grx;

namespace Ev3devKit.Ui {
    /**
     * A container widget that only displays one child at a time.
     *
     * The {@link Widget.visible} property of child widgets will be automatically
     * changed when they are added to the container and when the {@link active_child}
     * of the stack is changed.
     */
    public class Stack : Ev3devKit.Ui.Container {

        weak Widget _active_child;
        /**
         * Gets and sets the active child of the stack.
         */
        public weak Widget active_child {
            get { return _active_child; }
            set {
                if (_active_child == value) {
                    return;
                }
                if (_children.index (value) < 0) {
                    critical ("Stack does not contain the requested child.");
                    return;
                }
                if (_active_child != null) {
                    _active_child.visible = false;
                }
                _active_child = value;
                if (_active_child != null) {
                    _active_child.visible = true;
                }
            }
        }

        construct {
            if (container_type != ContainerType.MULTIPLE) {
                critical ("Requires container_type == ContainerType.MULTIPLE");
            }
            child_added.connect (on_child_added);
            child_removed.connect (on_child_removed);
        }

        /**
         * Creates a new stack.
         */
        public Stack () {
            Object (container_type: ContainerType.MULTIPLE);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            return int.max(1, (active_child == null ? 0 : active_child.get_preferred_width ())
                + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            return int.max(1, (active_child == null ? 0 : active_child.get_preferred_height ())
                + get_margin_border_padding_height ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            result = get_margin_border_padding_width ();
            if (active_child != null) {
                result += active_child.get_preferred_width_for_height (int.max (1,
                    height - get_margin_border_padding_height ()));
            }
            return int.max (1, result);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            result = get_margin_border_padding_height ();
            if (active_child != null) {
                result += active_child.get_preferred_height_for_width (int.max (1,
                    width - get_margin_border_padding_width ()));
            }
            return int.max (1, result);
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            set_child_bounds (active_child, content_bounds.x1, content_bounds.y1,
                content_bounds.x2, content_bounds.y2);
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            active_child.draw ();
        }

        void on_child_added (Widget child) {
            if (_active_child == null) {
                active_child = child;
            } else {
                child.visible = false;
            }
        }

        void on_child_removed (Widget child) {
            if (_active_child == child) {
                active_child = child;
            }
        }
    }
}
