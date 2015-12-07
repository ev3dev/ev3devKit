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

/* Widget.vala - Base class for all widgets */

using Curses;
using Grx;

/**
 * Library for building user interfaces on small screens (like the EV3 LCD).
 *
 * This library is modeled after GTK (and other modern UI toolkits). It uses
 * {@link Widget}s as the basic building blocks for building the user interface.
 * {@link Container}s are used to group and layout widgets. {@link Window}s are
 * the top-level Container and are displayed to the user using a {@link Screen}
 * that represents a physical screen.
 */
namespace Ev3devKit.Ui {
    /**
     * Used by {@link Widget.do_recursive_parent} and {@link Widget.do_recursive_children}
     * to traverse the widget tree.
     *
     * @param widget The current widget in the recursion.
     * @return ``null`` to continue the recursion or ``widget`` to stop the recursion.
     */
    public delegate Widget? WidgetFunc (Widget widget);

    /**
     * Specifies the direction to use for focusing the next widget.
     */
    public enum FocusDirection {
        /**
         * Focus the next widget above the current widget.
         */
        UP,
        /**
         * Focus the next widget below the current widget.
         */
        DOWN,
        /**
         * Focus the next widget to the left of the current widget.
         */
        LEFT,
        /**
         * Focus the next widget to the right of the current widget.
         */
        RIGHT;
    }

    /**
     * Specifies how a {@link Widget} should be laid out in a {@link Container}.
     */
    public enum WidgetAlign {
        /**
         * The widget should fill the entire container.
         */
        FILL,
        /**
         * The widget should be aligned to the start (top or left) of the container.
         */
        START,
        /**
         * The widget should be aligned to the center (middle) of the container.
         */
        CENTER,
        /**
         * The widget should be aligned to the end (bottom or right) of the container.
         */
        END;
    }

    /**
     * The base class for all UI components.
     *
     * Widgets are modeled after GTK (and other modern UI toolkits). Some of the
     * layout properties should also be familiar to those that use CSS.
     *
     * Each Widget is essentially three concentric rectangles.
     * {{{
     * +---------------------------------+
     * |             margin              |
     * |   +---------border----------+   |
     * |   |         padding         |   |
     * |   |   +-----------------+   |   |
     * |   |   |     content     |   |   |
     * |   |   +-----------------+   |   |
     * |   |                         |   |
     * |   +-------------------------+   |
     * |                                 |
     * +---------------------------------+
     * }}}
     *
     * The margin is used to control spacing between widgets. Nothing should
     * be drawn in the margin. The border is optional and can also have rounded
     * corners. The padding area should be filled with a background color unless
     * the widget is "transparent". The actual graphical representation of the
     * widget is drawn in the content area.
     *
     * Widgets also have a preferred width and height that is used to help
     * {@link Container}s layout child widgets. Widgets that can reflow their
     * contents, such as widgets displaying text, can also provide a preferred
     * width and height for a specified height or width respectively. A
     * Container will try to make each widget at least the requested size. It
     * may stretch the widget if needed but should not make it smaller that the
     * requested size. If a Container does not have enough room for each widget
     * to be at least the requested size, unexpected results my occur. In this
     * case, you should consider using a {@link Scroll} Container.
     */
    public abstract class Widget : Object {
        static int widget_count = 0;

        /* layout properties */

        /* bounding rectangles - set by parent container */

        /**
         * The outermost bounding rectangle.
         */
        protected Rectangle bounds;

        /**
         * The bounding rectangle for the border.
         */
        protected Rectangle border_bounds;

        /**
         * The bounding rectangle for the content area.
         */
        protected Rectangle content_bounds;

        /**
         * Gets and sets the top margin for the widget.
         */
        public int margin_top { get; set; default = 0; }

        /**
         * Gets and sets the bottom margin for the widget.
         */
        public int margin_bottom { get; set; default = 0; }

        /**
         * Gets and sets the left margin for the widget.
         */
        public int margin_left { get; set; default = 0; }

        /**
         * Gets and sets the right margin for the widget.
         */
        public int margin_right { get; set; default = 0; }

        /**
         * Sets all margins (top, bottom, left, right) for the widget.
         */
        public int margin {
            set {
                margin_top = value;
                margin_bottom = value;
                margin_left = value;
                margin_right = value;
            }
        }

        /**
         * Gets and sets the top border width for the widget.
         */
        public int border_top { get; set; default = 0; }

        /**
         * Gets and sets the bottom border width for the widget.
         */
        public int border_bottom { get; set; default = 0; }

        /**
         * Gets and sets the left border width for the widget.
         */
        public int border_left { get; set; default = 0; }

        /**
         * Gets and sets the right border width for the widget.
         */
        public int border_right { get; set; default = 0; }

        /**
         * Sets all border widths (top, bottom, left, right) for the widget.
         */
        public int border {
            set {
                border_top = value;
                border_bottom = value;
                border_left = value;
                border_right = value;
            }
        }

        /**
         * Gets and sets the border radius for the widget.
         */
        public int border_radius { get; set; default = 0; }

        /**
         * Gets and sets the top padding for the widget.
         */
        public int padding_top { get; set; default = 0; }

