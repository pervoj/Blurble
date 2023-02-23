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
    private HashTable<string, string> replacements;
    private void load_replacements () {
        if (replacements == null) {
            replacements = new HashTable<string, string> (str_hash, str_equal);
            foreach (var replacement in Data.get_replacements ().split ("\n")) {
                string[] _splitted = replacement.split ("/");
                replacements.set (_splitted[0].strip (), _splitted[1].strip ());
            }
        }
    }

    /**
     * Replaces characters in the given string according to the rules.
     */
    public string replace (string original) {
        load_replacements ();
        string replaced = original;
        foreach (string needle in replacements.get_keys ()) {
            string to_replace = replacements.get (needle);
            replaced = replaced.replace (needle, to_replace);
            replaced = replaced.replace (needle.up (), to_replace.up ());
        }
        return replaced;
    }

    public string[] get_available_letters () {
        if (_available_letters == null) {
            _available_letters = Data.get_available_letters ().split ("/");
        }
        return _available_letters;
    }
    private string[] _available_letters;

    /**
     * Returns List of Word instances from the dictionary.
     */
    public Word[] get_dictionary () {
        if (_dictionary == null) {
            _dictionary = {};
            string[] words = Data.get_dictionary ().strip ().split ("\n");
            foreach (string word in words) {
                _dictionary += new Word (word);
            }
        }
        return _dictionary;
    }
    private Word[] _dictionary;

    /**
     * Class representing a word from the dictionary.
     */
    public class Word : Object {
        /**
         * The exact value of the word from the dictionary (with slashes).
         */
        public string val { get; construct; }

        /**
         * The normal form of the word.
         */
        public string word {
            get {
                if (_word == null) {
                    _word = val.replace ("/", "");
                }
                return _word;
            }
        }
        private string _word;

        /**
         * The replaced form of the word.
         */
        public string replaced {
            get {
                if (_replaced == null) {
                    _replaced = replace(word);
                }
                return _replaced;
            }
        }
        private string _replaced;

        /**
         * Characters of the word with already replaced characters.
         */
        public string[] characters {
            get {
                if (_characters == null) {
                    _characters = replace(val).split ("/");
                }
                return _characters;
            }
        }
        private string[] _characters;

        /**
         * Takes the exact value of the word from the dictionary (with slashes).
         *
         * For example: h/o/u/s/e
         */
        public Word (string val) {
            Object (val: val.strip ().down ());
        }
    }
}
