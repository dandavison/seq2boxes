.PHONY: all build samples clean serve help

# Default target
all: build samples

# Build the seq2boxes tool
build:
	@echo "Building seq2boxes..."
	go build -o seq2boxes

# Build all samples
samples: build
	@echo "Building all samples..."
	@chmod +x samples/*/build.sh 2>/dev/null || true
	@for dir in samples/*/; do \
		if [ -f "$$dir/build.sh" ]; then \
			echo "Building $$dir..."; \
			(cd "$$dir" && ./build.sh) || exit 1; \
		fi \
	done
	@echo "All samples built successfully!"
	@echo ""
	@echo "To view the samples, open samples/index.html in your browser."
	@echo "For local development, you can run 'make serve' to start a local server."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f seq2boxes
	@for dir in samples/*/; do \
		if [ -d "$$dir/build" ]; then \
			echo "Cleaning $$dir/build..."; \
			rm -rf "$$dir/build"; \
		fi; \
		rm -f "$$dir/index.html" 2>/dev/null || true; \
	done
	@echo "Clean complete."

# Serve samples locally
serve:
	@echo "Starting local server at http://localhost:8000/samples/"
	@echo "Press Ctrl+C to stop the server."
	@cd samples && python3 -m http.server 8000

# Help target
help:
	@echo "seq2boxes Makefile targets:"
	@echo "  make         - Build tool and all samples (default)"
	@echo "  make build   - Build only the seq2boxes tool"
	@echo "  make samples - Build all sample outputs"
	@echo "  make clean   - Remove all build artifacts"
	@echo "  make serve   - Start local server to view samples"
	@echo "  make help    - Show this help message"
