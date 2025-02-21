MOD = graphlib

NPM = npm
BROWSERIFY = ./node_modules/browserify/bin/cmd.js
ISTANBUL = ./node_modules/istanbul/lib/cli.js
KARMA = ./node_modules/karma/bin/karma
MOCHA = ./node_modules/mocha/bin/_mocha
UGLIFY = ./node_modules/uglify-es/bin/uglifyjs

ISTANBUL_OPTS = --dir $(COVERAGE_DIR) --report html
MOCHA_OPTS = -R dot

BUILD_DIR = build
COVERAGE_DIR = $(BUILD_DIR)/cov
DIST_DIR = dist

SRC_FILES = lib/index.js $(shell find lib -type f -name '*.js')
TEST_FILES = $(shell find test -type f -name '*.js' | grep -v 'bundle-test.js' | grep -v 'bundle.amd-test.js' | grep -v 'test-main.js')
BUILD_FILES = $(addprefix $(BUILD_DIR)/, \
						$(MOD).js $(MOD).min.js \
						$(MOD).core.js $(MOD).core.min.js)

DIRS = $(BUILD_DIR)

.PHONY: all bench clean browser-test unit-test test dist

all: unit-test

bench: test
	@src/bench.js

$(DIRS):
	@mkdir -p $@

test: unit-test browser-test browser-test-amd

unit-test: $(SRC_FILES) $(TEST_FILES) node_modules | $(BUILD_DIR)
	@$(ISTANBUL) cover $(ISTANBUL_OPTS) $(MOCHA) --dir $(COVERAGE_DIR) -- $(MOCHA_OPTS) $(TEST_FILES) || $(MOCHA) $(MOCHA_OPTS) $(TEST_FILES)

browser-test: $(BUILD_DIR)/$(MOD).js $(BUILD_DIR)/$(MOD).core.js
	$(KARMA) start --single-run $(KARMA_OPTS)
	$(KARMA) start karma.core.conf.js --single-run $(KARMA_OPTS)

browser-test-amd: $(BUILD_DIR)/$(MOD).js $(BUILD_DIR)/$(MOD).core.js
	$(KARMA) start karma.amd.conf.js --single-run $(KARMA_OPTS)

$(BUILD_DIR)/$(MOD).js: lib/index.js $(SRC_FILES) | unit-test
	@$(BROWSERIFY) $< > $@ -s graphlib

$(BUILD_DIR)/$(MOD).min.js: $(BUILD_DIR)/$(MOD).js
	@$(UGLIFY) --ecma=6 $< --comments '@license' > $@

$(BUILD_DIR)/$(MOD).core.js: lib/index.js $(SRC_FILES) | unit-test
	@$(BROWSERIFY) $< > $@ --no-bundle-external -s graphlib

$(BUILD_DIR)/$(MOD).core.min.js: $(BUILD_DIR)/$(MOD).core.js
	@$(UGLIFY) --ecma=6 $< --comments '@license' > $@

dist: test
	@rm -rf $@
	npm run build

release: dist
	@echo
	@echo Starting release...
	@echo
	@src/release/release.sh $(MOD) dist

clean:
	rm -rf $(BUILD_DIR)

node_modules: package.json
	@$(NPM) install
	@touch $@
