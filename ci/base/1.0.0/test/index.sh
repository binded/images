set -o errexit

source ../rootfs/ci/lib/stdlib.sh

docker_image_exists "362178051443.dkr.ecr.us-west-1.amazonaws.com/binded-ui:git-ed2fed2"
docker_image_exists "362178051443.dkr.ecr.us-west-1.amazonaws.com/binded-ui:doesnotexist" \
  && exit 1 || true