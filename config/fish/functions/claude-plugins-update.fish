function claude-plugins-update
  claude plugin marketplace update
  for id in (claude plugin list --json | jq -r '.[].id')
    claude plugin update $id
  end
end
