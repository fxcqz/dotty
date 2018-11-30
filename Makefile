all: build

build:
	nim c --noMain -d:release --app:staticlib source/plugins/bash.nim
	dub build

run: build
	./dotty

.PHONY: all build run
