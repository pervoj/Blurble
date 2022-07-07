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

public enum WG.CellState {
    CORRECT,
    WRONG,
    WRONG_POSITION,
    UNKNOWN,
    NONE
}

public class WG.Grid : Gtk.Grid {
    private Gtk.Label[] cells = new Gtk.Label[5*6];
    private int active = 0;

    public Grid () {
        style ();
        fill ();
    }
    
    public void active_dimensions (out int x, out int y) {
        int width;
        int height;
        query_child (cells[active], out x, out y, out width, out height);
    }
    
    public int active_row () {
        int x;
        int y;
        active_dimensions (out x, out y);
        return y;
    }

    public int active_column () {
        int x;
        int y;
        active_dimensions (out x, out y);
        return x;
    }

    public Gtk.Label cell (int x, int y) {
        return (Gtk.Label) get_child_at (x, y);
    }

    public Gtk.Label active_cell () {
        return cells[active];
    }

    public void set_cell_state (int x, int y, CellState state) {
        Gtk.Label cell = this.cell (x, y);
        cell.remove_css_class ("correct");
        cell.remove_css_class ("wrong");
        cell.remove_css_class ("position");
        cell.remove_css_class ("unknown");
        switch (state) {
            case CellState.CORRECT:
                cell.add_css_class ("correct");
                break;
            case CellState.WRONG:
                cell.add_css_class ("wrong");
                break;
            case CellState.WRONG_POSITION:
                cell.add_css_class ("position");
                break;
            case CellState.UNKNOWN:
                cell.add_css_class ("unknown");
                break;
            case CellState.NONE:
                break;
        }
    }

    public CellState get_cell_state (int x, int y) {
        Gtk.Label cell = this.cell (x, y);
        if (cell.has_css_class ("correct")) return CellState.CORRECT;
        else if (cell.has_css_class ("wrong")) return CellState.WRONG;
        else if (cell.has_css_class ("position")) return CellState.WRONG_POSITION;
        else if (cell.has_css_class ("unknown")) return CellState.UNKNOWN;
        return CellState.NONE;
    }

    public void backspace (int count = 1) {
        if (active == 0) return;
        active--;
        cells[active].label = "";
    }
    
    public void insert (string text) {
        if (active == 5*6) return;
        cells[active].label = text;
        active++;
    }
    
    private void fill () {
        for (int i = 0; i < 5*6; i++) {
            int x = i % 5;
            int y = i / 5;
            Gtk.Label cell = new Gtk.Label ("");
            cells[i] = cell;
            attach (cell, x, y);
            cell.add_css_class ("cell");
        }
    }

    private void style () {
        column_homogeneous = true;
        row_homogeneous = true;
        column_spacing = 6;
        row_spacing = 6;
        margin_top = 10;
        margin_bottom = 10;
        margin_start = 10;
        margin_end = 10;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
    }
}
