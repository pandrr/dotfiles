function git_branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'

}


setopt PROMPT_SUBST



PROMPT='%K{blue} M1 %K{black} %5/$(git_branch) '
#alias python=/opt/homebrew/bin/python3
