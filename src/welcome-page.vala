/* welcome-page.vala
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

[GtkTemplate (ui = "/app/drey/Blurble/welcome-page.ui")]
public class WG.WelcomePage : Adw.Bin {
    public string icon_name { get; private set; default = Constants.APP_ID; }

    [GtkChild]
    private unowned Gtk.Button play_button;

    construct {
        play_button.clicked.connect (() => { play (); });
    }

    public signal void play ();
}
