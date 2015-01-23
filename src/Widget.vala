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

/* Widget.vala - Base class for all widgets */

using Curses;
using Gee;
using GRX;

namespace EV3devKit {
    public delegate Widget? WidgetFunc (Widget widget);

    public enum FocusDirection {
        UP,
        DOWN,
        LEFT,
        RIGHT;
    }

    public abstract class Widget : Object {
        static int widget_count = 0;

        /* layout properties */

        /* bounding rectangles - set by parent container */
        protected Rectangle bounds;
        protected Rectangle border_bounds;
        protected Rectangle content_bounds;

        public int margin_top { get; set; default = 0; }
        public int margin_bottom { get; set; default = 0; }
        public int margin_left { get; set; default = 0; }
        public int margin_right { get; set; default = 0; }
        public int margin {
            set {
                margin_top = value;
                margin_bottom = value;
                margin_left = value;
                margin_right = value;
            }
        }

        public int border_top { get; set; default = 0; }
        public int border_bottom { get; set; default = 0; }
        public int border_left { get; set; default = 0; }
        public int border_right { get; set; default = 0; }
        public int border {
            set {
                border_top = value;
                border_bottom = value;
                border_left = value;
                border_right = value;
            }
        }
        public int border_radius { get; set; default = 0; }

        public int padding_top { get; set; default = 0; }
        public int padding_bottom { get; set; default = 0; }
        public int padding_left { get; set; default = 0; }
        public int padding_right { get; set; default = 0; }
        public int padding {
            set {
                padding_top = value;
                padding_bottom = value;
                padding_left = value;
                padding_right = value;
            }
        }

        public WidgetAlign horizontal_align {
            get; set; default = WidgetAlign.FILL;
        }
        public WidgetAlign vertical_align {
            get; set; default = WidgetAlign.FILL;
        }

        /* navigation properties */

        /**
         * This widget can take the focus.
         *
         * Wigets must also be visible in order to take focus.
         */
        public bool can_focus { get; set; }

        /**
         * This widget has focus
         */
        public bool has_focus { get; protected set; default = false; }

        weak Widget? _next_focus_widget_up;
        public Widget? next_focus_widget_up {
            get { return _next_focus_widget_up; }
            set {
                if (_next_focus_widget_up != null)
                    _next_focus_widget_up.weak_unref (remove_next_focus_widget_up);
                _next_focus_widget_up = value;
                if (_next_focus_widget_up != null)
                    _next_focus_widget_up.weak_ref (remove_next_focus_widget_up);
            }
        }

        void remove_next_focus_widget_up (Object obj) {
            _next_focus_widget_up = null;
            notify_property ("next-focus-widget-up");
        }

        weak Widget? _next_focus_widget_down;
        public Widget? next_focus_widget_down {
            get { return _next_focus_widget_down; }
            set {
                if (_next_focus_widget_down != null)
                    _next_focus_widget_down.weak_unref (remove_next_focus_widget_down);
                _next_focus_widget_down = value;
                if (_next_focus_widget_down != null)
                    _next_focus_widget_down.weak_ref (remove_next_focus_widget_down);
            }
        }

        void remove_next_focus_widget_down (Object obj) {
            _next_focus_widget_down = null;
            notify_property ("next-focus-widget-down");
        }

        weak Widget? _next_focus_widget_left;
        public Widget? next_focus_widget_left {
            get { return _next_focus_widget_left; }
            set {
                if (_next_focus_widget_left != null)
                    _next_focus_widget_left.weak_unref (remove_next_focus_widget_left);
                _next_focus_widget_left = value;
                if (_next_focus_widget_left != null)
                    _next_focus_widget_left.weak_ref (remove_next_focus_widget_left);
            }
        }

        void remove_next_focus_widget_left (Object obj) {
            _next_focus_widget_left = null;
            notify_property ("next-focus-widget-left");
        }

        weak Widget? _next_focus_widget_right;
        public Widget? next_focus_widget_right {
            get { return _next_focus_widget_right; }
            set {
                if (_next_focus_widget_right != null)
                    _next_focus_widget_right.weak_unref (remove_next_focus_widget_right);
                _next_focus_widget_right = value;
                if (_next_focus_widget_right != null)
                    _next_focus_widget_right.weak_ref (remove_next_focus_widget_right);
            }
        }

        void remove_next_focus_widget_right (Object obj) {
            _next_focus_widget_right = null;
            notify_property ("next-focus-widget-right");
        }

