# Runs the commands configured in the GitHub runner for each push

if ! command -v xcbeautify &> /dev/null
then
    echo "xcbeautify could not be found."
    echo "Please install xcbeautify using Homebrew by running the following command:"
    echo "brew install xcbeautify"
    exit 1
fi

set -o pipefail && xcodebuild build -scheme "APIClient" -destination "OS=16.4,name=iPhone 14 Pro" -skipPackagePluginValidation | xcbeautify
set -o pipefail && xcodebuild build -scheme "APIClient" -destination "platform=macOS,arch=arm64" -skipPackagePluginValidation | xcbeautify
