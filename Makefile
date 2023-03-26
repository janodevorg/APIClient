#!/bin/bash -e -o pipefail

.PHONY: build docc requirebrew requirejq

test:
	set -o pipefail && xcodebuild test -scheme "APIClient-Package" -destination "OS=16.2,name=iPhone 14 Pro" -skipPackagePluginValidation | xcpretty
	set -o pipefail && xcodebuild test -scheme "APIClient-Package" -destination "platform=macOS,arch=arm64" -skipPackagePluginValidation | xcpretty
	set -o pipefail && xcodebuild test -scheme "APIClient-Package" -destination "platform=macOS,arch=arm64,variant=Mac Catalyst" -skipPackagePluginValidation | xcpretty
	set -o pipefail && xcodebuild test -scheme "APIClient-Package" -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)" -skipPackagePluginValidation | xcpretty

docc: requirejq
	rm -rf docs
	swift build
	DOCC_JSON_PRETTYPRINT=YES
	swift package \
 	--allow-writing-to-directory ./docs \
	generate-documentation \
 	--target APIClient \
 	--output-path ./docs \
 	--transform-for-static-hosting \
 	--hosting-base-path APIClient \
	--emit-digest
	cat docs/linkable-entities.json | jq '.[].referenceURL' -r | sort > docs/all_identifiers.txt
	sort docs/all_identifiers.txt | sed -e "s/doc:\/\/APIClient\/documentation\\///g" | sed -e "s/^/- \`\`/g" | sed -e 's/$$/``/g' > docs/all_symbols.txt
	@echo "Check https://janodevorg.github.io/APIClient/documentation/apiclient/"
	@echo ""

requirebrew:
	@if ! command -v brew &> /dev/null; then echo "Please install brew from https://brew.sh/"; exit 1; fi

requirejq: requirebrew
	@if ! command -v jq &> /dev/null; then echo "Please install jq using 'brew install jq'"; exit 1; fi
