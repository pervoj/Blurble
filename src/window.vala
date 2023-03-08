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
    private bool game_over = false;

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
        help_action.activate.connect (() => {
            stack.visible_child_name = "help";
        });

        stack.notify["visible-child-name"].connect (update_back_btn_visibility);
        back_button.clicked.connect (back);

        var welcome_page = new WelcomePage ();
        stack.add_named (welcome_page, "welcome");

        var game_page = new GamePage ();
        stack.add_named (game_page, "game");

        var result_page = new ResultPage ();
        stack.add_named (result_page, "result");

        var help_page = new HelpPage ();
        stack.add_named (help_page, "help");

        welcome_page.play.connect (() => {
            stack.visible_child_name = "game";
            game_started = true;
            game_page.new_word ();
        });

        game_page.game_over.connect ((word, win) => {
            game_over = true;
            result_page.win = win;
            result_page.word = word;
            result_page.reload ();
            stack.visible_child_name = "result";
        });

        result_page.play_again.connect (() => {
            game_started = false;
            game_over = false;
            stack.visible_child_name = "welcome";
        });
        result_page.quit.connect (close);

        help_page.back.connect (back);
    }

    private void back () {
        if (game_started || game_over) {
            if (game_over) {
                stack.visible_child_name = "result";
            } else {
                stack.visible_child_name = "game";
            }
        } else {
            stack.visible_child_name = "welcome";
        }
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
