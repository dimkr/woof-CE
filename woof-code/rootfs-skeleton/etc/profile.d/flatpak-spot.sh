command -v flatpak > /dev/null && export XDG_DATA_DIRS=$XDG_DATA_DIRS:`run-as-spot sh -c 'echo $XDG_DATA_HOME/flatpak/exports/share'`
