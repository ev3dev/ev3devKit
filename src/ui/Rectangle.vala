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

/* Rectangle.vala - Struct for rectangles */

namespace Ev3devKit.Ui {
    /**
     * The bounds of a rectangle.
     */
    public struct Rectangle {
        /**
         * The leftmost x-axis value.
         */
        public int x1;

        /**
         * The topmost y-axis value.
         */
        public int y1;

        /**
         * The rightmost x-axis value.
         */
        public int x2;

        /**
         * The bottommost y-axis value.
         */
        public int y2;

        /**
         * Gets the width of the rectangle.
         */
        public int width { get { return x2 - x1 + 1; } }

        /**
         * Gets the height of the rectangle.
         */
        public int height { get { return y2 - y1 + 1; } }
    }
}