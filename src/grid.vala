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
    private int active_x = 0;
    private int active_y = 0;

    public Grid () {
        style ();
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

    public Gtk.Label cell (int x, int y) {
        return (Gtk.Label) get_child_at (x, y);
    }

    public Gtk.Label active_cell () {
        return cell (active_x, active_y);
    }

    public string get_row () {
        string row = "";
        for (int x = 0; x < 5; x++) {
            row += cell (x, active_y).label;
        }
        return row.down ();
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

    public void backspace () {
        if (active_x == 0) return;
        active_x--;
        active_cell ().label = "";
    }
    
    public void insert (string text) {
        if (active_x == 5) return;
        active_cell ().label = text;
        active_x++;
    }

    public void next_row () {
        if (active_y == 5) return;
        active_x = 0;
        active_y++;
    }
    
    private void fill () {
        for (int y = 0; y < 6; y++) {
            for (int x = 0; x < 5; x++) {
                Gtk.Label cell = new Gtk.Label ("");
                attach (cell, x, y);
                cell.add_css_class ("cell");
            }
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
        hexpand = true;
        valign = Gtk.Align.CENTER;
        vexpand = true;
    }
}
