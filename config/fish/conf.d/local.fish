# Machine-specific fish config from the gitignored ~/dotfiles/local/.
set -l dir (path resolve (status dirname)/../../../local/fish)
test -d $dir/functions; and set -p fish_function_path $dir/functions
for f in $dir/conf.d/*.fish
    source $f
end
