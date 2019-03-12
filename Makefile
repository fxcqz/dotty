all: build

build:
	nim c --noMain -d:ssl --app:staticlib source/plugins/nimplug.nim
	dub build

release:
	nim c --noMain -d:ssl -d:release --app:staticlib source/plugins/nimplug.nim
	dub build -b release
	strip dotty

run: build
	./dotty

.PHONY: all build run release
