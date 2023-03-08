/* keyboard.vala
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

public class WG.Keyboard : Gtk.Box {
    private const int MARGIN = 6;
    private const int SPACING = 4;

    public signal void insert (string cell);
    public signal void backspace ();
    public signal void enter ();
    public bool game_over { get; set; default = false; }

    private HashTable<string, Key> keys;

    public Keyboard () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: SPACING
        );
    }

    construct {
        keys = new HashTable<string, Key> (str_hash, str_equal);
        halign = Gtk.Align.CENTER;
        hexpand = true;
        valign = Gtk.Align.CENTER;
        vexpand = true;
        margin_top = 6;
        margin_bottom = 6;
        margin_start = 6;
        margin_end = 6;

        foreach (string line in Data.get_keyboard ().split (";")) {
            Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, SPACING);
            append (box);
            box.halign = Gtk.Align.CENTER;
            box.hexpand = true;

            foreach (string _key_str in line.split (",")) {
                string _key = _key_str.strip ();
                _key = _key.replace ("{", "").replace ("}", "");
                var parts = _key.split ("/");

                if (parts.length <= 0) continue;

                string? display_val = null;
                string? val = null;
                double? size = null;

                foreach (string _part in parts) {
                    if (display_val != null && val != null && size != null) {
                        break;
                    }
                    string part = _part.strip ();
                    if (part.length == 0) continue;

                    if (display_val == null) {
                        display_val = part;
                        continue;
                    }

                    double _parsed = -1;
                    if (size == null && double.try_parse (part, out _parsed)) {
                        size = _parsed < 1 ? 1 : _parsed;
                        continue;
                    }

                    if (val == null) {
                        val = part;
                    }
                }

                if (display_val == null) continue;
                if (size == null) size = 1;

                var key = new Key (display_val, val, size, SPACING);
                if (keys.contains (key.val)) continue;
                keys.set (key.val, key);
                box.append (key);
                key.clicked.connect (clicked);
            }
        }

        notify["game-over"].connect (() => {
            this.sensitive = !game_over;
        });
    }

    public void set_key_state (string val, CellState state) {
        if (!keys.contains (val)) return;
        keys.get (val).state = state;
    }

    private void clicked (string val) {
        switch (val) {
            case "enter":
                enter ();
                break;
            case "backspace":
                backspace ();
                break;
            default:
                insert (val);
                break;
        }
    }
}
