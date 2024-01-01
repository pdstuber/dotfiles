#!/usr/bin/env sh
brew install go
go install github.com/pdstuber/homemaker@v1.0.0
homemaker --verbose homemaker.toml .