        public weak Container? parent { get; protected set; }

        public Window? window {
            owned get {
                return do_recursive_parent ((widget) => {
                    return widget as Window;
                }) as Window;
            }
        }

        /* Other properties */

        public bool visible { get; set; default = true; }

        public void *weak_represented_object { get; set; }
        public Object? represented_object { get; set; }

        protected Widget () {
            notify["margin-top"].connect (redraw);
            notify["margin-bottom"].connect (redraw);
            notify["margin-left"].connect (redraw);
            notify["margin-right"].connect (redraw);
            notify["border-top"].connect (redraw);
            notify["border-bottom"].connect (redraw);
            notify["border-left"].connect (redraw);
            notify["border-right"].connect (redraw);
            notify["border-radius"].connect (redraw);
            notify["padding-top"].connect (redraw);
            notify["padding-bottom"].connect (redraw);
            notify["padding-left"].connect (redraw);
            notify["padding-right"].connect (redraw);
            notify["horizontal-align"].connect (redraw);
            notify["vertical-align"].connect (redraw);
            notify["can-focus"].connect (redraw);
            notify["has-focus"].connect (redraw);
            notify["visible"].connect (redraw);
            widget_count++;
            //debug ("Created %s widget: %p", get_type ().name (), this);
        }
/*
        ~Widget () {
            debug ("Finalized %s widget %p", get_type ().name (), this);
            debug ("Widget count %d", --widget_count);
        }
*/
        /* layout functions */

        public inline int get_margin_border_padding_width () {
            return _margin_left + _margin_right + _border_left
                + _border_right + _padding_left + _padding_right;
        }

        public inline int get_margin_border_padding_height () {
            return _margin_top + _margin_bottom + _border_top
                + _border_bottom + _padding_top + _padding_bottom;
        }

        public virtual int get_preferred_width () ensures (result > 0) {
            return int.max (1, get_margin_border_padding_width ());
        }

        public virtual int get_preferred_height () ensures (result > 0) {
            return int.max (1, get_margin_border_padding_height ());
        }

        public virtual int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            return get_preferred_width ();
        }

