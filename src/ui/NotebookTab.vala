/*
 * EV3devKit.UI - ev3dev toolkit for LEGO MINDSTORMS EV3
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

/* NotebookTab.vala - Container for a tab of a Notebook */

using Curses;
using Gee;
using GRX;

namespace EV3devKit.UI {
    /**
     * Container for a single tab of a {@link Notebook}.
     */
    public class NotebookTab : EV3devKit.UI.Container {
        internal weak Notebook? notebook;

        /**
         * Gets and sets the title displayed on the tab.
         */
        public string title { get; set; }

        /**
         * Creates a new notebook tab.
         */
        public NotebookTab (string title) {
            base (ContainerType.SINGLE);
            this.title = title;
            notify["title"].connect (redraw);
        }
    }
}
