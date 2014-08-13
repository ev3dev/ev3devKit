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

/* Label.vala - Widget to display text */

using Gee;
using GRX;

namespace EV3devTk {
    public class Label : EV3devTk.Widget {

        public string? text { get; set; }
        public HorizontalAlign text_horizontal_align {
            get; set; default = HorizontalAlign.CENTER;
        }
        public VerticalAlign text_vertical_align {
            get; set; default = VerticalAlign.MIDDLE;
        }
        public unowned Font font { get; set; default = Font.pc6x8; }
        TextOption text_option;

        Gee.List<string> _lines;
        Gee.List<string> lines {
            owned get {
                if (_lines != null)
                    return _lines;
                _lines = new LinkedList<string> ();
                if (text == null)
                    return _lines;
                if (parent == null) {
                    _lines.add (text);
                    return lines;
                }
                var builder = new StringBuilder ();
                int i = 0;
                while (i < text.length) {
                    while (font.vala_string_width (builder.str) < parent.max_width) {
                        if (i == text.length)
                            break;
                        builder.append_c (text[i++]);
                    }
                    if (i < text.length) {
                        var last_space_index = builder.str.last_index_of (" ");
                        if (last_space_index >= 0) {
                            i -= (int)builder.len;
                            builder.truncate (last_space_index);
                            i += last_space_index + 1;
                        } else {
                            builder.truncate (builder.len - 1);
                            i--;
                        }
                    }
                    _lines.add (builder.str);
                    builder.truncate ();
                }
                return _lines;
            }
        }

        public override int preferred_width {
            get {
                var _width = base.preferred_width;
                if (text != null)
                    _width += font.vala_string_width (text);
                if (parent != null)
                    return int.min (_width, parent.max_width);
                return _width;
            }
        }
        public override int preferred_height {
            get {
                var _height = font.vala_string_height (text) + base.preferred_height;
                return _height * (int)lines.size;
            }
        }

        public Label (string? text = null) {
            _text = text;
            text_option = new TextOption ();
            notify["text"].connect (redraw);
            notify["text_horizontal_align"].connect (redraw);
            notify["text_vertical_align"].connect (redraw);
            notify["font"].connect (redraw);

            notify["text"].connect (() => _lines = null);
            notify["font"].connect (() => _lines = null);
            notify["margin_top"].connect (() => _lines = null);
            notify["margin_bottom"].connect (() => _lines = null);
            notify["margin_left"].connect (() => _lines = null);
            notify["margin_right"].connect (() => _lines = null);
            notify["padding_top"].connect (() => _lines = null);
            notify["padding_bottom"].connect (() => _lines = null);
            notify["padding_left"].connect (() => _lines = null);
            notify["padding_right"].connect (() => _lines = null);
            notify["parent"].connect (() => _lines = null);
        }

        protected override void on_draw (Context context) {
            weak Widget widget = this;
            while (widget.parent != null) {
                if (widget.can_focus)
                    break;
                else
                    widget = widget.parent;
            }
            text_option.font = font;
            text_option.direction = TextDirection.RIGHT;
            if (widget.has_focus)
                text_option.fg_color = (TextColor)window.screen.bg_color;
            else
                text_option.fg_color = (TextColor)window.screen.fg_color;
            text_option.bg_color = (TextColor)GRX.Color.no_color;
            int _x = 0;
            switch (text_horizontal_align) {
            case HorizontalAlign.LEFT:
                _x = x + margin_left + padding_left;
                text_option.x_align = TextHorizAlign.LEFT;
                break;
            case HorizontalAlign.CENTER:
                _x = x + width / 2;
                text_option.x_align = TextHorizAlign.CENTER;
                break;
            case HorizontalAlign.RIGHT:
                _x = x + width - margin_right - padding_right;
                text_option.x_align = TextHorizAlign.RIGHT;
                break;
            }
            int _y = 0;
            switch (text_vertical_align) {
            case VerticalAlign.TOP:
                _y = content_y;
                text_option.y_align = TextVertAlign.TOP;
                break;
            case VerticalAlign.MIDDLE:
                _y = y + height / 2;
                text_option.y_align = TextVertAlign.MIDDLE;
                break;
            case VerticalAlign.BOTTOM:
                _y = y + height - margin_bottom - padding_bottom;
                text_option.y_align = TextVertAlign.BOTTOM;
                break;
            }
            foreach (var item in lines) {
                draw_vala_string (item, _x, _y, text_option);
                _y += font.vala_string_height (item);
            }
        }
    }
}
