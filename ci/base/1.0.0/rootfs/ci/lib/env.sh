git_repo_name() {
  local url
  local basename
  local reponame
  cd "$BUILD_DIR" || exit
  url=$(git config --get remote.origin.url)
  basename=$(basename "$url")
  # my-repo.git
  reponame=${basename%.*}
  # my-repo
  echo -n "$reponame"
}

validate_env() {
  [ -z "$AWS_ACCESS_KEY_ID" ] && die "AWS_ACCESS_KEY_ID must be set"
  [ -z "$AWS_SECRET_ACCESS_KEY" ] && die "AWS_SECRET_ACCESS_KEY must be set"
  [ -z "$SLACK_DEV_WEBHOOK_URL" ] && warn "SLACK_DEV_WEBHOOK_URL is not set"
  [ -z "$NPM_TOKEN" ] && info "NPM_TOKEN is not set"
}

guess_environment() {
  cd "$BUILD_DIR"
  branch=$(git symbolic-ref --short -q HEAD)

  case "$branch" in
  "master") echo -n "prod" ;;
  "staging") echo -n "staging" ;;
  *) echo -n "staging" ;;
  esac
}

env_info() {
  echo "IMAGE = ${IMAGE}"
  echo "SHORT_NAME = ${SHORT_NAME}"
}

AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-"362178051443"}
AWS_ECR_REGION=${AWS_ECR_REGION:-"us-west-1"}

PROJECT_REPONAME=${PROJECT_REPONAME:-$(git_repo_name)}

IMAGE_PREFIX=${IMAGE_PREFIX:-""}
SHORT_VERSION=$(cd "${BUILD_DIR}" && git rev-parse --short HEAD)
VERSION="git-${SHORT_VERSION}"

PRIVATE_REGISTRY=${PRIVATE_REGISTRY:-"${AWS_ACCOUNT_ID}.dkr.ecr.us-west-1.amazonaws.com"}
DEPLOY_PATH=${DEPLOY_PATH:-"${BUILD_DIR}/deploy"}

# derived vars
SHORT_NAME="${PROJECT_REPONAME}"
IMAGE="${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}:${VERSION}"
IMAGE_UNTAGGED="${PRIVATE_REGISTRY}/${IMAGE_PREFIX}${SHORT_NAME}"

# For deployment
ENVIRONMENT=${ENVIRONMENT:-$(guess_environment)}
KOPS_STATE_STORE=${KOPS_STATE_STORE:-"s3://binded-kops-${ENVIRONMENT}"}
CLUSTER_NAME=${CLUSTER_NAME:-"${ENVIRONMENT}.b1nded.com"}

export IMAGE
export IMAGE_UNTAGGED
export SHORT_NAME
export AWS_ECR_REGION
export ENVIRONMENT
export KOPS_STATE_STORE
export CLUSTER_NAME
export DEPLOY_PATH
