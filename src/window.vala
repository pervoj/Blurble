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

[GtkTemplate (ui = "/cz/pervoj/WordGame/window.ui")]
public class WG.Window : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.Box content;

    public Window (Gtk.Application app) {
        Object (application: app);
        
        Grid grid = new Grid ();
        content.append (grid);

        var event = new Gtk.EventControllerKey ();
        event.key_pressed.connect ((val, code, state) => {
            if (val == 65288 || val == 65535) {
                grid.backspace ();
                return true;
            }

            if (val == 65293) {
                print ("enter\n");
                return true;
            }

            string key = ((char) val).to_string ();
            if (!(key in "abcdefghijklmnopqrstuvwxyz")) return false;
            grid.insert (key.up ());
            return true;
        });
        ((Gtk.Widget) this).add_controller (event);
    }
}
