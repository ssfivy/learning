#!/bin/bash

# Testing various methods of printing help in shell scripts as described here:
# https://samizdat.dev/help-message-for-shell-scripts/
# https://news.ycombinator.com/item?id=23763166

### help.sh — Print this help in multiple ways
###
### Usage:
###   help.sh helptype
###
### Options:
###   helptype  How to print help. Available options are:
###
###             commentsed - Print using comment in script + sed
###             heredoc - Print using heredoc
###             heredocsed - Print using heredoc + sed
###             string - Print using multiline string
###

commentsed() {
    sed -rn 's/^### ?//;T;p' "$0"
    # substitute
    # match a string starting with ### and an optional space after
    # replace with empty string
    # T - Jumps to the end of sed-script if no s/// has done a successful substitution;
    # p - Prints the result of the substitution.
    # $0 - this script
}

heredoc() {
cat <<'EOH'
help.sh — Print this help in multiple ways

Usage:
  help.sh helptype

Options:
  helptype  How to print help. Available options are:

            commentsed - Print using comment in script + sed
            heredoc - Print using heredoc
            heredocsed - Print using heredoc + sed
            string - Print using multiline string
EOH
}

heredocsed() {
  sed -e 's/    //' <<'EOH'
    help.sh — Print this help in multiple ways

    Usage:
      help.sh helptype

    Options:
      helptype  How to print help. Available options are:

                commentsed - Print using comment in script + sed
                heredoc - Print using heredoc
                heredocsed - Print using heredoc + sed
                string - Print using multiline string
EOH
}

USAGE="help.sh — Print this help in multiple ways

Usage:
  help.sh helptype

Options:
  helptype  How to print help. Available options are:

            commentsed - Print using comment in script + sed
            heredoc - Print using heredoc
            heredocsed - Print using heredoc + sed
            string - Print using multiline string
"

string() {
echo "$USAGE"
}


# Bonus: Example on how to parse arguments in pure bash
while (( $# )); do
  case "$1" in
    -h|--help)
      heredoc
      exit
      ;;

    -v|--version)
      echo "0.0.1"
      exit
      ;;

    -d|--debug)
      echo "Not implemented!"
      ;;

    -a|--arg)
      arg_value="$2"
      shift 2
      ;;

    *)
      if [[ ! -v pos1 ]]; then
        pos1="$1"
      elif [[ ! -v pos2 ]]; then
        pos2="$1"
      else
        >&2 printf "%s: unrecognized argument\n" "$1"
        >&2 usage
        exit 1
      fi
  esac

  shift
done

echo "$arg_value"

if [[ $pos1 == "commentsed" ]]; then
    commentsed
elif [[ $pos1 == "heredoc" ]]; then
    heredoc
elif [[ $pos1 == "heredocsed" ]]; then
    heredocsed
elif [[ $pos1 == "string" ]]; then
    string
fi
