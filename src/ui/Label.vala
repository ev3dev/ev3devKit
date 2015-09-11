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

/* Label.vala - Widget to display text */

using Gee;
using Grx;

namespace EV3devKit.Ui {
    /**
     * Widget to display text.
     *
     * The text will be automatically wrapped if the parent Container is not
     * wide enough to fit the entire text value.
     */
    public class Label : EV3devKit.Ui.Widget {
        internal static Font _default_font;
        internal static weak Font default_font;

        // TODO: This is a problem if we try to use default_font before creating an instance of Label
        static construct {
            _default_font = Font.load ("xm6x8");
            default_font = _default_font ??  Font.pc6x8;
        }

        TextOption text_option;
        Gee.List<string>? cached_lines;
        int last_width = 0;

        /**
         * Gets and sets the text displayed by this Label.
         */
        public string? text { get; set construct; }

        /**
         * Gets and sets the Font.
         */
        public unowned Font font {
            get {return text_option.font; }
            set { text_option.font = value; }
        }

        /**
         * Gets and sets the horizontal text alignment.
         */
        public TextHorizAlign text_horizontal_align {
            get { return text_option.x_align; }
            set { text_option.x_align = value; }
        }

        /**
         * Gets and sets the vertical text alignment.
         */
        public TextVertAlign text_vertical_align {
            get { return text_option.y_align; }
            set { text_option.y_align = value; }
        }

        construct {
            text_option = new TextOption () {
                font = default_font,
                direction = TextDirection.RIGHT,
                chr_type = ChrType.BYTE,
                x_align = TextHorizAlign.CENTER,
                y_align = TextVertAlign.MIDDLE
            };
            notify["text"].connect (redraw);
            notify["font"].connect (redraw);
            notify["text-horizontal-align"].connect (redraw);
            notify["text-vertical-align"].connect (redraw);
        }

        /**
         * Creates a new instance of a Label widget.
         *
         * @param text The text displayed by this Label.
         */
        public Label (string? text = null) {
            Object (text: text);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            return int.max(1, font.vala_string_width (text ?? ""))
                + get_margin_border_padding_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            return int.max(1, (int)font.height) + get_margin_border_padding_height ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            // TODO: create get_lines_for_height () method
            return get_preferred_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            var lines = get_lines_for_width (width);
            return int.max(1, (int)font.height * lines.size)
                + get_margin_border_padding_height ();
        }

        Gee.List<string> get_lines_for_width (int width) requires (width > 0) {
            if (cached_lines != null && width == last_width)
                return cached_lines;
            cached_lines = new LinkedList<string> ();
            if (text == null)
                return cached_lines;
            var hard_lines = text.split ("\n");
            foreach (var line in hard_lines)
                cached_lines.add_all (get_substring_lines_for_width (line, width));

            return cached_lines;
        }

        Gee.List<string> get_substring_lines_for_width (string substring, int width) {
            var lines = new LinkedList<string> ();
            // if everything fits on one line...
            if (font.vala_string_width (substring) <= width) {
                lines.add (substring);
                return lines;
            }
            // otherwise we have to spilt it into multiple lines
            var builder = new StringBuilder ();
            int i = 0;
            while (i < substring.length) {
                while (font.vala_string_width (builder.str) < width) {
                    if (i == substring.length)
                        break;
                    builder.append_c (substring[i++]);
                }
                if (i < substring.length || font.vala_string_width (builder.str) > width) {
                    var last_space_index = builder.str.last_index_of (" ");
                    if (last_space_index >= 0) {
                        i -= (int)builder.len;
                        builder.truncate (last_space_index);
                        i += last_space_index + 1;
                    } else if (builder.len > 1) {
                        builder.truncate (builder.len - 1);
                        i--;
                    }
                }
                lines.add (builder.str);
                builder.truncate ();
            }
            return lines;
        }

        /**
         * {@inheritDoc}
         */
        protected override void redraw () {
            cached_lines = null;
            base.redraw ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            if (_text == null)
                return;
            if (parent.draw_children_as_focused)
                text_option.fg_color = (TextColor)window.screen.bg_color;
            else
                text_option.fg_color = (TextColor)window.screen.fg_color;
            text_option.bg_color = (TextColor)Grx.Color.no_color;
            int x = 0;
            switch (text_horizontal_align) {
            case TextHorizAlign.LEFT:
                x = content_bounds.x1;
                break;
            case TextHorizAlign.CENTER:
                x = content_bounds.x1 + content_bounds.width / 2;
                break;
            case TextHorizAlign.RIGHT:
                x = content_bounds.x2;
                break;
            }
            var lines = get_lines_for_width (content_bounds.width);
            int y = 0;
            switch (text_vertical_align) {
            case TextVertAlign.TOP:
                y = content_bounds.y1;
                break;
            case TextVertAlign.MIDDLE:
                y = content_bounds.y1 + (content_bounds.height + 1) / 2
                    - (int)font.height * (lines.size - 1) / 2;
                break;
            case TextVertAlign.BOTTOM:
                y = content_bounds.y2;
                break;
            }
            foreach (var item in lines) {
                draw_vala_string (item, x, y, text_option);
                y += (int)font.height;
            }
        }
    }
}
