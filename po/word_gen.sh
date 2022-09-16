#!/usr/bin/env bash

set -ue
TMP=$(mktemp -d)

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

# don't assume UTF-8
SET=$(head -1 "$AFF")
# luckily, .aff files begin with 'SET UTF-8' or whatever the encoding i·
ENCODING=${SET##*[[:space:]]}

if [ "$ENCODING" != "UTF-8" ]; then
    echo "reencoding from $ENCODING to UTF-8" >&2
    BDIC=$(basename "$DIC")
    BAFF=$(basename "$AFF")

    iconv "$DIC" -f "$ENCODING" -t 'UTF-8' -o "$TMP/$BDIC"
    iconv "$AFF" -f "$ENCODING" -t 'UTF-8' -o "$TMP/$BAFF"

    DIC="$TMP/$BDIC"
    AFF="$TMP/$BAFF"
fi

filter_and_format() {
    sed -r '
    /^.{5}$/!d              # delete words without exactly 5 letters
    s/[[:upper:]]*/\L&/g    # lowercase
    s/./&\//g               # add slash between letters
    s/^(.*)\/$/"\1\\n"/g    # add quotes and newline
    '
}

unmunch "$DIC" "$AFF" 2>/dev/null |
filter_and_format |
sort -u | 
sed '$s/\\n"$/"/' # remove trailing newline

rm -rf "$TMP"
