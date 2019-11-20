# Lazy load because kubectl completion sucks
# https://github.com/kubernetes/kubernetes/issues/59078
function kubectl() {
  if ! type __start_kubectl > /dev/null 2>&1; then
    # Fails with 127, see https://github.com/kubernetes/kubectl/issues/125
    source <(command kubectl completion zsh)\
      && echo "kubectl completion seems fixed, update zsh config"\
      || true
  fi

  command kubectl "$@"
}
