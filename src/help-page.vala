/* help-page.vala
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

public class WG.HelpPage : Adw.Bin {
    private string title = _("Help");
    private string body = _(
        "The game consists of <b>guessing words</b> five characters long. " +
        "You try to enter your guesses one by one, pressing Enter after each " +
        "one.\n\n" +
        "After confirmation, the cell <b>color changes</b> to indicate how " +
        "close you are to the word you are looking for with your guess:"
    );

    // Word cells are separated by slashes, the cell with state preview starts with exclamation mark
    private string correct_word = C_("Preview of the word cells", "!w/e/a/r/y");
    private string correct_word_desc = _(
        "<b>W</b> is in the word and in the correct spot."
    );

    // Word cells are separated by slashes, the cell with state preview starts with exclamation mark
    private string position_word = C_("Preview of the word cells", "p/!i/l/l/s");
    private string position_word_desc = _(
        "<b>I</b> is in the word but in the wrong spot."
    );

    // Word cells are separated by slashes, the cell with state preview starts with exclamation mark
    private string wrong_word = C_("Preview of the word cells", "v/a/g/!u/e");
    private string wrong_word_desc = _(
        "<b>U</b> is not in the word in any spot."
    );

    public signal void back ();

    construct {
        var shortcut_controller = new Gtk.ShortcutController ();
        this.add_controller (shortcut_controller);
        shortcut_controller.scope = Gtk.ShortcutScope.GLOBAL;

        // add escape button shortcut
        shortcut_controller.add_shortcut (new Gtk.Shortcut (
            (!) Gtk.ShortcutTrigger.parse_string ("Escape"),
            new Gtk.CallbackAction (() => { back (); })
        ));

        // basic widget setup

        this.vexpand = true;

        var scrolled_window = new Gtk.ScrolledWindow ();
        this.child = scrolled_window;

        var viewport = new Gtk.Viewport (null, null);
        scrolled_window.child = viewport;

        var clamp = new Adw.Clamp ();
        viewport.child = clamp;
        clamp.tightening_threshold = 400;
        clamp.maximum_size = 600;
        clamp.add_css_class ("container");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 32);
        clamp.child = main_box;
        main_box.valign = Gtk.Align.CENTER;

        // page title
        var title_label = new Gtk.Label (title);
        main_box.append (title_label);
        title_label.halign = Gtk.Align.CENTER;
        title_label.add_css_class ("title-1");

        // page body
        var body_label = new Gtk.Label (body);
        main_box.append (body_label);
        body_label.halign = Gtk.Align.CENTER;
        body_label.wrap = true;
        body_label.use_markup = true;
        body_label.justify = Gtk.Justification.CENTER;

        // preview of the states

        main_box.append (get_state_preview (
            correct_word, correct_word_desc, CellState.CORRECT
        ));

        main_box.append (get_state_preview (
            position_word, position_word_desc, CellState.WRONG_POSITION
        ));

        main_box.append (get_state_preview (
            wrong_word, wrong_word_desc, CellState.WRONG
        ));
    }

    /**
     * returns the whole preview widget with the cells and the explanation
     */
    private Gtk.Widget get_state_preview (
        string word, string desc, CellState state
    ) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

        var cells = get_cells_for_word (word, state);
        box.append (cells);
        cells.halign = Gtk.Align.CENTER;

        var label = new Gtk.Label (desc);
        box.append (label);
        label.halign = Gtk.Align.CENTER;
        label.use_markup = true;

        return box;
    }

    /**
     * returns widget with the cells for the given word
     */
    private Gtk.Widget get_cells_for_word (string word, CellState state) {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);

        var _word = word.split ("/");
        foreach (string _cell in _word) {
            _cell = _cell.strip ();
            var cell = new Cell ();

            if (_cell.has_prefix ("!")) {
                cell.state = state;
                _cell = _cell.replace ("!", "").strip ();
            }

            cell.content = _cell.up ();

            box.append (cell);
        }

        return box;
    }
}
