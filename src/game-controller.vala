/* window.vala
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

public class WG.GameController : Object {
    public string[] correct_word = {"p", "o", "n", "o", "r"};
    public string[,] dictionary = {
        {"p", "o", "n", "o", "r"},
        {"s", "l", "a", "m", "a"},
        {"r", "a", "d", "l", "o"},
        {"f", "a", "k", "i", "r"},
        {"a", "m", "a", "n", "t"}
    };

    public Grid grid { get; construct; }
    public Gtk.EventControllerKey event { get; construct; }

    public signal void game_over (bool win);

    public GameController () {
        Object (
            grid: new Grid (),
            event: new Gtk.EventControllerKey ()
        );
        event.key_pressed.connect (key_pressed);
    }

    private bool word_exist () {
        string[] word = grid.get_row ();
        for (int y = 0; y < dictionary.length[0]; y++) {
            bool equal = true;
            for (int x = 0; x < dictionary.length[1]; x++) {
                if (dictionary[y, x] != word[x]) equal = false;
            }
            if (equal) return true;
        }
        return false;
    }

    private bool check_word () {
        string[] written_word = grid.get_row ();
        int y = grid.active_row ();

        bool exist = word_exist ();

        bool correct = exist;
        for (int x = 0; x < 5; x++) {
            string correct_cell = correct_word[x];
            string written_cell = written_word[x];

            if (!exist) {
                grid.set_cell_state (x, y, CellState.UNKNOWN);
                continue;
            }

            if (written_cell == correct_cell) {
                grid.set_cell_state (x, y, CellState.CORRECT);
                continue;
            }

            correct = false;

            if (written_cell in correct_word) {
                grid.set_cell_state (x, y, CellState.WRONG_POSITION);
                continue;
            }

            grid.set_cell_state (x, y, CellState.WRONG);
        }

        return correct;
    }

    private bool key_pressed (uint val, uint code, Gdk.ModifierType state) {
        if (val == 65288 || val == 65535) {
            grid.reset_row_state ();
            grid.backspace ();
            return true;
        }

        if (val == 65293) {
            if (!grid.row_filled ()) return true;

            if (check_word ()) {
                game_over (true);
                return true;
            }

            if (word_exist ()) {
                if (grid.active_row () < 5) {
                    grid.next_row ();
                } else {
                    game_over (false);
                }
            }

            return true;
        }

        string key = ((char) val).to_string ();
        if (!(key.down () in "abcdefghijklmnopqrstuvwxyz")) return false;
        grid.reset_row_state ();
        grid.insert (key.up ());
        return true;
    }
}
