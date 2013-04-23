_homebrew-installed() {
  type brew &> /dev/null
}

_rbenv-from-homebrew-installed() {
  brew --prefix rbenv &> /dev/null
}

export FOUND_RBENV=0
if _homebrew-installed && _rbenv-from-homebrew-installed ; then
    rbenvdirs=($(brew --prefix rbenv) "${rbenvdirs[@]}")
fi

rbenvdirs=("$HOME/.rbenv")

for rbenvdir in "${rbenvdirs[@]}" ; do
  if [ -d $rbenvdir/bin -a $FOUND_RBENV -eq 0 ] ; then
    export FOUND_RBENV=1
    export RBENV_ROOT=$rbenvdir
    export PATH=${rbenvdir}/bin:$PATH
    eval "$(rbenv init - zsh)"

    alias rubies="rbenv versions"
    alias gemsets="rbenv gemset list"

    function current_ruby() {
      echo "$(rbenv version-name)"
    }

    function current_gemset() {
      echo "$(rbenv gemset active 2>/dev/null | sed -E -n -e "s/^(.*) .+$/\1/" -e p))"
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
  fi
done
unset rbenvdir

if [ $FOUND_RBENV -eq 0 ] ; then
  alias rubies='ruby -v'
  function gemsets() { echo 'not supported' }
  function rbenv_prompt_info() { echo "system: $(ruby -v | cut -f-2 -d ' ')" }
fi
