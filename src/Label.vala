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
using U8g;

namespace EV3devTk {
    public class Label : EV3devTk.Widget {

        public string? text { get; set; }
        public HorizontalAlign text_horizontal_align {
            get; set; default = HorizontalAlign.CENTER;
        }
        public VerticalAlign text_vertical_align {
            get; set; default = VerticalAlign.MIDDLE;
        }
        public unowned Font font { get; set; default = Font.x11_7x13; }

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
                fake_u8g.font = font;
                while (i < text.length) {
                    while (fake_u8g.get_string_width (builder.str)
                        < parent.max_width)
                    {
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

        public override ushort preferred_width {
            get {
                fake_u8g.font = font;
                var _width = base.preferred_width;
                if (text != null)
                    _width += fake_u8g.get_string_width (text);
                if (parent != null)
                    return ushort.min (_width, parent.max_width);
                return _width;
            }
        }
        public override ushort preferred_height {
            get {
                fake_u8g.font = font;
                var _height = fake_u8g.font_ascent
                    - fake_u8g.font_descent + base.preferred_height;
                return _height * (ushort)lines.size;
            }
        }

        public Label (string? text = null) {
            _text = text;
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

        protected override void on_draw (Graphics u8g) {
            weak Widget widget = this;
            while (widget.parent != null) {
                if (widget.can_focus)
                    break;
                else
                    widget = widget.parent;
            }
            if (widget.has_focus)
                u8g.set_default_background_color ();
            else
                u8g.set_default_foreground_color ();
            u8g.font = font;
            u8g.font_reference_height = FontReferenceHeight.EXTENDED_TEXT;
            ushort _x = 0;
            switch (text_horizontal_align) {
            case HorizontalAlign.LEFT:
                _x = x + margin_left + padding_left;
                break;
            case HorizontalAlign.CENTER:
                /* _x is calculated in each loop of the text lines */
                break;
            case HorizontalAlign.RIGHT:
                _x = x + width - margin_right - padding_right
                    - ((text == null) ? 0 : u8g.get_string_width (text));
                break;
            }
            ushort _y = 0;
            switch (text_vertical_align) {
            case VerticalAlign.TOP:
                _y = content_y;
                u8g.font_position = FontPosition.TOP;
                break;
            case VerticalAlign.MIDDLE:
                _y = y + (height - (u8g.font_ascent - u8g.font_descent)
                    * (ushort)(lines.size - 1)) / 2;
                u8g.font_position = FontPosition.CENTER;
                break;
            case VerticalAlign.BOTTOM:
                _y = y + height - margin_bottom - padding_bottom;
                u8g.font_position = FontPosition.BOTTOM;
                break;
            }
            foreach (var item in lines) {
                if (text_horizontal_align == HorizontalAlign.CENTER)
                    _x = x + (width - u8g.get_string_width (item)) / 2;
                u8g.draw_string (_x, _y, item);
                _y += u8g.font_ascent - u8g.font_descent;
            }
        }
    }
}
