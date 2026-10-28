if /usr/libexec/java_home -v 21 &>/dev/null
    set -gx JAVA_HOME (/usr/libexec/java_home -v 21)
end
set -gx ANDROID_HOME $HOME/Library/Android/sdk

fish_add_path $ANDROID_HOME/platform-tools
set -q JAVA_HOME; and fish_add_path $JAVA_HOME/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

type -q fnm; and fnm env --use-on-cd --shell fish | source
