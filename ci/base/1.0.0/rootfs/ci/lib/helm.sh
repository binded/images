yamlkey_to_value() {
  yamlkey="$1"
  envkey="${yamlkey//./_}"
  varname=$(echo -n "HELM_${ENVIRONMENT}_$envkey" | awk '{print toupper($0)}')
  echo -n "${!varname}"
}

helmset() {
  yamlkeys=("$@")

  for yamlkey in "${yamlkeys[@]}"; do
    # TODO: only if value is not empty?
    echo "--set"
    echo "${yamlkey}=$(yamlkey_to_value "$yamlkey")"
  done
}
