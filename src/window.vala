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
    public bool show_back_button { get; private set; }
    private bool game_started = false;

    [GtkChild]
    private unowned Gtk.Button back_button;

    [GtkChild]
    private unowned Gtk.MenuButton menu_button;

    [GtkChild]
    private unowned Gtk.Stack stack;

    public Window (Gtk.Application app) {
        Object (application: app);
    }

    construct {
        var help_action = new SimpleAction ("help", null);
        this.add_action (help_action);
        help_action.activate.connect (help);

        stack.notify["visible-child-name"].connect (update_back_btn_visibility);
        back_button.clicked.connect (back);

        var welcome_page = new WelcomePage ();
        stack.add_named (welcome_page, "welcome");

        var game_page = new GamePage ();
        stack.add_named (game_page, "game");

        var help_page = new HelpPage ();
        stack.add_named (help_page, "help");

        welcome_page.play.connect (start_game);
        game_page.game_over.connect (close);
        help_page.back.connect (back);
    }

    private void start_game () {
        stack.visible_child_name = "game";
        game_started = true;
    }

    private void help () {
        stack.visible_child_name = "help";
    }

    private void back () {
        stack.visible_child_name = game_started ? "game" : "welcome";
    }

    private void update_back_btn_visibility () {
        string[] visible_on = { "help" };
        string current_page = stack.visible_child_name;
        show_back_button = (current_page in visible_on);
    }

    public void open_menu () {
        menu_button.popup ();
    }
}
