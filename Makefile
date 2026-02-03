.PHONY: build install

BIN_DIR ?= /usr/local/bin

build:
	@echo "Building ltxe."
	bash src/bundler.sh

install:
	$(MAKE) build
	@echo "Installing ltxe to $(BIN_DIR)"
	@mkdir -p "$(BIN_DIR)"
	@cp build/ltxe.sh "$(BIN_DIR)/ltxe"
	@chmod +x "$(BIN_DIR)/ltxe"
	@echo "Installation complete. Run 'ltxe' from anywhere."

uninstall:
	@echo "Removing ltxe from $(BIN_DIR)"
	@rm -f "$(BIN_DIR)/ltxe"
	@echo "Uninstall complete."
