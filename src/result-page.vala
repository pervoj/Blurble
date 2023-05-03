/* result-page.vala
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

public class WG.ResultPage : Adw.Bin {

    public DataParser.Word word { get; set; }
    public bool win { get; set; }

    private Gtk.Picture illustration = new Gtk.Picture ();
    private Gtk.Label title_label = new Gtk.Label (null);
    private Adw.Bin word_container = new Adw.Bin ();

    public void reload () {
        illustration.file = GLib.File.new_for_uri (
            "resource:///app/drey/Blurble/" + (win ? "win.svg" : "lose.svg")
        );

        title_label.label = win ? _("You won!") : _("You lost!");
        word_container.child = get_cells_for_word (word, win);
    }

    public signal void play_again ();
    public signal void quit ();

    construct {
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

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        clamp.child = main_box;
        main_box.valign = Gtk.Align.CENTER;

        main_box.append(illustration);

        main_box.append (title_label);
        title_label.margin_top = 36;
        title_label.halign = Gtk.Align.CENTER;
        title_label.add_css_class ("title-1");

        var word_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        main_box.append (word_box);
        word_box.margin_top = 12;
        var word_label = new Gtk.Label (_("The word was:"));
        word_box.append (word_label);
        word_label.halign = Gtk.Align.CENTER;

        word_box.append (word_container);
        word_container.halign = Gtk.Align.CENTER;

        var button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (button_box);
        button_box.halign = Gtk.Align.CENTER;
        button_box.margin_top = 36;

        var play_button = new Gtk.Button.with_mnemonic (_("_Play Again"));
        button_box.append (play_button);
        play_button.add_css_class ("pill");
        play_button.add_css_class ("suggested-action");
        play_button.clicked.connect (() => { play_again (); });
    }

    private Gtk.Widget get_cells_for_word (DataParser.Word word, bool win) {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        foreach (string _cell in word.characters) {
            var cell = new Cell ();
            cell.content = _cell.up ();
            if (win) cell.state = CellState.CORRECT;
            box.append (cell);
        }
        return box;
    }
}
