/* grid.vala
 *
 * Copyright 2022 Vojtěch Perník
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class WG.Grid : Adw.Bin {
    private int active_x = 0;
    private int active_y = 0;

    private Gtk.Grid grid = new Gtk.Grid ();

    construct {
        this.focusable = true;
        this.can_focus = true;

        add_css_class ("letter-grid");

        margin_top = 10;
        margin_bottom = 10;
        margin_start = 10;
        margin_end = 10;
        halign = Gtk.Align.CENTER;
        hexpand = true;
        valign = Gtk.Align.CENTER;
        vexpand = true;

        this.child = grid;
        grid.column_homogeneous = true;
        grid.row_homogeneous = true;
        grid.column_spacing = 6;
        grid.row_spacing = 6;

        fill ();
    }

    public void active_dimensions (out int x, out int y) {
        x = active_x;
        y = active_y;
    }
    
    public int active_row () {
        return active_y;
    }

    public int active_column () {
        return active_x;
    }

    public Cell cell (int x, int y) {
        return (Cell) grid.get_child_at (x, y);
    }

    public Cell active_cell () {
        return cell (active_x, active_y);
    }

    public string[] get_row () {
        string[] row = {};
        for (int x = 0; x < 5; x++) {
            row += cell (x, active_y).content.down ();
        }
        return row;
    }

    public bool row_filled () {
        foreach (string cell in get_row ()) {
            if (cell.length == 0) return false;
        }
        return true;
    }

    public void reset_row_state () {
        for (int x = 0; x < 5; x++) {
            set_cell_state (x, active_y, CellState.NONE);
        }
    }

    public void set_cell_state (int x, int y, CellState state) {
        cell (x, y).state = state;
    }

    public CellState get_cell_state (int x, int y) {
        return cell (x, y).state;
    }

    public void backspace () {
        if (active_x == 0) return;
        Cell cell;
        if (active_x < 5) {
            cell = active_cell ();
            cell.focused = false;
        }

        active_x--;
        cell = active_cell ();
        cell.content = "";
        cell.focused = true;
    }
    
    public void insert (string text) {
        if (active_x == 5) return;
        var cell = active_cell ();
        cell.content = text;
        cell.focused = false;

        active_x++;
        if (active_x < 5) {
            cell = active_cell ();
            cell.focused = true;
        }
    }

    public void next_row () {
        if (active_y == 5) return;
        var cell = active_cell ();
        cell.focused = false;

        active_x = 0;
        active_y++;
        cell = active_cell ();
        cell.focused = true;
    }
    
    private void fill () {
        for (int y = 0; y < 6; y++) {
            for (int x = 0; x < 5; x++) {
                grid.attach (new Cell (), x, y);
            }
        }

        active_cell ().focused = true;
    }
}
