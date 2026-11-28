function tarzst --description "Create a Zstandard-compressed tar archive"
    if test (count $argv) -eq 0
        echo "Usage: tarzst <file or directory>..."
        return 1
    end

    if test (count $argv) -eq 1
        set -l target (path resolve -- "$argv[1]")
        set -f name (path basename -- "$target")
    else
        set -f name (path basename -- "$PWD")-(date +%Y%m%d-%H%M%S)
    end

    set -l archive "$name.tar.zst"

    if test -e "$archive"
        echo "Error: $archive already exists"
        return 1
    end

    echo "Creating $archive..."

    tar --exclude="./$archive" -cf - -- $argv | zstd -T0 -10 -o "$archive"

    if contains -- 1 $pipestatus
        echo "Error: Compression failed"
        return 1
    end
end