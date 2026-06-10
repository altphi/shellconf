typeset -ga HISTORY_BLOCK_COMMANDS_LIST=(
  cd
  pushd
  popd
  z
  yazi
  airpods.sh
  "kubectl apply"
)

typeset -ga HISTORY_BLOCK_TOKENS_LIST=(
  --secret
  --password
  production
)

typeset -gA HISTORY_BLOCK_COMMANDS
typeset -gA HISTORY_BLOCK_TOKENS

history_init_blocklists() {
  emulate -L zsh

  local x

  HISTORY_BLOCK_COMMANDS=()
  for x in $HISTORY_BLOCK_COMMANDS_LIST; do
    HISTORY_BLOCK_COMMANDS[$x]=1
  done

  HISTORY_BLOCK_TOKENS=()
  for x in $HISTORY_BLOCK_TOKENS_LIST; do
    HISTORY_BLOCK_TOKENS[$x]=1
  done
}

history_init_blocklists

history_should_block() {
  emulate -L zsh -o extendedglob

  local line="${1%%$'\n'}"
  local -a words
  local x

  words=(${(z)line})
  (( $#words == 0 )) && return 1

  [[ -n ${HISTORY_BLOCK_COMMANDS[$words[1]]} ]] && return 0

  for x in $words; do
    [[ -n ${HISTORY_BLOCK_TOKENS[$x]} ]] && return 0
  done

  return 1
}

zshaddhistory() {
  history_should_block "$1" && return 1
  return 0
}
