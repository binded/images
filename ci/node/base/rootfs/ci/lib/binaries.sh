needs_resolution() {
  local semver=$1
  if ! [[ "$semver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

install_yarn() {
  local version="$1"
  local dir="$NVM_BIN"
  local installdir="$NVM_BIN/../yarn"

  if needs_resolution "$version"; then
    echo "Resolving yarn version ${version:-(latest)} via semver.io..."
    local version=$(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=${version}" https://semver.herokuapp.com/yarn/resolve)
  fi

  echo "Downloading and installing yarn ($version)..."
  local download_url="https://yarnpkg.com/downloads/$version/yarn-v$version.tar.gz"
  local code=$(curl "$download_url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/yarn.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "Unable to download yarn: $code" && false
  fi
  rm -rf $installdir
  mkdir -p "$installdir"
  # https://github.com/yarnpkg/yarn/issues/770
  if tar --version | grep -q 'gnu'; then
    tar xzf /tmp/yarn.tar.gz -C "$installdir" --strip 1 --warning=no-unknown-keyword
  else
    tar xzf /tmp/yarn.tar.gz -C "$installdir" --strip 1
  fi
  chmod +x $installdir/bin/*
  ln -f -s $installdir/bin/* "${dir}"
  echo "Installed yarn $(yarn --version)"
}


# Workaround: https://github.com/npm/npm/issues/15611#issuecomment-289133810
install_npm_workaround() {
  local version=${1}
  local lib_dir="${NVM_BIN}/../lib"
  pushd /tmp > /dev/null
  npm install --unsafe-perm --quiet "npm@${version}" > /dev/null 2>&1
  rm -rf "${lib_dir}/node_modules"
  mv node_modules "${lib_dir}/"
  popd > /dev/null
}

install_npm() {
  local version="$1"
  local npm_lock="$2"
  local dir="$NVM_BIN"

  if $npm_lock && [ "$version" == "" ]; then
    echo "Detected package-lock.json: defaulting npm to version 5.x.x"
    version="5.x.x"
  fi

  if [ "$version" == "" ]; then
    echo "Using default npm version: `npm --version`"
  else
    if needs_resolution "$version"; then
      echo "Resolving npm version ${version} via semver.io..."
      version=$(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=${version}" https://semver.herokuapp.com/npm/resolve)
    fi
    if [[ `npm --version` == "$version" ]]; then
      echo "npm `npm --version` already installed with node"
    else
      echo "Downloading and installing npm $version (replacing version `npm --version`)..."

      install_npm_workaround "$version"
    fi
  fi
}

