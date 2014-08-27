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

/* Scroll.vala - Container that can scroll */

using Curses;
using Gee;
using GRX;

namespace EV3devKit {
    public enum ScrollDirection {
        HORIZONTAL,
        VERTICAL
    }

    public enum ScrollbarVisibility {
        AUTO,
        ALWAYS_HIDE,
        ALWAYS_SHOW
    }

    public class Scroll : EV3devKit.Container {
        public const int SCROLLBAR_SIZE = 7;

        ScrollDirection direction;
        int scroll_offset;
        int scroll_indicator_size;
        int scroll_indicator_offset;
        bool draw_scrollbar;

        public int min_height { get; set; default = 100; }
        public int min_width { get; set; default = 100; }
        public ScrollbarVisibility scrollbar_visible {
            get; set; default = ScrollbarVisibility.AUTO;
        }

        Scroll (ScrollDirection direction) {
            base (ContainerType.SINGLE);
            this.direction = direction;
            can_focus = true;
            border = 1;
            padding = 2;
            notify["min-height"].connect (redraw);
            notify["min-width"].connect (redraw);
            notify["scrollbar-visible"].connect (redraw);
        }

        public Scroll.horizontal () {
            this (ScrollDirection.HORIZONTAL);
        }

        public Scroll.vertical () {
            this (ScrollDirection.VERTICAL);
        }

        /**
         * update scroll_offset so that top/right of child widget is visible
         */
        public void scroll_to_child (Widget child) {
            // make sure this is really a child of this
            var found_child = do_recursive_children ((widget) => {
                if (widget == child)
                    return widget;
                return null;
            });
            if (found_child == null)
                return;
            if (direction == ScrollDirection.VERTICAL) {
                if (child.bounds.y1 < content_bounds.y1)
                    scroll_offset += child.bounds.y1 - content_bounds.y1;
                if (child.bounds.y2 > content_bounds.y2)
                    scroll_offset += child.bounds.y2 - content_bounds.y2;
            } else {
                if (child.bounds.x1 < content_bounds.x1)
                    scroll_offset += child.bounds.x1 - content_bounds.x1;
                if (child.bounds.x2 > content_bounds.x2)
                    scroll_offset += child.bounds.x2 - content_bounds.x2;
            }
            redraw ();
        }

        public override int get_preferred_width () {
            return _min_width;
        }

        public override int get_preferred_height () {
            return _min_height;
        }

        public override int get_preferred_width_for_height (int height) requires (height > 0) {
            return _min_width;
        }

        public override int get_preferred_height_for_width (int width) requires (width > 0) {
            return _min_height;
        }

