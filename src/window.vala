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

    private Grid grid = new Grid ();

    private Gtk.EventControllerKey event = new Gtk.EventControllerKey ();

    public Window (Gtk.Application app) {
        Object (application: app);
        content.append (grid);
        event.key_pressed.connect (key_pressed);
        ((Gtk.Widget) this).add_controller (event);
    }

    private bool key_pressed (uint val, uint code, Gdk.ModifierType state) {
        if (val == 65288 || val == 65535) {
            grid.backspace ();
            return true;
        }

        if (val == 65293) {
            if (grid.get_row ().length != 5) return true;
            print (grid.get_row () + "\n");
            if (grid.active_row () == 5) {
                ((Gtk.Widget) this).remove_controller (event);
                return true;
            }
            grid.next_row ();
            return true;
        }

        string key = ((char) val).to_string ();
        if (!(key in "abcdefghijklmnopqrstuvwxyz")) return false;
        grid.insert (key.up ());
        return true;
    }
}
