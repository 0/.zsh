## Input

# Emacs mode.
bindkey -e

# Too many characters in the default.
WORDCHARS=

# Special keys.
[[ -n "$terminfo[kdch1]" ]] && bindkey "$terminfo[kdch1]" delete-char           # Delete
[[ -n "$terminfo[khome]" ]] && bindkey "$terminfo[khome]" beginning-of-line     # Home
[[ -n "$terminfo[kend]" ]]  && bindkey "$terminfo[kend]"  end-of-line           # End
[[ -n "$terminfo[kpp]" ]]   && bindkey "$terminfo[kpp]"   up-line-or-history    # Page up
[[ -n "$terminfo[knp]" ]]   && bindkey "$terminfo[knp]"   down-line-or-history  # Page down


## Completion

mkdir -p "${HOME}/.zcompdump"
autoload -U compinit
compinit -i -d "${HOME}/.zcompdump/${HOST}-${ZSH_VERSION}"

zmodload zsh/complist
# Shift-tab.
[[ -n "$terminfo[kcbt]" ]] && bindkey "$terminfo[kcbt]" reverse-menu-complete

setopt always_to_end
setopt complete_in_word

# Use ls colors.
zstyle ':completion:*' list-colors ''
# Try case-insensitive-ish first, then some voodoo pilfered from chapter 6 of
# "A User's Guide to the Z-Shell".
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[-._]=* r:|=*' 'l:|=* r:|=*'
# Always show a menu.
zstyle ':completion:*' menu select


## History

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history

HISTSIZE=10000
SAVEHIST=10000


## Prompts

setopt prompt_subst

git_prompt() {
	local name
	name="$(git branch --show-current 2>/dev/null)"
	[[ "$?" == '0' ]] || return

	git diff --quiet
	local unstaged="$?"
	git diff --quiet --cached
	local staged="$?"

	if [[ "$unstaged" != '0' ]]; then
		printf ' %s' '%F{yellow}'
	elif [[ "$staged" != '0' ]]; then
		printf ' %s' '%F{cyan}'
	else
		printf ' %s' '%F{magenta}'
	fi

	if [[ -z "$name" ]]; then
		printf '%s' "$(git rev-parse --short HEAD)"
	else
		printf '%s' "$name"
	fi

	printf '%s' '%f'
}

PROMPT='%{%}%F{${HOST_COLOR:-white}}%M%F %B%F{magenta}%~%f%b '
RPROMPT='%(?.%F{green}.%? %F{red})%*%f$(git_prompt)'


## Misc

setopt auto_pushd

setopt extended_glob

setopt interactive_comments

unsetopt beep


## Functions and aliases

# Activate a virtualenv from anywhere inside it.
vact() {
	local last=""
	local dir="$(pwd)"

	while [[ "$last" != "$dir" ]]; do
		local try="${dir}/bin/activate"

		if [[ -f "$try" ]]; then
			. "$try"

			return
		fi

		last="$dir"
		dir="$(dirname "$dir")"
	done
}

alias :q=exit
alias :Q=exit

alias t=true
alias nil=false

if [[ "$(uname)" == 'Darwin' ]]; then
	# BSD ls
	alias ls='ls -FGh'
else
	# GNU ls
	alias ls='ls --color=auto --classify --human-readable'
fi

# Replace newlines with commas, but leave the final newline as is.
alias comma="tr '\n' , | rev | cut -c 2- | rev"
alias d='dirs -v'
alias g='git'
alias grep='grep --color=auto --line-number'
alias gst='git status --short --branch'
alias l='ls -ahl'
alias mytop='htop -u "${USER}"'
alias pathto='readlink -f'
alias qr='qrencode -t ANSIUTF8'
# Without connection sharing.
alias ssh-fresh='ssh -S none'
alias stickify='find . -type d -not -perm -g=s -print0 | xargs -0 chmod g+s'
alias ta='tmux attach'
alias tree='tree -C'
alias vimpg='vim -R -'
alias vlc='vlc --extraintf oldrc --rc-unix /tmp/vlc.sock'


## Slurm

# Show all jobs completed since the specified time.
srecent() {
	since="$1"

	if [[ -z "$since" ]]; then
		echo "usage: $0 <since>"
		return
	fi

	sacct --noheader --units=M --state=BF,CA,CD,DL,F,NF,OOM,PR,TO \
			--starttime "$since" --endtime now \
			-o End,State,JobID%-16,JobName%-120,Elapsed \
		| command grep -v -e '[0-9]\.batch  ' -e '[0-9]\.extern  ' \
		| sort
}

alias sq='squeue -o "%8A %8F %8K %50j %3t %15R %20P %10u %3C %7m %12M %8Q"'
alias squ='sq -u "${USER}"'
alias jobcount='squeue --noheader -o "%t" -u "${USER}" | sort | uniq -c'
alias jobcountall='squeue --noheader -o "%t" | sort | uniq -c'


## Local settings

if [[ -f ~/.zshrc.local ]]; then
	source ~/.zshrc.local
fi

: ${ZSH="${HOME}/.zsh"}


## Plugins

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=512

# Must be last.
source "${ZSH}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Must be laster.
source "${ZSH}/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

[[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up    # Up
[[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down  # Down
