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
