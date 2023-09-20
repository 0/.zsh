export TIMEFMT="${TIMEFMT}
space used: %K KB
max memory: %M MB
page faults: %F, %R
context switches: %w, %c"

export EDITOR=vim

export PAGER=less
export LESSHISTFILE=/dev/null

export SUDO_PROMPT='%p to sudo as %U: '

export JULIA_PKG_OFFLINE=true


if [[ -f ~/.zprofile.local ]]; then
	source ~/.zprofile.local
fi
