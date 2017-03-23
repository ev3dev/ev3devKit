/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
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

/* Fonts.vala - Namespace to manage fonts */

using Grx;

/**
 * Namespace for getting common fonts.
 */
namespace Ev3devKit.Ui.Fonts {
    Font default_font;
    Font small_font;
    Font big_font;

    /**
     * Gets the default font.
     */
    public unowned Font get_default () {
        if (default_font == null) {
            try {
                default_font = Font.load ("fixed sans", 8);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }
        return default_font;
    }

    /**
     * Gets the small font.
     */
    public unowned Font get_small () {
        if (small_font == null) {
            try {
                small_font = Font.load ("fixed sans", 6);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }
        return small_font;
    }

    /**
     * Gets the big font.
     */
    public unowned Font get_big () {
        if (big_font == null) {
            try {
                big_font = Font.load ("fixed sans", 10);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }
        return big_font;
    }
}
