.PHONY: build
build: bun-install
	openscad-auto \
		--variants "unengraved,CFExpress-B.unengraved,6-slots.unengraved,CFExpress-B.6-slots.unengraved,8-slots.unengraved,CFExpress-B.8-slots.unengraved,10-slots.unengraved,CFExpress-B.10-slots.unengraved" \
		--print-commands \
		--output-dir dist \
		./*.scad

.PHONY: build-for-publish
build-for-publish: clean build

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

RM_RF = bun -e 'process.argv.slice(1).map(p => process.getBuiltinModule("node:fs").rmSync(p, {recursive: true, force: true, maxRetries: 5}))' --

.PHONY: clean
clean:
	${RM_RF} ./dist/

.PHONY: reset
reset: clean
	${RM_RF} ./node_modules/