        protected override bool key_pressed (uint key_code) {
            if (has_focus) {
                if ((direction == ScrollDirection.VERTICAL && key_code == Key.UP)
                    || (direction == ScrollDirection.HORIZONTAL && key_code == Key.LEFT))
                    scroll_offset -= 8;
                else if ((direction == ScrollDirection.VERTICAL && key_code == Key.DOWN)
                    || (direction == ScrollDirection.HORIZONTAL && key_code == Key.RIGHT))
                    scroll_offset += 8;
                else
                    return base.key_pressed (key_code);
                redraw ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return base.key_pressed (key_code);
        }

        protected override void do_layout () {
            if (direction == ScrollDirection.VERTICAL) {
                var child_height = 0;
                draw_scrollbar = false;
                if (child != null) {
                    if (scrollbar_visible != ScrollbarVisibility.ALWAYS_SHOW)
                        child_height = child.get_preferred_height_for_width (content_bounds.width);
                    if (scrollbar_visible == ScrollbarVisibility.ALWAYS_SHOW
                        || (scrollbar_visible == ScrollbarVisibility.AUTO
                            && child_height > content_bounds.height))
                    {
                        child_height = child.get_preferred_height_for_width (content_bounds.width - SCROLLBAR_SIZE);
                        draw_scrollbar = true;
                    }
                    scroll_offset = int.min (scroll_offset, child_height - content_bounds.height);
                    scroll_offset = int.max (0, scroll_offset);
                    scroll_indicator_size = int.min (content_bounds.height,
                        content_bounds.height * content_bounds.height / child_height) - 2;
                    scroll_indicator_offset = content_bounds.height * scroll_offset / child_height;
                    set_child_bounds (child, content_bounds.x1, content_bounds.y1 - scroll_offset,
                        content_bounds.x2 - (draw_scrollbar ? SCROLLBAR_SIZE + padding_right + 1 : 0),
                        content_bounds.y1 - scroll_offset + child_height -1);
                } else if (scrollbar_visible == ScrollbarVisibility.ALWAYS_SHOW) {
                    draw_scrollbar = true;
                    scroll_indicator_size = content_bounds.height - 2;
                    scroll_indicator_offset = 0;
                }
            } else {
                var child_width = 0;
                draw_scrollbar = false;
                if (child != null) {
                    if (scrollbar_visible != ScrollbarVisibility.ALWAYS_SHOW)
                        child_width = child.get_preferred_width_for_height (content_bounds.height);
                    if (scrollbar_visible == ScrollbarVisibility.ALWAYS_SHOW
                        || (scrollbar_visible == ScrollbarVisibility.AUTO
                            && child_width > content_bounds.height))
                    {
                        child_width = child.get_preferred_width_for_height (content_bounds.height - SCROLLBAR_SIZE);
                        draw_scrollbar = true;
                    }
                    scroll_offset = int.min (scroll_offset, child_width - content_bounds.width);
                    scroll_offset = int.max (0, scroll_offset);
                    scroll_indicator_size = int.min(content_bounds.width,
                        content_bounds.width * content_bounds.width / child_width) - 2;
                    scroll_indicator_offset = content_bounds.width * scroll_offset / child_width;
                    set_child_bounds (child, content_bounds.x1 - scroll_offset, content_bounds.y1,
                        content_bounds.x1 - scroll_offset + child_width -1,
                        content_bounds.y2 - (draw_scrollbar ? SCROLLBAR_SIZE + padding_bottom + 1 : 0));
                } else if (scrollbar_visible == ScrollbarVisibility.ALWAYS_SHOW) {
                    draw_scrollbar = true;
                    scroll_indicator_size = content_bounds.width - 2;
                    scroll_indicator_offset = 0;
                }
            }
        }

        protected override void draw_content () {
            do_layout ();
            var color = has_focus ? window.screen.mid_color : window.screen.fg_color;
            var x = content_bounds.x2;
            if (direction == ScrollDirection.VERTICAL && draw_scrollbar) {
                x -= SCROLLBAR_SIZE;
                box (x, content_bounds.y1, content_bounds.x2,
                    content_bounds.y2, color);
                filled_rounded_box (x + 2, content_bounds.y1 + scroll_indicator_offset + 2,
                    content_bounds.x2 - 2, content_bounds.y1 + scroll_indicator_offset 
                        + scroll_indicator_size - 1, 2, color);
                if (has_focus)
                    filled_box (x + 3, content_bounds.y1 + scroll_indicator_offset + 3,
                        content_bounds.x2 - 3, content_bounds.y1 + scroll_indicator_offset 
                            + scroll_indicator_size - 2, window.screen.bg_color);
            }
            var y = content_bounds.y2;
            if (direction == ScrollDirection.HORIZONTAL && draw_scrollbar) {
                y -= SCROLLBAR_SIZE;
                box (content_bounds.x1, y, content_bounds.x2,
                    content_bounds.y2, color);
                filled_rounded_box (content_bounds.x1  + scroll_indicator_offset + 2,
                    y + 2, content_bounds.x1 + scroll_indicator_offset 
                        + scroll_indicator_size - 1, content_bounds.y2 - 2, 2, color);
                if (has_focus)
                    filled_box (content_bounds.x1  + scroll_indicator_offset + 3,
                        y + 3, content_bounds.x1 + scroll_indicator_offset 
                            + scroll_indicator_size - 2, content_bounds.y2 - 3, window.screen.bg_color);
            }
            if (child != null) {
                set_clip_box (content_bounds.x1, content_bounds.y1, x, y);
                child.draw ();
                reset_clip_box ();
            }
        }
    }
}