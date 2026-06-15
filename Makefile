.PHONY: build
build: bun-install
	openscad-auto --output-dir dist "./Camera card holder v0.5.5i.bundled.scad"

.PHONY: build-for-publish
build-for-publish: clean
	openscad-auto --output-dir dist "./Camera card holder v0.5.5i.bundled.scad"

.PHONY: setup
setup: bun-install

.PHONY: bun-install
bun-install:
	bun install --frozen-lockfile

.PHONY: publish
publish: build-for-publish
	npm publish

.PHONY: bump-dev
bump-dev:
	bun run ./script/bump-dev.ts

.PHONY: clean
clean:
	rm -rf ./dist

.PHONY: reset
reset: clean
	rm -rf ./node_modules
