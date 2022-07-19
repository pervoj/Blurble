#!/bin/sh

if ! command -v unmunch > /dev/null
then
    echo "for this script to work you need to install hunspell"
    exit 1
fi

if [ -z ${1+x} ]
then
    echo "Usage: $0 <DICTIONARY>"
    exit 1
fi



unmunch                                                         \
    /usr/share/myspell/dicts/$1.dic                             \
    /usr/share/myspell/dicts/$1.aff 2>/dev/null                 \
    | sed -nr 's/^(.)(.)(.)(.)(.)$/"\1\/\2\/\3\/\4\/\5\\n"/p'   \
    | tr '[:upper:]' '[:lower:]'                                \
    | sort | uniq
