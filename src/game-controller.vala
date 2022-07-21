/* game-controller.vala
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
    public string[] correct_word;
    public List<string> dictionary = DataParser.dictionary ();

    public Grid grid { get; construct; }
    public Gtk.EventControllerKey event { get; construct; }

    public signal void game_over (bool win);

    public GameController () {
        Object (
            grid: new Grid (),
            event: new Gtk.EventControllerKey ()
        );

        int32 word = Random.int_range (0, (int32) dictionary.length ());
        correct_word = DataParser.replace (dictionary.nth_data ((uint) word)).split ("/");

        debug (_("Current word: %s\n"), dictionary.nth_data ((uint) word).replace ("/", ""));

        event.key_pressed.connect (key_pressed);
    }

    private bool word_exist () {
        string word = string.joinv ("/", grid.get_row ());
        bool found = false;
        dictionary.foreach ((current_word) => {
            if (found) return;
            if (word == DataParser.replace (current_word)) found = true;
        });
        return found;
    }

    private bool check_word () {
        string?[] written_word = grid.get_row ();

        int y = grid.active_row ();

        bool correct = true;

        if (!word_exist ()) {
            for (int x = 0; x < 5; x++) {
                grid.set_cell_state (x, y, CellState.UNKNOWN);
            }
            return false;
        }

        // make a copy to keep the unmatched letters, (with CellState.WRONG)
        string?[] remaining_word = correct_word.copy ();

        // find exact matches
        for (int x = 0; x < 5; x++) {
            string correct_cell = correct_word[x];
            string written_cell = written_word[x];

            if (written_cell == correct_cell) {
                grid.set_cell_state (x, y, CellState.CORRECT);
                // match found, remove it from the remaining array
                remaining_word[x] = null;
                written_word[x] = null;
            } else {
                grid.set_cell_state (x, y, CellState.WRONG);
                correct = false;
            }
        }

        for (int wx = 0; wx < 5; wx++) { // for each letter guessed
            if (written_word[wx] == null) continue;

            for (int rx = 0; rx < 5; rx++) { // find the first matching remaining letter
                if (written_word[wx] == remaining_word[rx]) {
                    grid.set_cell_state (wx, y, CellState.WRONG_POSITION);
                    // match found, remove it
                    remaining_word[rx] = null;
                    break;
                }
            }
        }

        return correct;
    }

    private bool key_pressed (uint val, uint code, Gdk.ModifierType state) {
        if (val == 65288 || val == 65535) {
            backspace ();
            return true;
        }

        if (val == 65293) {
            enter ();
            return true;
        }

        insert (((unichar) val).to_string ());
        return true;
    }

    public void insert (string cell) {
        if (!(cell.down () in Data.get_available_letters ().split ("/"))) return;
        grid.reset_row_state ();
        grid.insert (cell.up ());
    }

    public void backspace () {
        grid.reset_row_state ();
        grid.backspace ();
    }

    public void enter () {
        if (!grid.row_filled ()) return;

        if (check_word ()) {
            game_over (true);
            return;
        }

        if (word_exist ()) {
            if (grid.active_row () < 5) {
                grid.next_row ();
            } else {
                game_over (false);
            }
        }
    }
}