        /**
         * Gets and sets the bottom padding for the widget.
         */
        public int padding_bottom { get; set; default = 0; }

        /**
         * Gets and sets the left padding for the widget.
         */
        public int padding_left { get; set; default = 0; }

        /**
         * Gets and sets the right padding for the widget.
         */
        public int padding_right { get; set; default = 0; }

        /**
         * Sets all padding (top, bottom, left, right) for the widget.
         */
        public int padding {
            set {
                padding_top = value;
                padding_bottom = value;
                padding_left = value;
                padding_right = value;
            }
        }

        /**
         * Gets and sets the horizontal alignment for the widget.
         *
         * This is used by the parent container to help layout the widget.
         */
        public WidgetAlign horizontal_align {
            get; set; default = WidgetAlign.FILL;
        }

        /**
         * Gets and sets the vertical alignment for the widget.
         *
         * This is used by the parent container to help layout the widget.
         */
        public WidgetAlign vertical_align {
            get; set; default = WidgetAlign.FILL;
        }

        /* navigation properties */

        /**
         * This widget can take the focus.
         *
         * Widgets must also be visible in order to take focus.
         */
        public bool can_focus { get; set; }

        /**
         * Gets and sets the focus of this widget.
         *
         * Setting ``has_focus`` has no effect if either {@link can_focus} or
         * {@link visible} is ``false``.
         */
        public bool has_focus { get; protected set; default = false; }

        weak Widget? _next_focus_widget_up;
        /**
         * Gets and sets the next widget to focus when navigating up.
         *
         * This is used to override the default focus traversal and is not required.
         */
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
        /**
         * Gets and sets the next widget to focus when navigating down.
         *
         * This is used to override the default focus traversal and is not required.
         */
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
        /**
         * Gets and sets the next widget to focus when navigating left.
         *
         * This is used to override the default focus traversal and is not required.
         */
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
        /**
         * Gets and sets the next widget to focus when navigating right.
         *
         * This is used to override the default focus traversal and is not required.
         */
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

        /**
         * Gets the parent Container of this widget.
         *
         * Returns ``null`` if this widget has not been added to a Container.
         */
        public weak Container? parent { get; protected set; }

        /**
         * Gets the top level window for this widget.
         *
         * Returns ``null`` if this widget or none of its Container ancestors
         * have been added to a Window.
         */
        public Window? window {
            owned get {
                return do_recursive_parent ((widget) => {
                    return widget as Window;
                }) as Window;
            }
        }

        /* Other properties */

        /**
         * Gets and sets the visibility of this widget.
         *
         * When a widget is not visible, it still takes up the same amount of
         * space when the parent Container does its layout - it is just not
         * drawn.
         */
        public bool visible { get; set; default = true; }

        /**
         * Gets and sets a weak reference to a user-defined value.
         *
         * This can be used to attach arbitrary data to a widget.
         *
         * If the user data is an Object, then {@link represented_object} should
         * be used instead (so that it will increase the reference count).
         */
        public void *weak_represented_object { get; set; }

        /**
         * Gets and sets a reference to a user-defined Object.
         *
         * This can be used to attach arbitrary data to a widget.
         *
         * If you do not want this widget to have a reference to the Object, then
         * {@link weak_represented_object} should be used instead.
         */
        public Object? represented_object { get; set; }

        construct {
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
            notify["visible"].connect (() => {
                if (parent != null)
                    parent.redraw ();
            });
            widget_count++;
            //debug ("Created %s widget: %p", get_type ().name (), this);
        }

        /**
         * Creates a new instance of a widget.
         */
        protected Widget () {
        }
/*
        ~Widget () {
            debug ("Finalized %s widget %p", get_type ().name (), this);
            debug ("Widget count %d", --widget_count);
        }
*/
        /* layout functions */

        /**
         * Gets the combined width of margins, borders and paddings.
         *
         * Specifically, it is the sum of the left and right margins, the left
         * and right borders and the left and right paddings. It does not
         * include the width of the content area.
         */
        public inline int get_margin_border_padding_width () {
            return _margin_left + _margin_right + _border_left
                + _border_right + _padding_left + _padding_right;
        }

        /**
         * Gets the combined height of margins, borders and paddings.
         *
         * Specifically, it is the sum of the top and bottom margins, the top
         * and bottom borders and the top and bottom paddings. It does not
         * include the width of the content area.
         */
        public inline int get_margin_border_padding_height () {
            return _margin_top + _margin_bottom + _border_top
                + _border_bottom + _padding_top + _padding_bottom;
        }

        /**
         * Gets the preferred width of the widget.
         *
         * This is used by the parent Container to help layout the widget.
         */
        protected virtual int get_preferred_width () ensures (result > 0) {
            return int.max (1, get_margin_border_padding_width ());
        }

        /**
         * Gets the preferred height of the widget.
         *
         * This is used by the parent Container to help layout the widget.
         */
        protected virtual int get_preferred_height () ensures (result > 0) {
            return int.max (1, get_margin_border_padding_height ());
        }

