git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

# local machine - blue
PS1="\[\e[44m\] \u@\h \[\e[m\] \[\e[37m\]\w\[\e[m\] \$(git_branch)\[\e[37m\]>\[\e[m\] "

# dev server - green
#PS1="\[\e[42m\] \u@\h \[\e[m\] \[\e[37m\]\w\[\e[m\] \$(git_branch)\[\e[37m\]>\[\e[m\] "

# live server - red
#PS1="\[\e[41m\] \u@\h \[\e[m\] \[\e[37m\]\w\[\e[m\] \$(git_branch)\[\e[37m\]>\[\e[m\] "
