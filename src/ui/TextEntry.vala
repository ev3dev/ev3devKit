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

/* TextEntry.vala - Widget for getting text from user */

using Curses;
using Grx;

namespace Ev3devKit.Ui {
    /**
     * A wiget for getting user input.
     */
    public class TextEntry : Ev3devKit.Ui.Widget {
        const string CONTINUE_RIGHT = "\xaf";
        const string CONTINUE_LEFT = "\xae";

        /**
         * String containing all numeric characters (``0-9``).
         */
        public const string NUMERIC = "0123456789";

        /**
         * String containing numeric characters (``0-9``) and a decimal point (``.``).
         */
        public const string DECIMAL = NUMERIC + ".";

        /**
         * String containing hexadecimal numeric characters (``0-9`` and ``A-F``).
         */
        public const string HEXIDECIMAL = NUMERIC + "ABCDEF";

        /**
         * String containing uppercase alphabetic characters (``A-Z``).
         */
        public const string UPPER_ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        /**
         * String containing lowercase alphabetic characters (``a-z``).
         */
        public const string LOWER_ALPHA = "abcdefghijklmnopqrstuvwxyz";

        /**
         * String containing all alphabetic characters (``a-z`` and ``A-Z``).
         */
        public const string ALPHA = LOWER_ALPHA + UPPER_ALPHA;

        /**
         * String containing alphanumeric characters (``a-z``, ``A-Z``, ``0-9`` and ``.-_<space>``).
         */
        public const string ALPHA_NUM = ALPHA + DECIMAL + "-_ ";

        /**
         * String containing symbol characters (``!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~``).
         */
        public const string SYMBOL = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";

        /**
         * String containing all 95 printable ASCII characters.
         */
        public const string ALPHA_NUM_SYMBOL = ALPHA + NUMERIC + SYMBOL + " ";

        Label label;
        int text_offset; // chars
        internal int cursor_offset; // chars
        int cursor_x; // pixels
        bool should_inc_text_offset_with_cursor;
        string save_text;
        OnScreenKeyboard on_screen_keyboard;

        /**
         * Gets and sets the test displayed in the text entry.
         */
        public string text { get; set; }

        /**
         * Gets and sets the font used in the text entry.
         */
        public unowned Font font {
            get {return label.font; }
            set { label.font = value; }
        }

        /**
         * Gets and sets the minimum width for the text entry.
         */
        public int min_width { get; set; default = 10; }

        /**
         * Gets and sets the edit-ability of the text entry.
         */
        public bool can_edit { get; set; default = true; }

        /**
         * Gets and sets whether the text entry should use an on screen keyboard.
         */
        public bool use_on_screen_keyboard { get; set; default = true; }

        /**
         * Gets the current editing state.
         */
        public bool editing { get; internal set; default = false; }

        /**
         * Gets and sets a string containing valid characters for the text entry.
         *
         * This limits the number of characters that have to be scrolled when
         * not using the on screen keyboard.
         */
        public string valid_chars { get; set; default = ALPHA_NUM_SYMBOL; }

        /**
         * Gets and sets whether the text entry inserts or replaces text.
         */
        public bool insert { get; set; default = false; }

        construct {
            label = new Label () {
                text_horizontal_align = TextHorizAlign.LEFT,
                text_vertical_align = TextVertAlign.TOP,
                font = Font.pc6x8
            };
            can_focus = true;
            border = 1;
            padding = 2;
            notify["text"].connect (redraw);
            notify["min-width"].connect (redraw);
            notify["editing"].connect (redraw);
            notify["parent"].connect (() => label.parent = this.parent);
        }

        /**
         * Creates a new text entry.
         *
         * @param text The initial text.
         */
        public TextEntry (string text = "") {
            this.text = text;
        }

        /**
         * Starts an editing session.
         *
         * If the text entry uses an on screen keyboard, it will be displayed.
         * Otherwise, a cursor will be displayed. The left and right arrow keys
         * move the cursor and the up and down arrow keys change the character
         * above the cursor using the list of {@link valid_chars}. Either
         * {@link commit_editing} or {@link cancel_editing} must be called to
         * end the editing session.
         */
        public void start_editing () {
            if (_editing)
                return;
            save_text = text;
            editing = true;
            if (_use_on_screen_keyboard) {
                on_screen_keyboard = new OnScreenKeyboard ();
                on_screen_keyboard.text = text;
                on_screen_keyboard.accepted.connect (commit_editing);
                on_screen_keyboard.canceled.connect (cancel_editing);
                on_screen_keyboard.show ();
            }
        }

        /**
         * Commits the changes made in an editing session.
         *
         * An editing session is started by calling {@link start_editing}.
         */
        public void commit_editing () {
            if (!_editing)
                return;
            editing = false;
            if (_use_on_screen_keyboard) {
                text = on_screen_keyboard.text;
                on_screen_keyboard = null;
            }
        }

