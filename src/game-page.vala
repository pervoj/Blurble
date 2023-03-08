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

public class WG.GamePage : Adw.Bin {
    private GameController gc = new GameController ();
    private Keyboard k = new Keyboard ();

    private Settings settings = new Settings (Constants.APP_ID);

    public signal void game_over ();

    public GamePage () {
        gc.game_over.connect (do_game_over);
        k.game_over = false;

        k.insert.connect (gc.insert);
        k.enter.connect (gc.confirm);
        k.backspace.connect (gc.backspace);

        gc.change_letter_state.connect ((val, state) => {
            k.set_key_state (val, state);
        });

        set_keyboard_visibility (settings.get_boolean ("show-keyboard"));
        settings.changed.connect ((key) => {
            if (key != "show-keyboard") return;
            set_keyboard_visibility (settings.get_boolean ("show-keyboard"));
        });
    }

    construct {
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 32);
        this.child = main_box;
        main_box.halign = Gtk.Align.CENTER;
        main_box.valign = Gtk.Align.CENTER;

        main_box.append (gc);
        main_box.append (k);

        gc.grab_focus ();
    }

    private void do_game_over (bool win) {
        k.game_over = true;

        var dialog = new Gtk.MessageDialog (
            null,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.INFO,
            Gtk.ButtonsType.OK,
            win ?
                _("You won!") :
                _("You lost! The word was: %s").printf (gc.correct_word.word)
        );

        dialog.response.connect (() => { game_over (); });

        dialog.show ();
    }

    public void set_keyboard_visibility (bool visible) {
        k.visible = visible;
    }
}
