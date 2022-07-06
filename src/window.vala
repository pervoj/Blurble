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
    private unowned Gtk.Grid grid;

    public Window (Gtk.Application app) {
        Object (application: app);
        
        for (int x = 0; x < 5; x++) {
            for (int y = 0; y < 6; y++) {
                Gtk.Label cell = new Gtk.Label ("");
                cell.add_css_class ("cell");
                grid.attach (cell, x, y);
            }
        }
    }
}
