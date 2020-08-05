INSTALL_DIR=~/bin
BIN_NAME=asset-import
BUILD_DIR=.build
BUILD_PATH=$(BUILD_DIR)/release/$(BIN_NAME)

all: build install

test:
	@swift test

build:
	@swift build -c release

install:
	@cp -p  $(BUILD_PATH) $(INSTALL_DIR)/$(BIN_NAME)

clean:
	@rm -rf $(BUILD_DIR)

format:
	@swiftformat .
	@swiftlint autocorrect
	@swiftlint
