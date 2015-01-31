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

/* Grid.vala - Container for laying out widgets in a grid */

using Curses;
using Gee;
using GRX;

namespace EV3devKit.UI {
    /**
     * A container that lays out it children in a grid.
     */
    public class Grid : EV3devKit.UI.Container {
        struct Pair {
            int row;
            int col;
        }

        Pair size;
        Widget?[,] grid;
        Rectangle[,] cells;
        Map<weak Widget,Pair?> position_map;
        Map<weak Widget,Pair?> span_map;

        /**
         * Sets all border widths (top, bottom, left, right, row, column) for the widget.
         */
        public new int border {
            set {
                border_top = value;
                border_bottom = value;
                border_left = value;
                border_right = value;
                border_row = value;
                border_column = value;
            }
        }

        /**
         * Gets and sets the width of the border that is drawn between rows of
         * the Grid.
         */
        public int border_row { get; set; }

        /**
         * Gets and sets the width of the border that is drawn between columns
         * of the Grid.
         */
        public int border_column { get; set; }

        /**
         * Creates a new instance of a grid container.
         *
         * @param rows The number of rows in the grid. Must be > 0.
         * @param columns The number of columns in the grid. Must be > 0.
         */
        public Grid (uint rows, uint columns) requires (rows > 0 && columns > 0) {
            base (ContainerType.MULTIPLE);
            size.row = (int)rows;
            size.col = (int)columns;
            grid = new Widget?[rows,columns];
            position_map = new Gee.HashMap<Widget,Pair?>();
            span_map = new Gee.HashMap<Widget,Pair?>();
            child_added.connect (on_child_added);
            child_removed.connect (on_child_removed);
            notify["border-row"].connect (redraw);
            notify["border-column"].connect (redraw);
        }

