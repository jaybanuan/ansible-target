#!/bin/bash

#function logger() {
#    echo "$@"
#}


#if [ "$1" = "/sbin/init" ]; then
#    logger "Process /docker-entrypoint.d/"
#
#    find "/docker-entrypoint.d/" -type f -print | sort -V | while read -r FILEPATH; do
#        case "$FILEPATH" in
#            *.sh)
#                if [ -x "$FILEPATH" ]; then
#                    logger "Launch: $FILEPATH";
#                    "$FILEPATH"
#                else
#                    # warn on shell scripts without exec bit
#                    logger "Not launch: $FILEPATH, not executable";
#                fi
#                ;;
#            *)
#                logger "Ignore: $FILEPATH"
#                ;;
#        esac
#    done
#fi
exec "$@"