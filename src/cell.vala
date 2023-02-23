/* cell.vala
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

public class WG.Cell : Adw.Bin {
    public string content { get; set; default = ""; }
    public CellState state { get; set; default = CellState.NONE; }
    public bool focused { get; set; default = false; }

    construct {
        add_css_class ("cell");

        var label = new Gtk.Label (content);
        this.child = label;
        bind_property ("content", label, "label", BindingFlags.DEFAULT);

        notify["state"].connect (update_styles);
        notify["focused"].connect (update_styles);
        update_styles ();
    }

    private void update_styles () {
        remove_css_class ("focused");
        remove_css_class ("correct");
        remove_css_class ("wrong");
        remove_css_class ("position");
        remove_css_class ("unknown");

        if (focused) add_css_class ("focused");

        switch (state) {
            case CellState.CORRECT:
                add_css_class ("correct");
                break;
            case CellState.WRONG:
                add_css_class ("wrong");
                break;
            case CellState.WRONG_POSITION:
                add_css_class ("position");
                break;
            case CellState.UNKNOWN:
                add_css_class ("unknown");
                break;
            case CellState.NONE:
                break;
        }
    }
}
