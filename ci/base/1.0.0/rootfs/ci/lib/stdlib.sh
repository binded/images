err() {
  echo "$@" 1>&2;
}

die() {
  err "Error:" "$@"
  exit 1
}

warn() {
  echo "Warn:" "$@"
}

info() {
  echo "Info:" "$@"
}

git_branch() {
  git symbolic-ref --short -q HEAD
}

guess_environment() {
  cd "$1"
  branch=$(git_branch)

  case "$branch" in
  "master") echo -n "prod" ;;
  "staging") echo -n "staging" ;;
  *) echo -n "staging" ;;
  esac
}

git_repo_name() {
  local url
  local basename
  local reponame
  cd "$1" || exit
  url=$(git config --get remote.origin.url)
  basename=$(basename "$url")
  # my-repo.git
  reponame=${basename%.*}
  # my-repo
  echo -n "$reponame"
}
