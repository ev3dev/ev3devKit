/*
 * EV3devKit.UI - ev3dev toolkit for LEGO MINDSTORMS EV3
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

/* Box.vala - {@link Container} for displaying widgets horizontally or vertically */

using Gee;
using GRX;

namespace EV3devKit.UI {

    /**
     * Specifies the number of children a container can have.
     */
    public enum BoxDirection {
        /**
         * The Box lays out widgets in a horizontal row.
         */
        HORIZONTAL,
        /**
         * The Box lays out widgets in a vertical column.
         */
        VERTICAL;
    }

    /**
     * Container for laying out widgets horizontally or vertically.
     *
     * A horizontal box with 3 children might look like this:
     *
     * {{{
     * +-----+-----+----------------+
     * |     |     |                |
     * |  1  |  2  |       3        |
     * |     |     |                |
     * +-----+-----+----------------+
     * }}}
     *
     * If the last child Widget has ``horizontal_align == WidgetAlign.FILL``
     * and there are no {@link Spacer} child widgets, the last widget will be
     * stretched to fill the remaining space. Otherwise, the {@link Widget.horizontal_align}
     * property will have no effect.
     *
     * The {@link Widget.vertical_align} property can be used to position the
     * child widgets vertically. {@link WidgetAlign.START} will align the widget
     * to the top of the Box, {@link WidgetAlign.CENTER} will align it in the
     * middle of the Box, {@link WidgetAlign.END} will align it to the bottom of
     * the box and {@link WidgetAlign.FILL} will use the entire height of the box.
     *
     * Vertical boxes work similarly except the vertical and horizontal properties
     * are swapped.
     */
    public class Box : EV3devKit.UI.Container {
        /**
         * Gets the layout direction of the Box.
         */
        public BoxDirection direction { get; construct set; }

        /**
         * Gets and sets the spacing in pixels between the widgets in the box.
         *
         * Default value is 2 pixels.
         */
        public int spacing { get; set; default = 2; }

        /**
         * Create a new instance of Box.
         *
         * @param direction The direction to layout widgets.
         */
        Box (BoxDirection direction) {
             base (ContainerType.MULTIPLE);
             this.direction = direction;
             notify["spacing"].connect (redraw);
        }

        /**
         * Create a new instance of Box with widgets laid out vertically.
         */
        public Box.vertical () {
            this (BoxDirection.VERTICAL);
        }

        /**
         * Create a new instance of Box with widgets laid out horizontally.
         */
        public Box.horizontal () {
            this (BoxDirection.HORIZONTAL);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            int width = 0;
            if (direction == BoxDirection.HORIZONTAL) {
                foreach (var item in _children)
                    width += item.get_preferred_width () + spacing;
                width -= spacing;
            } else {
                foreach (var item in _children)
                    width = int.max (width, item.get_preferred_width ());
            }
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            int height = 0;
            if (direction == BoxDirection.VERTICAL) {
                foreach (var item in _children)
                    height += item.get_preferred_height () + spacing;
                height -= spacing;
            } else {
                foreach (var item in _children)
                    height = int.max (height, item.get_preferred_height ());
            }
            return int.max (1, height + get_margin_border_padding_height ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0)  ensures (result > 0)
        {
            int width = 0;
            if (direction == BoxDirection.HORIZONTAL) {
                foreach (var item in _children)
                    width += item.get_preferred_width_for_height (height) + spacing;
                width -= spacing;
            } else {
                foreach (var item in _children)
                    width = int.max (width, item.get_preferred_width_for_height (height));
            }
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            int height = 0;
            if (direction == BoxDirection.VERTICAL) {
                foreach (var item in _children)
                    height += item.get_preferred_height_for_width (width) + spacing;
                height -= spacing;
            } else {
                foreach (var item in _children)
                    height = int.max (height, item.get_preferred_height_for_width (width));
            }
            return int.max (1, height + get_margin_border_padding_height ());
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            if (direction == BoxDirection.HORIZONTAL) {
                int total_width = 0;
                int spacer_count = 0;
                int fill_count = 0;
                HashMap<Widget, int> width_map = new HashMap<Widget,int> ();
                foreach (var child in _children) {
                    width_map[child] = child.get_preferred_width_for_height (content_bounds.height);
                    total_width += width_map[child];
                    total_width += spacing;
                    if (child is Spacer)
                        spacer_count++;
                    else if (child.horizontal_align == WidgetAlign.FILL)
                        fill_count++;
                }
                total_width -= spacing;
                var x = content_bounds.x1;
                var extra_space = int.max (0, content_bounds.width - total_width);
                foreach (var child in _children) {
                    if (spacer_count > 0) {
                        if (child is Spacer) {
                            var spacer_width = extra_space / spacer_count;
                            width_map[child] = spacer_width;
                            extra_space -= spacer_width;
                            spacer_count--;
                        }
                    } else if (fill_count > 0 && child.horizontal_align == WidgetAlign.FILL) {
                        var fill_width = extra_space / fill_count;
                        width_map[child] = width_map[child] + fill_width; // += does not work!
                        extra_space -= fill_width;
                        fill_count--;
                    }
                    width_map[child] = int.max (width_map[child], 1);
                    set_child_bounds (child, x, content_bounds.y1,
                        x + width_map[child] - 1, content_bounds.y2);
                    x += width_map[child] + spacing;
                }
            } else {
                int total_height = 0;
                int spacer_count = 0;
                int fill_count = 0;
                HashMap<Widget, int> height_map = new HashMap<Widget, int> ();
                foreach (var child in _children) {
                    height_map[child] = child.get_preferred_height_for_width (content_bounds.width);
                    total_height += height_map[child];
                    total_height += spacing;
                    if (child is Spacer)
                        spacer_count++;
                    else if (child.vertical_align == WidgetAlign.FILL)
                        fill_count++;
                }
                total_height -= spacing;
                var y = content_bounds.y1;
                var extra_space = int.max (0, content_bounds.height - total_height);
                foreach (var child in _children) {
                    if (spacer_count > 0) {
                        if (child is Spacer) {
                            var spacer_height = extra_space / spacer_count;
                            height_map[child] = spacer_height;
                            extra_space -= spacer_height;
                            spacer_count--;
                        }
                    } else if (fill_count > 0 && child.vertical_align == WidgetAlign.FILL) {
                        var fill_height = extra_space / fill_count;
                        height_map[child] = height_map[child] + fill_height; // += does not work!
                        extra_space -= fill_height;
                        fill_count--;
                    }
                    height_map[child] = int.max (height_map[child], 1);
                    set_child_bounds (child, content_bounds.x1, y,
                        content_bounds.x2, y + height_map[child] - 1);
                    y += height_map[child] + spacing;
                }
            }
        }
    }
}