        /**
         * Cancels the changes made in an editing session.
         *
         * An editing session is started by calling {@link start_editing}.
         * {@link text} will be reverted to the value saved when
         * {@link start_editing} was called.
         */
        public void cancel_editing () {
            if (!_editing)
                return;
            editing = false;
            text = save_text;
            if (_use_on_screen_keyboard)
                on_screen_keyboard = null;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () {
            return int.max (min_width, font.vala_string_width (text ?? "")
                + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () {
            return label.get_preferred_height () + get_margin_border_padding_height ();
        }

        /**
         * Sets the character at the current cursor position.
         *
         * @param c The new character.
         * @param move_next If true, the cursor will be moved to the next character.
         */
        public void set_char (char c, bool move_next = false) {
            if (!_editing)
                return;
            if (!(c.to_string() in valid_chars))
                return;
            var builder = new StringBuilder (text);
            if (_insert)
                builder.insert (cursor_offset, c.to_string ());
            else
                builder.overwrite (cursor_offset, c.to_string ());
            text = builder.str;
            if (move_next)
                cursor_offset++;
            redraw ();
        }

        /**
         * Removes the character at the current cursor position.
         *
         * @param backspace If true deletes the character before the cursor instead.
         */
        public void delete_char (bool backspace = false) {
            if (!_editing)
                return;
            if (text.length == 0 || (backspace && cursor_offset == 0)
                    || (!backspace && cursor_offset == text.length - 1))
                return;
            var offset = cursor_offset - (backspace ? 1 : 0);
            var builder = new StringBuilder (text);
            builder.erase (offset, 1);
            text = builder.str;
            cursor_offset = offset;
            redraw ();
        }

        /**
         * Increments or decrements the character at the current cursor position.
         *
         * Uses {@link valid_chars} to determine the next character.
         *
         * @param dec If true, decrements instead of increments.
         */
        void inc_char (bool dec = false) {
            var new_char = text.get (cursor_offset);
            var next_index = _valid_chars.index_of_char (new_char) + (dec ? -1 : 1);
            // wraparound
            next_index = (_valid_chars.length + next_index) % _valid_chars.length;
            new_char = _valid_chars.get (next_index);
            set_char (new_char);
        }

        /**
         * Default handler for the key_pressed signal.
         */
        internal override bool key_pressed (uint key_code) {
            if (_editing) {
                if (key_code == Key.UP)
                    inc_char ();
                else if (key_code == Key.DOWN)
                    inc_char (true);
                else if (key_code == Key.RIGHT) {
                    cursor_offset ++;
                    if (should_inc_text_offset_with_cursor)
                        text_offset++;
                } else if (key_code == Key.LEFT)
                    cursor_offset--;
                else if (key_code == '\n')
                    commit_editing ();
                else if (key_code == Key.BACKSPACE)
                    cancel_editing ();
                else if (key_code >= 32 && key_code < 127)
                    set_char ((char)key_code, true);
                else
                    return false;
                redraw ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            } else {
                if (key_code == Key.RIGHT)
                    text_offset ++;
                else if (key_code == Key.LEFT)
                    text_offset--;
                else if (_can_edit && key_code == '\n')
                    start_editing ();
                else
                    return base.key_pressed (key_code);
                redraw ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
        }

        void set_label_text () {
            var builder = new StringBuilder ();
            var continuation_offset = 0;
            should_inc_text_offset_with_cursor = false;

            // don't need to do fancy calculations if we are not out of bounds.
            if (font.vala_string_width (text ?? "") <= content_bounds.width) {
                label.text = text;
                text_offset = 0;
            } else {
                // FIXME: draw elipsis (...) or arrows instead of using text for contrinue left/right
                if (!editing && text_offset > CONTINUE_LEFT.length)
                    cursor_offset = text_offset;
                if (editing && cursor_offset < text_offset)
                    text_offset = cursor_offset;
                text_offset = int.max (CONTINUE_LEFT.length, text_offset);
                builder.append (CONTINUE_LEFT);
                var max_text_offset = text.length - 1;
                while (max_text_offset > 0
                    && font.vala_string_width (builder.str) < content_bounds.width)
                    builder.append_c (text[max_text_offset--]);
                max_text_offset += CONTINUE_LEFT.length + 1;
                text_offset = int.min (text_offset, max_text_offset);
                var cursor_out_of_range = true;
                while (cursor_out_of_range) {
                    cursor_out_of_range = false;
                    builder.erase ();
                    if (text_offset > CONTINUE_LEFT.length)
                        builder.append (CONTINUE_LEFT);
                    else
                        builder.append (text[0:CONTINUE_LEFT.length]);
                    continuation_offset = CONTINUE_LEFT.length;
                    var index = text_offset;
                    while (index < text.length
                            && font.vala_string_width (builder.str) < content_bounds.width)
                        builder.append_c (text[index++]);
                    if (index < text.length
                        || font.vala_string_width (builder.str) > content_bounds.width)
                    {
                        while (index > 0
                            && font.vala_string_width (builder.str + CONTINUE_RIGHT)
                                > content_bounds.width)
                        {
                            builder.truncate (builder.len - 1);
                        }
                        if (cursor_offset - text_offset > builder.len - 2) {
                            text_offset++;
                            cursor_out_of_range = true;
                            continue;
                        } else if (cursor_offset - text_offset == builder.len - 2)
                            should_inc_text_offset_with_cursor = true;
                        builder.append (CONTINUE_RIGHT);
                    }
                }
                label.text = builder.str;
            }
            cursor_offset = int.max (0, cursor_offset);
            cursor_offset = int.min (cursor_offset, text.length - 1);
            cursor_x = content_bounds.x1;
            if (text.length > 0)
                cursor_x += font.vala_string_width (
                    label.text[0:continuation_offset + cursor_offset - text_offset]);
        }

        /**
         * {@inheritDoc}
         */
        protected override void redraw () {
            label.text = null;
            base.redraw ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            label.set_bounds (content_bounds.x1, content_bounds.y1,
                content_bounds.x2, content_bounds.y2);
            if (text != null && label.text == null)
                set_label_text ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            var color = has_focus ? window.screen.mid_color : window.screen.fg_color;
            label.draw ();
            if (editing) {
                horiz_line (cursor_x,
                    cursor_x + font.char_width (label.text[cursor_offset]),
                    content_bounds.y2 + 1, color);
            }
            if (has_focus && !editing) {
                box (border_bounds.x1 + 1, border_bounds.y1 + 1,
                    border_bounds.x2 - 1, border_bounds.y2 -1, color);
            }
        }
    }
}