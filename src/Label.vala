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
using GRX;

namespace EV3devKit {
    public class Label : EV3devKit.Widget {
        Gee.List<string>? cached_lines;
        int last_width = 0;

        public string? text { get; set; }

        TextOption text_option;
        public unowned Font font {
            get {return text_option.font; }
            set { text_option.font = value; }
        }
        public TextHorizAlign text_horizontal_align {
            get { return text_option.x_align; }
            set { text_option.x_align = value; }
        }
        public TextVertAlign text_vertical_align {
            get { return text_option.y_align; }
            set { text_option.y_align = value; }
        }

        public Label (string? text = null) {
            this.text = text;
            text_option = new TextOption () {
                font = Font.pc6x8,
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

        public override int get_preferred_width () {
            return font.vala_string_width (text) + get_margin_border_padding_width ();
        }
        public override int get_preferred_height () {
            return (int)font.height + get_margin_border_padding_height ();
        }

        public override int get_preferred_width_for_height (int height) requires (height > 0) {
            // TODO: create get_lines_for_height () method
            return get_preferred_width ();
        }
        public override int get_preferred_height_for_width (int width) requires (width > 0) {
            var lines = get_lines_for_width (width);
            return (int)font.height * lines.size + get_margin_border_padding_height ();
        }

        Gee.List<string> get_lines_for_width (int width) requires (width > 0) {
            if (cached_lines != null && width == last_width)
                return cached_lines;
            cached_lines = new LinkedList<string> ();
            if (text == null)
                return cached_lines;
            // if everything fits on one line...
            if (font.vala_string_width (text) <= width) {
                cached_lines.add (text);
                return cached_lines;
            }
            // otherwise we have to spilt it into multiple lines
            var builder = new StringBuilder ();
            int i = 0;
            while (i < text.length) {
                while (font.vala_string_width (builder.str) < width) {
                    if (i == text.length)
                        break;
                    builder.append_c (text[i++]);
                }
                if (i < text.length || font.vala_string_width (builder.str) > width) {
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
                cached_lines.add (builder.str);
                builder.truncate ();
            }
            return cached_lines;
        }

        public override void redraw () {
            cached_lines = null;
            base.redraw ();
        }

        protected override void draw_content () {
            if (has_focus || parent.draw_children_as_focused)
                text_option.fg_color = (TextColor)window.screen.bg_color;
            else
                text_option.fg_color = (TextColor)window.screen.fg_color;
            text_option.bg_color = (TextColor)GRX.Color.no_color;
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
            int y = 0;
            switch (text_vertical_align) {
            case TextVertAlign.TOP:
                y = content_bounds.y1;
                break;
            case TextVertAlign.MIDDLE:
                y = content_bounds.y1 + ((int)font.height + 1) / 2;
                break;
            case TextVertAlign.BOTTOM:
                y = content_bounds.y2;
                break;
            }
            var lines = get_lines_for_width (content_bounds.width);
            foreach (var item in lines) {
                draw_vala_string (item, x, y, text_option);
                y += (int)font.height;
            }
        }
    }
}
