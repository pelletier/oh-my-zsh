_homebrew-installed() {
  type brew &> /dev/null
}

_rbenv-from-homebrew-installed() {
  brew --prefix rbenv &> /dev/null
}

if _homebrew-installed && _rbenv-from-homebrew-installed ; then
    rbenvdirs=($(brew --prefix rbenv) "${rbenvdirs[@]}")
fi



# Don't try to find rbenv if it's not installed or has already been set up.
if [ -z "$FOUND_RBENV" -a "xxx$FOUND_RBENV" = "xxx" ]; then

    # Check if Rbenv is already available in the PATH
    if which rbenv > /dev/null; then
        export FOUND_RBENV=1
    else
        rbenvdirs=("$HOME/.rbenv")
        for rbenvdir in "${rbenvdirs[@]}" ; do
            if [ -d $rbenvdir/bin -a $FOUND_RBENV -eq 0 ] ; then
                export FOUND_RBENV=1
                export RBENV_ROOT=$rbenvdir
                export PATH=${rbenvdir}/bin:$PATH
            fi
        done
    fi

    if [ $FOUND_RBENV -eq 1 ]; then
        eval "$(rbenv init - zsh)"

        alias rubies="rbenv versions"
        alias gemsets="rbenv gemset list"

        function current_ruby() {
            echo "$(rbenv version-name)"
        }

        function current_gemset() {
            echo "$(rbenv gemset active 2>/dev/null | sed -E -n -e "s/^(.*) .+$/\1/" -e p)"
        }

        function gems {
            local rbenv_path=$(rbenv prefix)
            gem list $@ | sed \
                -Ee "s/\([0-9\.]+( .+)?\)/$fg[blue]&$reset_color/g" \
                -Ee "s|$(echo $rbenv_path)|$fg[magenta]\$rbenv_path$reset_color|g" \
                -Ee "s/$current_ruby@global/$fg[yellow]&$reset_color/g" \
                -Ee "s/$current_ruby$current_gemset$/$fg[green]&$reset_color/g"
        }

        function rbenv_prompt_info() {
            if [[ -n $(current_gemset) ]] ; then
                echo "$(current_ruby)@$(current_gemset)"
            else
                echo "$(current_ruby)"
            fi
        }
    else
        export FOUND_RBENV=0
    fi

fi


unset rbenvdir

if [ $FOUND_RBENV -eq 0 ] ; then
  alias rubies='ruby -v'
  function gemsets() { echo 'not supported' }
  function rbenv_prompt_info() { echo "system: $(ruby -v | cut -f-2 -d ' ')" }
fi
