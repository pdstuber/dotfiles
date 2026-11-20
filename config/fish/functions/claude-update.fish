function claude-update
  claude plugin marketplace update
  for id in (claude plugin list --json | jq -r '.[].id')
    claude plugin update $id
  end
  if contains -- --skills $argv
    npx skills@latest update -g
  end
end
