/* key.vala
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

public class WG.Key : Adw.Bin {
    public string display_val { get; construct; }
    public string val { get; construct; }
    public int size { get; construct; }

    public CellState state { get; set; default = CellState.NONE; }

    public signal void clicked (string val);

    private Gtk.Button button;
    private int spacing;

    public Key (
        string display_val, string? val = null, int size = 1, int spacing = 0
    ) {
        string _display_val = display_val.strip ();

        string _val = val == null ? _display_val : val.strip ();
        if (_val == "") _val = _display_val;

        int _size = size < 1 ? 1 : size;

        Object (display_val: _display_val, val: _val, size: _size);
        this.spacing = spacing >= 0 ? spacing : 0;
    }

    construct {
        button = new Gtk.Button ();
        this.child = button;
        button.add_css_class ("key");
        button.can_focus = false;

        switch (display_val) {
            case "enter":
                button.icon_name = "keyboard-enter-symbolic";
                button.add_css_class ("suggested-action");
                break;
            case "backspace":
                button.icon_name = "entry-clear-symbolic";
                button.add_css_class ("destructive-action");
                break;
            default:
                button.label = display_val.up ();
                break;
        }

        // (size * prev_size) - the new size is size-times the previous size
        // ((size - 1) * spacing) - include the box spacing into the size
        int prev_size = button.width_request;
        button.width_request = (size * prev_size) + ((size - 1) * spacing);

        button.clicked.connect (() => { clicked (val); });

        notify["state"].connect (update_styles);
        update_styles ();
    }

    private void update_styles () {
        button.remove_css_class ("correct");
        button.remove_css_class ("wrong");
        button.remove_css_class ("position");

        switch (state) {
            case CellState.CORRECT:
                button.add_css_class ("correct");
                break;
            case CellState.WRONG:
                button.add_css_class ("wrong");
                break;
            case CellState.WRONG_POSITION:
                button.add_css_class ("position");
                break;
            case CellState.UNKNOWN:
            case CellState.NONE:
                break;
        }
    }
}
