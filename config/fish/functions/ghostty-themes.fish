function ghostty-themes --description 'Live-preview Ghostty themes with fzf; Enter saves, Esc reverts'
    set -l dir /Applications/Ghostty.app/Contents/Resources/ghostty/themes
    set -l config ~/.config/ghostty/config
    set -l reset '\e]104\a\e]110\a\e]111\a\e]112\a'

    switch "$argv[1]"
        case --apply
            while read -l line
                set -l kv (string split -m1 = -- $line | string trim)
                switch $kv[1]
                    case palette
                        printf '\e]4;%s;%s\a' (string split -m1 = -- $kv[2])
                    case foreground
                        printf '\e]10;%s\a' $kv[2]
                    case background
                        printf '\e]11;%s\a' $kv[2]
                    case cursor-color
                        printf '\e]12;%s\a' $kv[2]
                end
            end <$dir/$argv[2] >/dev/tty
            return
        case --sample
            for i in (seq 0 15)
                printf '\e[48;5;%sm  %2s  \e[0m' $i $i
                test $i = 7; and echo
            end
            printf '\n\n\e[1;34m~/projects/app\e[0m on \e[35m main\e[0m \e[31m!2\e[0m \e[32m+1\e[0m\n'
            printf '\e[32m+ fun answer() = 42\e[0m\n\e[31m- fun answer() = 41\e[0m\n'
            printf '\e[33mwarning:\e[0m unused variable \e[36m`x`\e[0m\n\e[2m// dim comment\e[0m\n'
            return
    end

    set -l themes 'Kanagawa Wave' 'Kanagawa Dragon' 'Rose Pine Moon' 'Selenized Dark' \
        'Everforest Dark Hard' 'Gruvbox Material Dark' Nightfox Carbonfox 'JetBrains Darcula' \
        'TokyoNight Moon' 'TokyoNight Storm' 'Catppuccin Macchiato' 'Catppuccin Frappe' \
        Vesper 'Cursor Dark' 'No Clown Fiesta' Mellifluous 'Melange Dark' 'Kanso Zen' Vague \
        'Black Metal (Gorgoroth)' 'Black Metal (Mayhem)' 'Black Metal (Bathory)' Kanagawabones

    set -l choice (printf '%s\n' $themes | fzf --with-shell 'fish -c' --no-sort --prompt 'theme> ' \
        --preview 'ghostty-themes --sample' --preview-window right,50%,border-left \
        --bind 'focus:execute-silent(ghostty-themes --apply {})')

    if test -z "$choice"
        printf $reset
        return 1
    end

    set -l lines (string replace -r '^theme\s*=.*' "theme = $choice" <$config)
    contains -- "theme = $choice" $lines; or set -a lines "theme = $choice"
    printf '%s\n' $lines >$config
    echo "theme = $choice saved. Reload other windows with Cmd+Shift+,"
end
