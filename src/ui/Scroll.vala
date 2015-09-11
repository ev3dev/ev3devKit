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
using Grx;

namespace EV3devKit.Ui {
    /**
     * Specifies the direction of scrolling.
     */
    public enum ScrollDirection {
        /**
         * Scroll horizontally.
         */
        HORIZONTAL,
        /**
         * Scroll vertically.
         */
        VERTICAL
    }

    /**
     * Specifies if/when a scrollbar should be displayed.
     */
    public enum ScrollbarVisibility {
        /**
         * The scrollbar is only displayed when the contents are larger than
         * the Scroll area.
         */
        AUTO,
        /**
         * Never show the scrollbar.
         */
        ALWAYS_HIDE,
        /**
         * Always show the scrollbar.
         */
        ALWAYS_SHOW
    }

    /**
     * A scrollable container for displaying content that is too large to fit
     * on the screen.
     */
    public class Scroll : EV3devKit.Ui.Container {
        const int SCROLLBAR_SIZE = 7;

        int scroll_offset;
        int scroll_indicator_size;
        int scroll_indicator_offset;
        bool draw_scrollbar;

        /**
         * Gets the direction of the scrollbar.
         */
        public ScrollDirection direction { get; construct; }

        /**
         * Gets and sets the maximum preferred width for the scroll area.
         */
        public int max_preferred_width { get; set; default = 50; }

        /**
         * Gets and sets the maximum preferred height for the scroll area.
         */
        public int max_preferred_height { get; set; default = 50; }

        /**
         * Gets and sets the visibility of the scrollbar.
         */
        public ScrollbarVisibility scrollbar_visible {
            get; set; default = ScrollbarVisibility.AUTO;
        }

        /**
         * Gets and sets the default scroll distance in pixels used by
         * {@link scroll_forward} and {@link scroll_backward}.
         */
        public int scroll_amount { get; set; default = 8; }

        construct {
            if (container_type != ContainerType.SINGLE)
                critical ("Requires container_type == ContainerType.SINGLE.");
            can_focus = true;
            padding = 2;
            notify["min-height"].connect (redraw);
            notify["min-width"].connect (redraw);
            notify["scrollbar-visible"].connect (redraw);
        }

        private Scroll (ScrollDirection direction) {
            Object (container_type: ContainerType.SINGLE, direction: direction);
        }

        /**
         * Creates a new scroll area that scrolls horizontally.
         */
        public Scroll.horizontal () {
            this (ScrollDirection.HORIZONTAL);
        }

        /**
         * Creates a new scroll area that scrolls vertically.
         */
        public Scroll.vertical () {
            this (ScrollDirection.VERTICAL);
        }

        /**
         * Scroll forward (down or right) by the specified amount.
         *
         * @param amount The amount to scroll in pixels.
         */
        public void scroll_forward (int amount = scroll_amount) {
            scroll_offset += amount;
            redraw ();
        }

        /**
         * Scroll backwards (up or left) by the specified amount.
         * @param amount The amount to scroll in pixels.
         */
        public void scroll_backward (int amount = scroll_amount) {
            scroll_offset -= amount;
            redraw ();
        }

