#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/node_modules/@b2ns/libshell/libshell.sh"

Args_define "-u --user" "github user name" "<any>!"
Args_define "-y --year" "back to which year" "<int>" "1992"
Args_define "--repo" "repo name" "<any>" "1992"
Args_define "--token" "github access token" "<any>!"
Args_define "-h --help" "Show this help"

Args_parse "$@"

if Args_has "-h" || (($# == 0)); then
  Args_help
  exit
fi

backToThe1992() {
  local username="$1"
  local -i year="$2"
  local repo="$3"
  local access_token="$4"

  File_isDir "$repo" || mkdir "$repo"
  cd "$repo" || exit

  git init
  echo "# $year" >README.md
  git add .
  GIT_AUTHOR_DATE="${year}-01-01T12:00:00" GIT_COMMITTER_DATE="${year}-01-01T12:00:00" git commit -m "$year"
  git remote add origin "https://${access_token}@github.com/${username}/${repo}.git"
  git branch -M master
  git push -u origin master -f

  cd ..
  rm -rf "repo"

  IO_info "check your profile: $(Color "https://github.com/$username" "blue" "underline")."
  IO_success "Done!"
}

backToThe1992 "$(Args_get "-u")" "$(Args_get "-y")" "$(Args_get "--repo")" "$(Args_get "--token")"
