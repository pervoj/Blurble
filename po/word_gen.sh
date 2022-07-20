#!/bin/sh

usage () {
    echo "Usage: $0 <DICTIONARY>"
    exit 1
}

error_no_hunspell () {
    echo "The command unmunch doesn't exist. Did you install hunspell?"
    exit 1
}

error_no_dicts () {
    echo "You don't have any dictionary installed."
    echo "The packages are generally called \"hunspell-\$LANGUAGE_CODE\" "\
        "(e.g. hunspell-en_gb), but that might depend on your distro"
    exit 1
}

error_dict_not_installed () {
    echo "Dictionary for language \"$1\" is not installed."
    echo "The packages are generally called \"hunspell-\$LANGUAGE_CODE\" "\
        "(e.g. hunspell-en_gb), but that might depend on your distro"
    exit 1
}

if ! command -v unmunch > /dev/null; then
    error_no_hunspell
fi

if [ -z ${1+x} ]; then
    usage
fi

for dict_path in /usr/share/myspell/dicts/ /usr/share/hunspell/
do
    if [ -d "$dict_path" ] && [ "$(ls -A $dict_path)" ]; then
        DICTS="$dict_path"
    fi
done

if [ -z ${DICTS+x} ]; then
    error_no_dicts
fi

DIC="$DICTS/$1.dic"
AFF="$DICTS/$1.aff"

if [ ! -f "$DIC" ]; then
    error_dict_not_installed "$1"
fi

unmunch "$DIC" "$AFF" 2>/dev/null | grep -E '^.{5}$' \
| sed -r 's/./&\//g;                
          s/^(.*)\/$/"\1\\n"/g;
          $s/\\n//;' \
| tr '[:upper:]' '[:lower:]'                                \
| sort | uniq
