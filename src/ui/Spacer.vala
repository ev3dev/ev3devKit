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

/* Spacer.vala - Widget to take up space */

using GRX;

namespace EV3devKit.UI {
    /**
     * An empty widget that is used to distribute left over space in a container.
     *
     * For example, if a Spacer is added to a vertical Box between two other
     * widgets, the first will be positioned at the top of the box and the second
     * at the bottom of the box. The Spacer will take up the remaining space
     * between them.
     */
    public class Spacer : EV3devKit.UI.Widget {
        /**
         * Create a new spacer.
         */
        public Spacer () {
        }
    }
}
