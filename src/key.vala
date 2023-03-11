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
    private const int PREV_SIZE = 30;

    public string display_val { get; construct; }
    public string val { get; construct; }
    public double size { get; construct; }
    public int spacing { get; construct; }

    public CellState state { get; set; default = CellState.NONE; }

    public signal void clicked (string val);

    private Gtk.Button button;

    public Key (
        string display_val, string? val = null, double size = 1, int spacing = 0
    ) {
        string _display_val = display_val.strip ();

        string _val = val == null ? _display_val : val.strip ();
        if (_val == "") _val = _display_val;

        Object (
            display_val: _display_val,
            val: _val,
            size: size < 1 ? 1 : size,
            spacing: spacing < 0 ? 0 : spacing
        );
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
                button.tooltip_text = _("Enter");
                break;
            case "backspace":
                button.icon_name = "entry-clear-symbolic";
                button.add_css_class ("destructive-action");
                button.tooltip_text = _("Erase");
                break;
            default:
                button.label = display_val.up ();
                break;
        }

        double new_size = size * PREV_SIZE;
        new_size = new_size + ((Math.ceil (size) - 1) * spacing);
        new_size = new_size - ((size - Math.floor (size)) * spacing);

        button.width_request = (int) Math.round (new_size);

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

