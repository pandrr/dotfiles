# local machine
PS1="\[\e[44m\] \u@\h \[\e[m\] \[\e[36m\]\w\[\e[m\] $(git branch 2>/dev/null|cut -f2 -d\* -s | sed "s/^ /[/" | sed "s/$/] /")\[\e[37m\]>\[\e[m\] "

# dev server
PS1="\[\e[42m\] \u@\h \[\e[m\] \[\e[36m\]\w\[\e[m\] $(git branch 2>/dev/null|cut -f2 -d\* -s | sed "s/^ /[/" | sed "s/$/] /")\[\e[37m\]>\[\e[m\] "


# dev server
PS1="\[\e[41m\] \u@\h \[\e[m\] \[\e[36m\]\w\[\e[m\] $(git branch 2>/dev/null|cut -f2 -d\* -s | sed "s/^ /[/" | sed "s/$/] /")\[\e[37m\]>\[\e[m\] "
