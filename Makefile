all: build

build:
	nim c --noMain -d:release --app:staticlib source/plugins/bash.nim
	dub build

release:
	nim c --noMain -d:release --app:staticlib source/plugins/bash.nim
	dub build -b release

run: build
	./dotty

.PHONY: all build run release
