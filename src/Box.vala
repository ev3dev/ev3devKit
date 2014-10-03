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

/* Box.vala - Container for displaying widgets horizontally or vertically */

using Gee;
using GRX;

namespace EV3devKit {

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

    public class Box : EV3devKit.Container {
        public BoxDirection direction { get; private set; }
        public int spacing { get; set; default = 2; }

         Box (BoxDirection direction) {
             base (ContainerType.MULTIPLE);
             this.direction = direction;
             notify["spacing"].connect (redraw);
        }

        public Box.vertical () {
            this (BoxDirection.VERTICAL);
        }

        public Box.horizontal () {
            this (BoxDirection.HORIZONTAL);
        }

        public override int get_preferred_width () ensures (result > 0) {
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

        public override int get_preferred_height () ensures (result > 0) {
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

        public override int get_preferred_width_for_height (int height)
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

        public override int get_preferred_height_for_width (int width)
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

        public override void do_layout () {
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
                    set_child_bounds (child, content_bounds.x1, y,
                        content_bounds.x2, y + height_map[child] - 1);
                    y += height_map[child] + spacing;
                }
            }
        }
    }
}
