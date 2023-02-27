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

public class WG.Grid : Adw.Bin {
    public const int COLS = 5;
    public const int ROWS = 6;

    private int active_x = 0;
    private int active_y = 0;

    private Gtk.Grid grid = new Gtk.Grid ();
    private Gtk.EventControllerKey controller = new Gtk.EventControllerKey ();

    construct {
        // setup this widget

        this.focusable = true;
        this.can_focus = true;
        accessible_role = Gtk.AccessibleRole.TEXT_BOX;
        update_property (Gtk.AccessibleProperty.LABEL, _("the letter grid"), -1);

        add_css_class ("letter-grid");

        margin_top = 10;
        margin_bottom = 10;
        margin_start = 10;
        margin_end = 10;
        halign = Gtk.Align.CENTER;
        hexpand = true;
        valign = Gtk.Align.CENTER;
        vexpand = true;

        // setup children

        this.child = grid;
        grid.column_homogeneous = true;
        grid.row_homogeneous = true;
        grid.column_spacing = 6;
        grid.row_spacing = 6;

        for (int y = 0; y < ROWS; y++) {
            for (int x = 0; x < COLS; x++) {
                grid.attach (new Cell (), x, y);
            }
        }
        active_cell ().focused = true;

        // setup events

        this.add_controller (controller);
        var context = new Gtk.IMMulticontext ();
        controller.set_im_context (context);

        context.commit.connect ((str) => {
            string key = DataParser.replace (str.down ());
            if (!(key in DataParser.get_available_letters ())) return;
            insert (key);
        });

        controller.key_pressed.connect ((val, code, state) => {
            if (val == Gdk.Key.BackSpace ||
                val == Gdk.Key.Delete ||
                val == Gdk.Key.KP_Delete) {
                backspace ();
                return true;
            }

            if (val == Gdk.Key.Return ||
                val == Gdk.Key.KP_Enter ||
                val == Gdk.Key.ISO_Enter) {
                confirm ();
                return true;
            }

            return false;
        });

        // click event

        var click_controller = new Gtk.GestureClick ();
        this.add_controller (click_controller);
        click_controller.released.connect (() => { this.grab_focus (); });
    }

    /**
     * Emitted when the current word is confirmed.
     *
     * Gets the current row content as the first argument.
     * The second argument is a bool, true if the current row is the last one.
     *
     * Returns List of CellStates.
     * If the word is unknown, it's expected to be an empty list.
     */
    public signal List<CellState> confirmed (string[] row_content);

    /**
     * Emitted when the game ends.
     * (the grid is filled up or the word is guessed)
     *
     * If the game was won is given as a bool argument.
     */
    public virtual signal void game_over (bool win) {
        remove_controller (controller);
    }

    /**
     * Insert into active cell and move the cursor.
     */
    public void insert (string text) {
        reset_row_state ();
        var cell = active_cell ();
        if (cell == null) return;
        cell.content = text.up ();
        activate_next ();
        update_properties ();
    }

    /**
     * Delete from the last cell and move cursor back.
     */
    public void backspace () {
        reset_row_state ();
        Cell cell = activate_prev ();
        cell.content = "";
        update_properties ();
    }

    /**
     * Confirm the current row content.
     *
     * If the confirmation is possible, emits the confirmed() signal.
     */
    public void confirm () {
        // don't do anything if the row is not complete
        if (!is_row_filled ()) return;

        // load the response
        var res = confirmed (get_current_content ());

        // if the response is an empty list, set state as an unknown word
        if (res == null || res.length () <= 0) {
            for (int x = 0; x < COLS; x++) {
                set_cell_state (x, active_y, CellState.UNKNOWN);
            }
            return;
        }

        // otherwise set the state from the response
        bool win = true;
        int x = 0;
        while (x < COLS && x < res.length ()) {
            var current_state = res.nth_data (x);
            set_cell_state (x, active_y, current_state);
            if (current_state != CellState.CORRECT) win = false;
            x++;
        }

        // if the whole row is correct, end the game
        if (win) {
            game_over (true);
            return;
        }

        // finally move the cursor down
        activate_next_row ();
        update_properties ();

        // if we are out of rows, end the game
        if (active_y >= ROWS) game_over (false);
    }

    private void update_properties () {
        update_property (
            Gtk.AccessibleProperty.VALUE_TEXT,
                string.joinv ("", get_current_content()),
            -1);
    }

    private Cell get_cell (int x, int y) {
        return (Cell) grid.get_child_at (x, y);
    }

    private Cell active_cell () {
        return get_cell (active_x, active_y);
    }

    private Cell set_active_cell (int x, int y) {
        var cell = active_cell ();
        if (cell != null) cell.focused = false;
        active_x = x;
        active_y = y;
        cell = active_cell ();
        if (cell != null) cell.focused = true;
        return cell;
    }

    private Cell activate_next () {
        if (active_x == COLS) return active_cell ();
        return set_active_cell (active_x + 1, active_y);
    }

    private Cell activate_prev () {
        if (active_x == 0) return active_cell ();
        return set_active_cell (active_x - 1, active_y);
    }

    private Cell activate_next_row () {
        if (active_y >= ROWS) return active_cell ();
        return set_active_cell (0, active_y + 1);
    }

    public string[] get_current_content () {
        string[] row = {};
        for (int x = 0; x < COLS; x++) {
            var cell = get_cell (x, active_y);
            if (cell == null) {
                row += "";
                continue;
            }
            row += cell.content.down ();
        }
        return row;
    }

    public bool is_row_filled () {
        foreach (string cell in get_current_content ()) {
            if (cell.length == 0) return false;
        }
        return true;
    }

    private void set_cell_state (int x, int y, CellState state) {
        get_cell (x, y).state = state;
    }

    private void reset_row_state () {
        for (int x = 0; x < COLS; x++) {
            set_cell_state (x, active_y, CellState.NONE);
        }
    }
}
