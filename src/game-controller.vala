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
        print (dictionary.nth_data ((uint) word) + "\n");

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
