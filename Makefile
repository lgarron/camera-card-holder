.PHONY: build
build: bun-install
	openscad-auto --output-dir dist ./*.scad

.PHONY: build-for-publish
build-for-publish: clean
	openscad-auto --variants "unengraved,CFExpress-B.unengraved,6-slots.unengraved,CFExpress-B.6-slots.unengraved,8-slots.unengraved,CFExpress-B.8-slots.unengraved --output-dir dist ./*.scad

.PHONY: setup
setup: bun-install

.PHONY: bun-install
bun-install:
	bun install --no-save

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
