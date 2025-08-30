.PHONY: all build samples clean help

# Default target
all: build samples

# Build the seq2boxes tool
build:
	@echo "Building seq2boxes..."
	go build -o seq2boxes

# Build all samples
samples: build
	@echo "Building all samples..."
	@for dir in samples/*/; do \
		if [ -f "$$dir/build.sh" ]; then \
			echo "Building $$dir..."; \
			(cd "$$dir" && ./build.sh) || exit 1; \
		fi \
	done
	@echo "All samples built successfully!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f seq2boxes
	@for dir in samples/*/; do \
		if [ -d "$$dir/build" ]; then \
			echo "Cleaning $$dir/build..."; \
			rm -rf "$$dir/build"; \
		fi \
	done
	@echo "Clean complete."

# Help target
help:
	@echo "seq2boxes Makefile targets:"
	@echo "  make         - Build tool and all samples (default)"
	@echo "  make build   - Build only the seq2boxes tool"
	@echo "  make samples - Build all sample outputs"
	@echo "  make clean   - Remove all build artifacts"
	@echo "  make help    - Show this help message"
