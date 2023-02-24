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

public class WG.GameController : Adw.Bin {
    public DataParser.Word correct_word { get; private set; }
    private DataParser.Word[] dictionary = DataParser.get_dictionary ();

    public signal void game_over (bool win);

    private Grid grid = new Grid ();

    public GameController () {
        int32 word_index = Random.int_range (0, (int32) dictionary.length);
        correct_word = dictionary[(uint) word_index];

        debug (_("Current word: %s\n"), correct_word.word);
    }

    construct {
        this.child = grid;

        grid.confirmed.connect (check_word);
        grid.game_over.connect ((win) => { game_over (win); });
    }

    public new bool grab_focus () {
        return grid.grab_focus ();
    }

    private List<CellState> check_word (string[] written_word) {
        if (!DataParser.check_if_word_exists (written_word)) {
            return new List<CellState> ();
        }

        var res_table = new HashTable<int, CellState> (null, null);

        // make a copy to keep the unmatched letters, (with CellState.WRONG)
        string?[] remaining_word = correct_word.characters.copy ();

        // find exact matches
        for (int i = 0; i < written_word.length; i++) {
            string correct_cell = correct_word.characters[i];
            string written_cell = written_word[i];

            if (written_cell == correct_cell) {
                res_table.set (i, CellState.CORRECT);
                // match found, remove it from the remaining array
                remaining_word[i] = null;
                written_word[i] = null;
            } else {
                res_table.set (i, CellState.WRONG);
            }
        }

        for (int w = 0; w < 5; w++) { // for each letter guessed
            if (written_word[w] == null) continue;

            for (int r = 0; r < 5; r++) { // find the first matching remaining letter
                if (written_word[w] == remaining_word[r]) {
                    res_table.set (w, CellState.WRONG_POSITION);
                    // match found, remove it
                    remaining_word[r] = null;
                    break;
                }
            }
        }

        var keys = res_table.get_keys ();
        keys.sort ((a, b) => {
            return (int) (a > b) - (int) (a < b);
        });

        var res = new List<CellState> ();
        foreach (int i in keys) {
            res.append (res_table.get (i));
        }
        return res;
    }

    public void insert (string text) {
        grab_focus ();
        grid.insert (text);
    }

    public void backspace () {
        grab_focus ();
        grid.backspace ();
    }

    public void confirm () {
        grab_focus ();
        grid.confirm ();
    }
}
