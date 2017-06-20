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

aws_ecr_curl() {
  login_cmd=$(aws ecr get-login)
  username=$(echo "$login_cmd" | cut -d " " -f 4)
  password=$(echo "$login_cmd" | cut -d " " -f 6)
  endpoint=$(echo "$login_cmd" | cut -d " " -f 9)

  args=("$@")
  args_length=${#args[@]}
  args_last=${args[$args_length-1]}
  unset 'args[${args_length}-1]'
  path="${args_last}"

  curl \
    -u "${username}:${password}" \
    "${args[@]}" \
    "${endpoint}${path}"
}

# Usage: docker_tag_exists somerepo sometag
docker_tag_exists() {
  repo_name="$1"
  tag="$2"
  aws_ecr_curl \
    --head \
    --fail \
    -s \
    "/v2/${repo_name}/manifests/${tag}" \
    > /dev/null
}

