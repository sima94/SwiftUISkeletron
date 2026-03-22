# SwiftUISkeletron — CLI Build Wrapper
# Use these targets instead of calling xcodebuild directly.

PROJECT       = SwiftUISkeletron.xcodeproj
SCHEME_PROD   = SwiftUISkeletron Prod
SCHEME_TEST   = SwiftUISkeletron Test
SCHEME_UITEST = SwiftUISkeletron UITests
TESTPLAN      = SwiftUISkeletron
SIMULATOR     = iPhone 17 Pro
PLATFORM      = iOS Simulator
PKG_SCHEMES   = Infuse NetworkRelay FormValidator

# Per-directory DerivedData for worktree isolation
DERIVED_DATA ?= $(shell pwd)/DerivedData

RESULT_BUNDLE   = $(DERIVED_DATA)/TestResults.xcresult
SCREENSHOTS_DIR = $(DERIVED_DATA)/Screenshots
VIDEO_DIR       = $(DERIVED_DATA)/Videos
SIM_UDID        = $(shell xcrun simctl list devices booted -j | python3 -c "import sys,json; devs=[d for r in json.load(sys.stdin)['devices'].values() for d in r if d['state']=='Booted']; print(devs[0]['udid'] if devs else '')" 2>/dev/null)

.PHONY: build test test-packages test-coverage test-ui test-ui-record test-ui-screenshots clean resolve format lint open

## Build the Prod scheme
build:
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME_PROD)" \
		-destination 'platform=$(PLATFORM),name=$(SIMULATOR)' \
		-derivedDataPath "$(DERIVED_DATA)" \
		-quiet \
		build

## Run all tests (app + local packages)
test:
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME_TEST)" \
		-destination 'platform=$(PLATFORM),name=$(SIMULATOR)' \
		-derivedDataPath "$(DERIVED_DATA)" \
		-testPlan "$(TESTPLAN)" \
		test
	@for pkg in $(PKG_SCHEMES); do \
		echo "\n🧪 Testing $$pkg..."; \
		cd "$(CURDIR)/$$pkg" && swift test --quiet || exit 1; \
	done
	@echo "\n✅ All tests passed (app + packages)."

## Run only local package tests (Infuse, NetworkRelay, FormValidator)
test-packages:
	@for pkg in $(PKG_SCHEMES); do \
		echo "\n🧪 Testing $$pkg..."; \
		cd "$(CURDIR)/$$pkg" && swift test --quiet || exit 1; \
	done
	@echo "\n✅ All package tests passed."

## Run all tests with code coverage and print report
test-coverage:
	@rm -rf "$(RESULT_BUNDLE)"
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME_TEST)" \
		-destination 'platform=$(PLATFORM),name=$(SIMULATOR)' \
		-derivedDataPath "$(DERIVED_DATA)" \
		-testPlan "$(TESTPLAN)" \
		-enableCodeCoverage YES \
		-resultBundlePath "$(RESULT_BUNDLE)" \
		test
	@echo "\n📊 Code Coverage Report:\n"
	@xcrun xccov view --report --only-targets "$(RESULT_BUNDLE)"

## Run UI tests with xcresult bundle for failure screenshots
test-ui:
	@rm -rf "$(RESULT_BUNDLE)"
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME_UITEST)" \
		-destination 'platform=$(PLATFORM),name=$(SIMULATOR)' \
		-derivedDataPath "$(DERIVED_DATA)" \
		-resultBundlePath "$(RESULT_BUNDLE)" \
		test; \
	STATUS=$$?; \
	if [ $$STATUS -ne 0 ]; then \
		echo "\n⚠️  UI tests failed. Extracting screenshots..."; \
		$(MAKE) test-ui-screenshots; \
	fi; \
	exit $$STATUS

## Run UI tests with video recording
test-ui-record:
	@rm -rf "$(RESULT_BUNDLE)"
	@mkdir -p "$(VIDEO_DIR)"
	@echo "📹 Starting video recording..."
	@xcrun simctl io booted recordVideo "$(VIDEO_DIR)/ui_test_run.mp4" &
	@sleep 1
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME_UITEST)" \
		-destination 'platform=$(PLATFORM),name=$(SIMULATOR)' \
		-derivedDataPath "$(DERIVED_DATA)" \
		-resultBundlePath "$(RESULT_BUNDLE)" \
		test; \
	STATUS=$$?; \
	kill %1 2>/dev/null || true; \
	sleep 1; \
	echo "📹 Video saved: $(VIDEO_DIR)/ui_test_run.mp4"; \
	if [ $$STATUS -ne 0 ]; then \
		echo "\n⚠️  UI tests failed. Extracting screenshots..."; \
		$(MAKE) test-ui-screenshots; \
		echo "\n📹 Extracting video frames..."; \
		$(MAKE) test-ui-frames; \
	fi; \
	exit $$STATUS

## Extract failure screenshots from xcresult bundle
test-ui-screenshots:
	@mkdir -p "$(SCREENSHOTS_DIR)"
	@if [ -d "$(RESULT_BUNDLE)" ]; then \
		echo "📸 Extracting from: $(RESULT_BUNDLE)"; \
		xcrun xcresulttool get test-results tests \
			--path "$(RESULT_BUNDLE)" \
			--format json 2>/dev/null | \
		python3 -c " \
import sys, json; \
data = json.load(sys.stdin); \
def walk(node, path=''): \
    if isinstance(node, dict): \
        if node.get('testStatus') == 'Failure': \
            print(f'FAILED: {path}/{node.get(\"name\",\"\")}'); \
        for k, v in node.items(): \
            walk(v, f'{path}/{node.get(\"name\",k)}' if k in ('subtests','children') else path); \
    elif isinstance(node, list): \
        for item in node: walk(item, path); \
walk(data)" 2>/dev/null || true; \
		xcrun xcresulttool export \
			--path "$(RESULT_BUNDLE)" \
			--output-path "$(SCREENSHOTS_DIR)" \
			--type attachments 2>/dev/null && \
		echo "📸 Screenshots saved to: $(SCREENSHOTS_DIR)" || \
		echo "📸 No attachments found in xcresult"; \
	else \
		echo "⚠️  No xcresult bundle found at $(RESULT_BUNDLE)"; \
	fi

## Extract frames from recorded video (requires ffmpeg: brew install ffmpeg)
test-ui-frames:
	@if [ -f "$(VIDEO_DIR)/ui_test_run.mp4" ]; then \
		mkdir -p "$(VIDEO_DIR)/frames"; \
		if command -v ffmpeg >/dev/null 2>&1; then \
			ffmpeg -i "$(VIDEO_DIR)/ui_test_run.mp4" \
				-vf "fps=1" \
				"$(VIDEO_DIR)/frames/frame_%03d.png" \
				-y -loglevel warning; \
			echo "🎞️  Frames saved to: $(VIDEO_DIR)/frames/"; \
		else \
			echo "⚠️  ffmpeg not found. Install with: brew install ffmpeg"; \
		fi; \
	else \
		echo "⚠️  No video found. Run 'make test-ui-record' first."; \
	fi

## Clean build artifacts
clean:
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME_PROD)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		clean
	rm -rf "$(DERIVED_DATA)"

## Resolve dependencies (no-op, all packages are local)
resolve:
	@echo "All packages (Infuse, NetworkRelay, FormValidator) are local — no resolution needed."

## Format Swift files (requires: brew install swiftformat)
format:
	swiftformat . --config .swiftformat

## Lint Swift files (requires: brew install swiftlint)
lint:
	swiftlint lint --config .swiftlint.yml

## Open the project in Xcode
open:
	open "$(PROJECT)"
