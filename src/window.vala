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

[GtkTemplate (ui = "/app/drey/Blurble/window.ui")]
public class WG.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.Box main_content;

    [GtkChild]
    private unowned Gtk.MenuButton menu_button;

    private GameController gc = new GameController ();
    private Keyboard k = new Keyboard ();

    private Settings settings = new Settings (Constants.APP_ID);

    public Window (Gtk.Application app) {
        Object (application: app);

        main_content.append (gc.grid);
        main_content.append (k);

        gc.game_over.connect (game_over);

        k.insert.connect (gc.insert);
        k.enter.connect (gc.enter);
        k.backspace.connect (gc.backspace);
        k.game_over = false;

        ((Gtk.Widget) this).add_controller (gc.event);

        set_keyboard_visibility (settings.get_boolean ("show-keyboard"));
        settings.changed.connect ((key) => {
            if (key != "show-keyboard") return;
            set_keyboard_visibility (settings.get_boolean ("show-keyboard"));
        });
    }

    private void game_over (bool win) {
        ((Gtk.Widget) this).remove_controller (gc.event);
        k.game_over = true;

        var dialog = new Gtk.MessageDialog (
            this,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.INFO,
            Gtk.ButtonsType.OK,
            win ?
                _("You won!") :
                _("You lost! The word was: %s").printf (gc.get_word ())
        );

        dialog.response.connect (close);

        dialog.show ();
    }

    public void set_keyboard_visibility (bool visible) {
        k.visible = visible;
    }

    public void open_menu () {
        menu_button.popup ();
    }
}
