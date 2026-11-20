function wargrid-playtests --description 'Copy filed Wargrid playtest sessions into the playtest inbox'
  set -l inbox ~/projects/wargrid-playtests
  set -l desktop ~/Library/Application\ Support/Godot/app_userdata/Wargrid/playtests
  mkdir -p $inbox
  # Desktop builds file into user://playtests; skip the open sitting and the web backups.
  if test -d $desktop
    rsync -a --ignore-existing --itemize-changes --include='session-*.json' --exclude='*' $desktop/ $inbox/
  end
  # Web builds download into ~/Downloads; browser-renamed duplicates ("… (1).json") are skipped.
  set -l downloads ~/Downloads/session-*.json
  set downloads (string match -v -r ' \(\d+\)\.json$' -- $downloads)
  if test (count $downloads) -gt 0
    rsync -a --ignore-existing --itemize-changes $downloads $inbox/
  end
end