        /**
         * Gets the preferred width of the widget for the specified height.
         *
         * This is used by the parent Container to help layout the widget.
         *
         * @param height The height to be used by the widget.
         */
        protected virtual int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            return get_preferred_width ();
        }

        /**
         * Gets the preferred height of the widget for the specified width.
         *
         * This is used by the parent Container to help layout the widget.
         *
         * @param width The width to be used by the widget.
         */
        protected virtual int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            return get_preferred_height ();
        }

        /**
         * Called by the parent Container to layout this widget.
         */
        protected void set_bounds (int x1, int y1, int x2, int y2)
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

        /**
         * Focuses this widget.
         *
         * @return ``true`` if this widget {@link can_focus} and is {@link visible}
         * or ``false`` if this widget can't be focused.
         */
        public bool focus () {
            if (!can_focus)
                return false;

            // if this widget or any ancestor is not visible, then it can't be focused.
            var not_visible = do_recursive_parent ((widget) => {
                return widget.visible ? null : widget;
            });
            if (not_visible != null) {
                return false;
            }

            // at this point, we know we can focus this widget, so unfocus all
            // other wigets.
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

        /**
         * Focuses the next widget in the specified direction.
         *
         * If this widget has one of the ``next_focus_widget_*`` properties set
         * it will use that value, otherwise, it focus the next widget in the
         * same Window in that direction. Focus will "wrap" around the screen
         * if no widgets are found in the specified direction.
         *
         * @param direction The direction pass the focus.
         */
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
            // In other words, if a widget is the bottom-most and focus direction
            // is down, the next focused widget will be the top-most. Since we
            // are using uint.MAX / 4 here, that means the total height or width
            // including scroll areas cannot exceed that number or unexpected
            // behavior will occur.
            uint best_distance = uint.MAX;
            window.do_recursive_children ((widget) => {
                if (widget == this || !widget.can_focus) {
                    return null;
                }
                var not_visible = widget.do_recursive_parent ((w) => {
                    return w.visible ? null : w;
                });
                if (not_visible != null) {
                    return null;
                }
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
         * @return The focused widget or ``null`` if no widget is focused.
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
         * Run a function recursively over widget and all of its children.
         *
         * The recursion stops when ``func`` returns a non-null value.
         *
         * @param func The function to call for each recursion.
         * @param reverse If ``true`` containers with more than one child will
         * be iterated starting with the last child first.
         * @return The return value of the last call to ``func``.
         */
        public Widget? do_recursive_children (WidgetFunc func, bool reverse = false) {
            return do_recursive_children_internal (this, func, reverse);
        }

        static Widget? do_recursive_children_internal (
            Widget widget, WidgetFunc func, bool reverse)
        {
            var result = func (widget);
            if (result != null)
                return result;
            var container = widget as Container;
            if (container != null && container.children.first () != null) {
                unowned List<Widget> iter;
                if (reverse) {
                    iter = container.children.last ();
                    do {
                        result = do_recursive_children_internal (iter.data, func, reverse);
                        if (result != null)
                            return result;
                    } while ((iter = iter.prev) != null);
                } else {
                    iter = container.children.first ();
                    do {
                        result = do_recursive_children_internal (iter.data, func, reverse);
                        if (result != null)
                            return result;
                    } while ((iter = iter.next) != null);
                }
            }
            return null;
        }

        /**
         * Run a function recursively over widget and all of its ancestors.
         *
         * The recursion stops when ``func`` returns a non-null value.
         *
         * @param func The function to call for each recursion.
         * @return The return value of the last call to ``func``.
         */
        public Widget? do_recursive_parent (WidgetFunc func) {
            return do_recursive_parent_internal (this, func);
        }

        static Widget? do_recursive_parent_internal (
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

        /**
         * Notifies that this widget has changed and needs to be redrawn.
         *
         * If this widget is displayed on a {@link Screen}, the Screen will be
         * redrawn.
         */
        public virtual void redraw () {
            if (_visible && parent != null)
                parent.redraw ();
        }

        /**
         * Implementations should override this method if they need to handle
         * laying out its contents.
         *
         * Mostly just {@link Container}s need to do this.
         */
        protected virtual void do_layout () {
        }

        /**
         * Implementations can override this method if they need to have a
         * a background.
         *
         * Care should be taken to not draw in the margin area and should
         * respect the border radius.
         */
        protected virtual void draw_background () {
        }

        /**
         * Implementations should override this method.
         *
         * Care should be taken to not draw outside of the content area.
         */
        protected virtual void draw_content () {
        }

        /**
         * Implementations can override this if they need special handling for
         * the border.
         *
         * For example Grid also draws a border between rows and columns.
         */
        protected virtual void draw_border (Grx.Color color = window.screen.fg_color) {
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

        internal void draw () {
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

        /**
         * Emitted when a key is pressed.
         *
         * This event is propitiated to all child widgets until a signal handler
         * returns ``true`` to indicate that the key has been handled.
         *
         * Due to a shortcoming in vala, you currently also have to call
         * {{{
         * Signal.stop_emission_by_name (this, "key-pressed");
         * }}}
         * in addition to returning ``true``.
         */
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