        ~Grid () {
            for (int col = 0; col < size.col; col++) {
                for (int row = 0; row < size.row; row++) {
                    grid[row,col] = null;
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            result = 0;
            for (uint row = 0; row < size.row; row++) {
                int row_width = 0;
                for (uint col = 0; col < size.col; col++) {
                    if (grid[row,col] != null) {
                        row_width += grid[row,col].get_preferred_width ();
                        col += span_map[grid[row,col]].col - 1;
                    }
                }
                result = int.max (result, row_width);
            }
            return result + _border_column * (size.col - 1) + get_margin_border_padding_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            result = 0;
            for (uint col = 0; col < size.col; col++) {
                int col_height = 0;
                for (uint row = 0; row < size.row; row++) {
                    if (grid[row,col] != null) {
                        col_height += grid[row,col].get_preferred_height ();
                        row += span_map[grid[row,col]].row - 1;
                    }
                }
                result = int.max (result, col_height);
            }
            return result + _border_row * (size.row - 1) + get_margin_border_padding_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            return get_preferred_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
        requires (width > 0) ensures (result > 0)
        {
            return get_preferred_height ();
        }

        /**
         * Gets the row and column of a widget contained in the Grid.
         *
         * @param child The widget to look for in the grid.
         * @param row The row that contains the child.
         * @param column The column that contains the child.
         * @return true if the child was found.
         */
        public bool get_position_for_child (Widget child, out int row, out int column) {
            if (!(_children.contains (child))) {
                row = -1;
                column = -1;
                return false;
            }
            var position = position_map[child];
            row = position.row;
            column = position.col;
            return true;
        }

        /**
         * Gets the child widget at the specified row and column.
         *
         * @param row The row of the child widget.
         * @param column The column of the child widget.
         * @return The Widget at the specified location or ``null`` if there was
         * nothing at that location.
         */
        public Widget? get_child_at (int row, int column)
            requires (row >= 0 && row < size.row && column >= 0 && column < size.col)
        {
            return grid[row,column];
        }

        /**
         * Add a widget to the specified row and column with optional spans.
         *
         * @param child The widget to add.
         * @param row The row to add the widget to.
         * @param column The column to add the widget to.
         * @param rowspan The number of rows that the widget will span.
         * @param colspan The number of columns that the widget will span.
         */
        public void add_at (Widget child, int row, int column, int rowspan = 1, int colspan = 1)
            requires (row >= 0 && column >=0 && row + rowspan <= size.row
                    && column + colspan <= size.col && rowspan > 0 && colspan > 0)
        {
            for (uint c = column; c < column + colspan; c++) {
                for (uint r = row; r < row + rowspan; r++) {
                    if (grid[r,c] != null)
                        remove (grid[r,c]);
                    grid[r,c] = child;
                }
            }
            add (child);
            position_map[child] = Pair () { row = row, col = column };
            span_map[child] = Pair () { row = rowspan, col = colspan };
        }

        /**
         * If a child was added with Grid.add_at (), then it will already be
         * present in grid[,]. Otherwise we add it to the first empty slot.
         */
        void on_child_added (Widget child) {
            Pair? first_null = null;
            bool found_child = false;
            for (int row = 0; row < size.row; row++) {
                for (int col = 0; col < size.col; col++) {
                    var widget = grid[row,col];
                    if (first_null == null && widget == null)
                        first_null = Pair () { row = row, col = col };
                    if (widget == child) {
                        found_child = true;
                        break;
                    }
                }
                if (found_child)
                    break;
            }
            if (!found_child && first_null != null) {
                grid[first_null.row,first_null.col] = child;
                position_map[child] = Pair () { row = first_null.row, col = first_null.col };
                span_map[child] = Pair () { row = 1, col = 1 };
            }
        }

        void on_child_removed (Widget child) {
            for (uint col = 0; col < size.col; col++) {
                for (uint row = 0; row < size.row; row++) {
                    if (grid[row,col] == child) {
                        grid[row,col] = null;
                        position_map.unset (child);
                        span_map.unset (child);
                    }
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            cells = new Rectangle[size.row,size.col];
            int cell_x = content_bounds.x1;
            int width_remaining = content_bounds.width;
            for (int col = 0; col < size.col; col++) {
                int cell_y = content_bounds.y1;
                int height_remaining = content_bounds.height;
                int columns_remaining = size.col - col;
                int cell_width = (width_remaining - (columns_remaining - 1) * border_column) / columns_remaining;
                for (int row = 0; row < size.row; row++) {
                    int rows_remaining = size.row - row;
                    int cell_height = (height_remaining - (rows_remaining - 1) * border_row) / rows_remaining;
                    cells[row,col].x1 = cell_x;
                    cells[row,col].y1 = cell_y;
                    cells[row,col].x2 = cell_x + cell_width - 1;
                    cells[row,col].y2 = cell_y + cell_height -1;
                    cell_y += cell_height + border_row;
                    height_remaining -= cell_height + border_row;
                }
                cell_x += cell_width + border_column;
                width_remaining -= cell_width + border_column;
            }
            for (int row = 0; row < size.row; row++) {
                for (int col = 0; col < size.col; col++) {
                    var widget = grid[row,col];
                    if (widget != null) {
                        int colspan = span_map[widget].col - 1;
                        // just storing the x values for retrieval in the next for loop
                        widget.set_bounds (cells[row,col].x1, 0, cells[row,col+colspan].x2, 0);
                        col += colspan;
                    }
                }
            }
            for (int col = 0; col < size.col; col++) {
                for (int row = 0; row < size.row; row++) {
                    var widget = grid[row,col];
                    if (widget != null) {
                        int rowspan = span_map[widget].row - 1;
                        set_child_bounds (widget, widget.bounds.x1, cells[row,col].y1,
                            widget.bounds.x2, cells[row+rowspan,col].y2);
                        row += rowspan;
                    }
                }
            }
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_border (GRX.Color color) {
            base.draw_border (color);
            // draw the vertical grid lines between each column
            if (border_column > 0) {
                for (int row = 0; row < size.row; row++) {
                    for (int col = 0; col < size.col - 1; col++) {
                        var widget = grid[row,col];
                        Rectangle cell;
                        if (widget != null) {
                            int colspan = span_map[widget].col - 1;
                            if (col + colspan >= size.col - 1)
                                continue;
                            cell = cells[row,col+colspan];
                            col += colspan;
                        } else {
                            cell = cells[row,col];
                        }
                        filled_box (cell.x2 + 1, cell.y1, cell.x2 + border_column, cell.y2 + border_row, color);
                    }
                }
            }
            // draw the horizontal grid lines between each row
            if (border_row > 0) {
                for (int col = 0; col < size.col; col++) {
                    for (int row = 0; row < size.row - 1; row++) {
                        var widget = grid[row,col];
                        Rectangle cell;
                        if (widget != null) {
                            int rowspan = span_map[widget].row - 1;
                            if (row + rowspan >= size.row - 1)
                                continue;
                            cell = cells[row+rowspan,col];
                            row += rowspan;
                        } else {
                            cell = cells[row,col];
                        }
                        filled_box (cell.x1, cell.y2 + 1, cell.x2 + border_column, cell.y2 + border_row, color);
                    }
                }
            }
        }
    }
}