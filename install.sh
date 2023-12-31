#!/usr/bin/env sh
brew install go
go install foosoft.net/projects/homemaker@latest
homemaker --verbose homemaker.toml .