        public virtual int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            return get_preferred_height ();
        }

        public void set_bounds (int x1, int y1, int x2, int y2)
            requires (x1 <= x2 && y1 <= y2)
        {
            bounds.x1 = x1;
            bounds.y1 = y1;
            bounds.x2 = x2;
            bounds.y2 = y2;
            border_bounds.x1 = x1 + margin_left;
            border_bounds.y1 = y1 + margin_top;
            border_bounds.x2 = x2 - margin_right;
            border_bounds.y2 = y2 - margin_bottom;
            content_bounds.x1 = x1 + margin_left + border_left + padding_left;
            content_bounds.y1 = y1 + margin_top + border_top + padding_top;
            content_bounds.x2 = x2 - margin_right - border_right - padding_right;
            content_bounds.y2 = y2 - margin_bottom - border_bottom - padding_bottom;
        }

        /* navigation functions */

        public bool focus () {
            if (!can_focus || !visible)
                return false;
            if (window != null) {
                window.do_recursive_children ((widget) => {
                    widget.has_focus = false;
                    return null;
                });
            }
            has_focus = true;
            redraw ();
            return true;
        }

        public void focus_next (FocusDirection direction) {
            if (window == null)
                return;
            weak Widget best = this;
            // first, check to see if next focus was set manually.
            switch (direction) {
            case FocusDirection.UP:
                if (_next_focus_widget_up != null)
                    best = _next_focus_widget_up;
                break;
            case FocusDirection.DOWN:
                if (_next_focus_widget_down != null)
                    best = _next_focus_widget_down;
                break;
            case FocusDirection.LEFT:
                if (_next_focus_widget_left != null)
                    best = _next_focus_widget_left;
                break;
            case FocusDirection.RIGHT:
                if (_next_focus_widget_right != null)
                    best = _next_focus_widget_right;
                break;
            }
            if (best != this) {
                best.focus ();
                return;
            }
            // if next focus was not specified, make an educated guess by
            // comparing the distance between the centers of widgets. Widgets
            // that are inline with each other are preferred. By "inline" we
            // mean that if the currently focused widget were expanded
            // infinitely either vertically or horizontally depending on the
            // focus direction, it would intersect the widget that we are
            // testing. If widgets are not inline, we add uint.MAX / 2 to the
            // distance between them so that they will only be the best if there
            // are no other inline widgets. If the widget being testing is in
            // the opposite direction of the currently focused widget, we add
            // uint.MAX / 4 to the distance. This allows focus to wrap around.
            // In other words, if a widget is the bottom-most an focus direction
            // is down, the next focused widget will be the top-most. Since we
            // are using uint.MAX / 4 here, that means the total height or width
            // including scroll areas cannot exceed that number or unexpected
            // behavior will occur.
            uint best_distance = uint.MAX;
            window.do_recursive_children ((widget) => {
                if (widget == this || !widget.can_focus || !widget.visible)
                    return null;
                uint widget_distance_x = 0;
                if (widget.border_bounds.x1 > border_bounds.x1 || widget.border_bounds.x2 < border_bounds.x2)
                    widget_distance_x = ((widget.border_bounds.x1 + widget.border_bounds.x2)
                        - (border_bounds.x1 + border_bounds.x2)).abs ();
                uint widget_distance_y = 0;
                if (widget.border_bounds.y1 > border_bounds.y1 || widget.border_bounds.y2 < border_bounds.y2)
                    widget_distance_y = ((widget.border_bounds.y1 + widget.border_bounds.y2)
                        - (border_bounds.y1 + border_bounds.y2)).abs ();
                switch (direction) {
                case FocusDirection.UP:
                    widget_distance_y = (widget.border_bounds.y2 - border_bounds.y1).abs ();
                    if (widget.border_bounds.y1 >= border_bounds.y1)
                        widget_distance_y = uint.MAX / 4 - widget_distance_y;
                    if (widget.border_bounds.x1 > border_bounds.x2 || widget.border_bounds.x2 < border_bounds.x1)
                        widget_distance_x += uint.MAX / 2;
                    break;
                case FocusDirection.DOWN:
                    widget_distance_y = (widget.border_bounds.y1 - border_bounds.y2).abs ();
                    if (widget.border_bounds.y2 <= border_bounds.y2)
                        widget_distance_y = uint.MAX / 4 - widget_distance_y;
                    if (widget.border_bounds.x1 > border_bounds.x2 || widget.border_bounds.x2 < border_bounds.x1)
                        widget_distance_x += uint.MAX / 2;
                    break;
                case FocusDirection.LEFT:
                    widget_distance_x = (widget.border_bounds.x2 - border_bounds.x1).abs ();
                    if (widget.border_bounds.x1 >= border_bounds.x1)
                        widget_distance_x = uint.MAX / 4 - widget_distance_x;
                    if (widget.border_bounds.y1 > border_bounds.y2 || widget.border_bounds.y2 < border_bounds.y1)
                        widget_distance_y += uint.MAX / 2;
                    break;
                case FocusDirection.RIGHT:
                    widget_distance_x = (widget.border_bounds.x1 - border_bounds.x2).abs ();
                    if (widget.border_bounds.x2 <= border_bounds.x2)
                        widget_distance_x = uint.MAX / 4 - widget_distance_x;
                    if (widget.border_bounds.y1 > border_bounds.y2 || widget.border_bounds.y2 < border_bounds.y1)
                        widget_distance_y += uint.MAX / 2;
                    break;
                }
                if ((widget_distance_x + widget_distance_y) < best_distance) {
                    best = widget;
                    best_distance = widget_distance_x + widget_distance_y;
                }
                return null;
            });
            // if we could not find another widget nearby, focus the next widget
            // in the window or if all else fails, the first widget in the window.
            if (best == this) {
                var found_this = false;
                weak Widget first = null;
                var next = window.do_recursive_children ((widget) => {
                    if (!widget.can_focus || !widget.visible)
                        return null;
                    if (found_this)
                        return widget;
                    if (widget == this)
                        found_this = true;
                    else if (first == null)
                        first = widget;
                    return null;
                }, direction == FocusDirection.UP || direction == FocusDirection.LEFT);
                best = next ?? first;
            }
            if (best != null)
                best.focus ();
        }

        /**
         * Searches this Widget and its children for the currently focused widget.
         *
         * @return The focused widget or "null" if no widget is focused.
         */
        public Widget? get_focused_child () {
            return do_recursive_children ((widget) => {
                if (widget.has_focus)
                    return widget;
                return null;
            });
        }

        /* tree traversal functions */

        /**
         * Run a function recursively over widget and all of its children
         * (if any). The recursion stops when func returns a non-null
         * value. That value is returned by do_recursive_children.
         */
        public Widget? do_recursive_children (WidgetFunc func, bool reverse = false) {
            return do_recursive_children_internal (this, func, reverse);
        }

        public static Widget? do_recursive_children_internal (
            Widget widget, WidgetFunc func, bool reverse)
        {
            var result = func (widget);
            if (result != null)
                return result;
            var container = widget as Container;
            if (container != null && container.children.size > 0) {
                var iter = container.children.bidir_list_iterator ();
                if (reverse) {
                    iter.last ();
                    do {
                        result = do_recursive_children_internal (iter.get (), func, reverse);
                        if (result != null)
                            return result;
                    } while (iter.previous ());
                } else {
                    iter.first ();
                    do {
                        result = do_recursive_children_internal (iter.get (), func, reverse);
                        if (result != null)
                            return result;
                    } while (iter.next ());
                }
            }
            return null;
        }

        /**
         * Run a function recursively over widget and all of its ancestors
         * (if any). The recursion stops when func returns a non-null
         * value. That value is returned by do_recursive_parent.
         */
        public Widget? do_recursive_parent (WidgetFunc func) {
            return do_recursive_parent_internal (this, func);
        }

        public static Widget? do_recursive_parent_internal (
            Widget widget, WidgetFunc func)
        {
            var result = func (widget);
            if (result != null)
                return result;
            if (widget.parent != null)
                return do_recursive_parent_internal (widget.parent, func);
            return null;
        }

        /* drawing functions */

        public virtual void redraw () {
            if (parent != null)
                parent.redraw ();
        }

        protected virtual void do_layout () {
        }

        protected virtual void draw_background () {
        }

        protected virtual void draw_content () {
        }

        protected virtual void draw_border (GRX.Color color = window.screen.fg_color) {
            if (border_top != 0)
                filled_box (border_bounds.x1 + border_radius, border_bounds.y1,
                    border_bounds.x2 - border_radius,
                    border_bounds.y1 + border_top - 1, color);
            if (border_bottom != 0)
                filled_box (border_bounds.x1 + border_radius,
                    border_bounds.y2 - border_bottom + 1,
                    border_bounds.x2 - border_radius, border_bounds.y2, color);
            if (border_left != 0)
                filled_box (border_bounds.x1, border_bounds.y1 + border_radius,
                    border_bounds.x1 + border_left- 1,
                    border_bounds.y2 - border_radius, color);
            if (border_right != 0)
                filled_box (border_bounds.x2 - border_left + 1,
                    border_bounds.y1 + border_radius, border_bounds.x2,
                    border_bounds.y2 - border_radius, color);
            if (border_radius != 0) {
                circle_arc (border_bounds.x2 - border_radius,
                    border_bounds.y1 + border_radius, border_radius, 0, 900,
                    ArcStyle.OPEN, color);
                circle_arc (border_bounds.x1 + border_radius,
                    border_bounds.y1 + border_radius, border_radius, 900, 1800,
                    ArcStyle.OPEN, color);
                circle_arc (border_bounds.x1 + border_radius,
                    border_bounds.y2 - border_radius, border_radius, 1800, 2700,
                    ArcStyle.OPEN, color);
                circle_arc (border_bounds.x2 - border_radius,
                    border_bounds.y2 - border_radius, border_radius, 2700, 3600,
                    ArcStyle.OPEN, color);
            }
        }

        public void draw () {
            if (!visible)
                return;
            int x1;
            int y1;
            int x2;
            int y2;
            get_clip_box (out x1, out y1, out x2, out y2);
            if (bounds.x1 > x2 || bounds.y1 > y2 || bounds.x2 < x1 || bounds.y2 < y1)
                return;
            do_layout ();
            draw_background ();
            draw_content ();
            draw_border ();
        }

        /* input handling */

        public virtual signal bool key_pressed (uint key_code) {
            if (can_focus && visible) {
                FocusDirection direction;
                switch (key_code) {
                case Key.UP:
                    direction = FocusDirection.UP;
                    break;
                case Key.DOWN:
                    direction = FocusDirection.DOWN;
                    break;
                case Key.LEFT:
                    direction = FocusDirection.LEFT;
                    break;
                case Key.RIGHT:
                    direction = FocusDirection.RIGHT;
                    break;
                default:
                    return false;
                }
                focus_next (direction);
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return false;
        }
    }
}
