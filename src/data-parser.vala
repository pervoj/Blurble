/* data-parser.vala
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

namespace WG.DataParser {
    public string replace (string original) {
        string replaced = original;
        foreach (var replacement in Data.get_replacements ().split ("\n")) {
            string needle = replacement.split ("/")[0].strip ();
            string to_replace = replacement.split ("/")[1].strip ();
            replaced = replaced.replace (needle, to_replace);
        }
        return replaced;
    }

    public List<string> dictionary () {
        string[] words = Data.get_dictionary ().strip ().split ("\n");
        var dict = new List<string> ();

        foreach (string word in words) {
            dict.append (word.strip ());
        }

        return dict;
    }
}