        /**
         * Ensure that a child widget is visible.
         *
         * @param child The child widget to scroll to.
         */
        public void scroll_to_child (Widget child) {
            // check if scroll has been laid out
            if (content_bounds.x1 == content_bounds.x2 || content_bounds.y1 == content_bounds.y2)
                return;

            // make sure this is really a child of this
            var found_child = do_recursive_children ((widget) => {
                if (widget == child)
                    return widget;
                return null;
            });
            if (found_child == null)
                return;

            // make sure layout is up to date.
            _children[0].do_layout ();

            // Make sure that the whole widget is visible. If the widget is
            // larger than the visible area, prefer showing the top and left.
            if (direction == ScrollDirection.VERTICAL) {
                if (child.bounds.y2 > content_bounds.y2)
                    scroll_offset += child.bounds.y2 - content_bounds.y2;
                if (child.bounds.y1 < content_bounds.y1)
                    scroll_offset += child.bounds.y1 - content_bounds.y1;
            } else {
                if (child.bounds.x2 > content_bounds.x2)
                    scroll_offset += child.bounds.x2 - content_bounds.x2;
                if (child.bounds.x1 < content_bounds.x1)
                    scroll_offset += child.bounds.x1 - content_bounds.x1;
            }
            redraw ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            result =  base.get_preferred_width ();
            if (direction == ScrollDirection.VERTICAL && scrollbar_visible != ScrollbarVisibility.ALWAYS_HIDE)
                result += SCROLLBAR_SIZE + padding_right;
            else if (direction == ScrollDirection.HORIZONTAL)
                result = int.min (result, _max_preferred_width);
            return result;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            result =  base.get_preferred_height ();
            if (direction == ScrollDirection.HORIZONTAL && scrollbar_visible != ScrollbarVisibility.ALWAYS_HIDE)
                result += SCROLLBAR_SIZE + padding_bottom;
            else if (direction == ScrollDirection.VERTICAL)
                result = int.min (result, _max_preferred_height);
            return result;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            if (direction == ScrollDirection.VERTICAL)
                result = base.get_preferred_width ();
            else
                result = base.get_preferred_width_for_height (height - SCROLLBAR_SIZE - padding_bottom);
            if (direction == ScrollDirection.VERTICAL && scrollbar_visible != ScrollbarVisibility.ALWAYS_HIDE)
                result += SCROLLBAR_SIZE + padding_right;
            else if (direction == ScrollDirection.HORIZONTAL)
                result = int.min (result, _max_preferred_width);
            return result;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            if (direction == ScrollDirection.HORIZONTAL)
                result = base.get_preferred_height ();
            else
                result = base.get_preferred_height_for_width (width - SCROLLBAR_SIZE - padding_right);
            if (direction == ScrollDirection.HORIZONTAL && scrollbar_visible != ScrollbarVisibility.ALWAYS_HIDE)
                result += SCROLLBAR_SIZE + padding_bottom;
            else if (direction == ScrollDirection.VERTICAL)
                result = int.min (result, _max_preferred_height);
            return result;
        }

        /**
         * Default handler for the key_pressed signal.
         */
        internal override bool key_pressed (uint key_code) {
            if (has_focus) {
                if ((direction == ScrollDirection.VERTICAL && key_code == Key.UP)
                    || (direction == ScrollDirection.HORIZONTAL && key_code == Key.LEFT))
                    scroll_offset -= _scroll_amount;
                else if ((direction == ScrollDirection.VERTICAL && key_code == Key.DOWN)
                    || (direction == ScrollDirection.HORIZONTAL && key_code == Key.RIGHT))
                    scroll_offset += _scroll_amount;
                else
                    return base.key_pressed (key_code);
                redraw ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return base.key_pressed (key_code);
        }

        /**
         * {@inheritDoc}
         */
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
                        child_height = child.get_preferred_height_for_width (
                            content_bounds.width - SCROLLBAR_SIZE - padding_right);
                        draw_scrollbar = true;
                    }
                    scroll_offset = int.min (scroll_offset, child_height - content_bounds.height);
                    scroll_offset = int.max (0, scroll_offset);
                    if (child_height == 0 || child_height == content_bounds.height) {
                        scroll_indicator_size = content_bounds.height - 2;
                        scroll_indicator_offset = 0;
                    } else {
                        scroll_indicator_size = int.min (content_bounds.height,
                            content_bounds.height * content_bounds.height / child_height) - 2;
                        scroll_indicator_size = int.max (scroll_indicator_size, 8);
                        scroll_indicator_offset = (content_bounds.height - scroll_indicator_size - 2)
                            * scroll_offset / (child_height - content_bounds.height);
                    }
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
                        child_width = child.get_preferred_width_for_height (
                            content_bounds.height - SCROLLBAR_SIZE - padding_bottom);
                        draw_scrollbar = true;
                    }
                    scroll_offset = int.min (scroll_offset, child_width - content_bounds.width);
                    scroll_offset = int.max (0, scroll_offset);
                    if (child_width == 0 || child_width == content_bounds.width) {
                        scroll_indicator_size = content_bounds.width - 2;
                        scroll_indicator_offset = 0;
                    } else {
                        scroll_indicator_size = int.min(content_bounds.width,
                            content_bounds.width * content_bounds.width / child_width) - 2;
                        scroll_indicator_size = int.max (scroll_indicator_size, 8);
                        scroll_indicator_offset = (content_bounds.width - scroll_indicator_size - 2)
                            * scroll_offset / (child_width - content_bounds.width);
                    }
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

        /**
         * {@inheritDoc}
         */
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