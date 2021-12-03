export FZF_EDIT_OPTS="--preview 'pygmentize -f terminal256 -O style=monokai -g {}' --preview-window=right:60% --prompt 'edit  '"
export FZF_EDIT_COMMAND="$FZF_DEFAULT_COMMAND"

# CTRL-P - Edit the selected file in $EDITOR
fzf-edit-widget() {
  local cmd="${FZF_EDIT_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
		-o -type d -print \
		-o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
	local file="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_EDIT_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$file" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="$EDITOR ${(q)file}"
  zle accept-line
  local ret=$?
  unset file # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N   fzf-edit-widget
bindkey '^P' fzf-edit-widget

export FZF_GIT_REPOS_DIR="$HOME/git"
export FZF_GIT_REPO_OPTS="--preview '(cd ${FZF_GIT_REPOS_DIR:-.}/{} && git remote get-url origin && echo && git status && echo && ls --color=always -lah)' --prompt 'repo  '"

# CTRL-O - Search recursively for git repos and open the selected one
fzf-cd-git-widget() {
  local cmd="${FZF_GIT_REPO_COMMAND:-"command find ${FZF_GIT_REPOS_DIR:-.} -type d -exec test -e '{}/.git' ';' -printf '%P\n' -prune 2> /dev/null | sort"}"
	setopt localoptions pipefail no_aliases 2> /dev/null
	local repo="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_GIT_REPO_OPTS" $(__fzfcmd) +m)"
	if [[ -z "$repo" ]]; then
    zle redisplay
		return 0
	fi
	zle push-line # Clear buffer. Auto-restored on next prompt.
	BUFFER="cd $(realpath --relative-to . ${FZF_GIT_REPOS_DIR:-.}/${(q)repo})"
	zle accept-line
	local ret=$?
	unset repo # ensure this doesn't end up appearing in prompt expansion
	zle reset-prompt
	return $ret
}
zle     -N     fzf-cd-git-widget
bindkey '^O'   fzf-cd-git-widget

export FZF_GIT_REPOS_DIR_WORK="$HOME/nv/git"
export FZF_GIT_REPO_WORK_OPTS="--preview '(cd ${FZF_GIT_REPOS_DIR_WORK:-.}/{} && git remote get-url origin && echo && git status && echo && ls --color=always -lah)' --prompt 'repo (work)  '"

# CTRL-N - Search recursively for git repos and open the selected one (work)
fzf-cd-git-work-widget() {
  local cmd="${FZF_GIT_REPO_WORK_COMMAND:-"command find ${FZF_GIT_REPOS_DIR_WORK:-.} -type d -exec test -e '{}/.git' ';' -printf '%P\n' -prune 2> /dev/null | sort"}"
	setopt localoptions pipefail no_aliases 2> /dev/null
	local repo="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_GIT_REPO_WORK_OPTS" $(__fzfcmd) +m)"
	if [[ -z "$repo" ]]; then
    zle redisplay
		return 0
	fi
	zle push-line # Clear buffer. Auto-restored on next prompt.
	BUFFER="cd $(realpath --relative-to . ${FZF_GIT_REPOS_DIR_WORK:-.}/${(q)repo})"
	zle accept-line
	local ret=$?
	unset repo # ensure this doesn't end up appearing in prompt expansion
	zle reset-prompt
	return $ret
}
zle     -N   fzf-cd-git-work-widget
bindkey '^N' fzf-cd-git-work-widget

export FZF_GIT_CHECKOUT_OPTS="--preview 'git --no-pager log --color=always {}' --prompt='git checkout  '"

# CTRL-A - Checkout the selected git branch
fzf-branch-widget() {
  git -C . rev-parse 2> /dev/null || return 0
  local cmd="${FZF_GIT_CHECKOUT_COMMAND:-"command git --no-pager branch --no-color | sed -E 's/\*?\s+//'"}"
	setopt localoptions pipefail no_aliases 2> /dev/null
	local branch="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_GIT_CHECKOUT_OPTS" $(__fzfcmd) +m)"
	if [[ -z "$branch" ]]; then
    zle redisplay
		return 0
	fi
	zle push-line # Clear buffer. Auto-restored on next prompt.
	BUFFER="git checkout ${(q)branch}"
	zle accept-line
	local ret=$?
	unset branch
	zle reset-prompt
	return $ret
}
zle     -N   fzf-branch-widget
bindkey '^A' fzf-branch-widget

export FZF_GIT_MERGE_OPTS="--preview 'git --no-pager log --color=always {}' --prompt='git merge  '"

# CTRL-Y - Merge the selected git branch
fzf-merge-widget() {
  git -C . rev-parse 2> /dev/null || return 0
	local cmd="${FZF_GIT_MERGE_COMMAND:-"command git --no-pager branch --no-color | sed -E 's/\*?\s+//'"}"
	setopt localoptions pipefail no_aliases 2> /dev/null
	local branch="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_GIT_MERGE_OPTS" $(__fzfcmd) +m)"
	if [[ -z "$branch" ]]; then
    zle redisplay
		return 0
	fi
	zle push-line # Clear buffer. Auto-restored on next prompt.
	BUFFER="git merge ${(q)branch}"
	zle accept-line
	local ret=$?
	unset branch
	zle reset-prompt
	return $ret
}
zle     -N   fzf-merge-widget
bindkey '^Y' fzf-merge-widget

export FZF_GIT_REBASE_OPTS="--preview 'git --no-pager log --color=always {}' --prompt='git rebase  '"

# CTRL-E - Rebase the selected git branch
fzf-rebase-widget() {
  git -C . rev-parse 2> /dev/null || return 0
	local cmd="${FZF_GIT_MERGE_COMMAND:-"command git --no-pager branch --no-color | sed -E 's/\*?\s+//'"}"
	setopt localoptions pipefail no_aliases 2> /dev/null
	local branch="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_GIT_REBASE_OPTS" $(__fzfcmd) +m)"
	if [[ -z "$branch" ]]; then
    zle redisplay
		return 0
	fi
	zle push-line # Clear buffer. Auto-restored on next prompt.
	BUFFER="git rebase ${(q)branch}"
	zle accept-line
	local ret=$?
	unset branch
	zle reset-prompt
	return $ret
}
zle     -N   fzf-rebase-widget
bindkey '^E' fzf-rebase-widget

