# Define bin file name
EXE := rp_test

# Build type (debug by default)
BUILD_TYPE ?= debug

# Define compiler and flags
CXX := g++
CXXFLAGS_BASE := -std=c++17

# Debug and Release specific flags
ifeq ($(BUILD_TYPE),debug)
    CXXFLAGS := $(CXXFLAGS_BASE) -Wall -Wextra -Wpedantic -g -O0 -DDEBUG
else ifeq ($(BUILD_TYPE),release)
    CXXFLAGS := $(CXXFLAGS_BASE) -O3 -DNDEBUG
else
    $(error Invalid BUILD_TYPE: $(BUILD_TYPE). Use 'debug' or 'release')
endif

# Define directories
SRC_DIR := src
INCLUDE_DIR := include
LIB_DIR := lib
OUTPUT_DIR := output
BIN_DIR := $(OUTPUT_DIR)
OBJ_DIR := $(OUTPUT_DIR)
DEP_DIR := $(OUTPUT_DIR)

# Final executable name
TARGET := $(BIN_DIR)/$(EXE)

# Find all source files
SRCS := $(wildcard $(SRC_DIR)/*.cpp)
OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))
DEPS := $(patsubst $(SRC_DIR)/%.cpp,$(DEP_DIR)/%.d,$(SRCS))

# Detect OS
UNAME_S := $(shell uname -s)

# OpenCV configuration
ifeq ($(UNAME_S),Linux)
    # Linux-specific OpenCV configuration
    OPENCV_CFLAGS := $(shell pkg-config --cflags opencv4)
    OPENCV_LIBS := $(shell pkg-config --libs opencv4)

    # Architecture-specific flags (uncomment for ARM build)
    # For ARM 64-bit
    CXXFLAGS += -march=armv8-a
    # For ARM 32-bit (uncomment instead if using 32-bit ARM)
    # CXXFLAGS += -march=armv7-a
    
    # If opencv4 is not found, try opencv
    ifeq ($(OPENCV_CFLAGS),)
        OPENCV_CFLAGS := $(shell pkg-config --cflags opencv)
        OPENCV_LIBS := $(shell pkg-config --libs opencv)
    endif
else ifeq ($(UNAME_S),Darwin)
    # macOS-specific OpenCV configuration
    # Try with Homebrew installation first
    OPENCV_CFLAGS := $(shell pkg-config --cflags opencv4 2>/dev/null || echo "-I/usr/local/include/opencv4")
    OPENCV_LIBS := $(shell pkg-config --libs opencv4 2>/dev/null || echo "-L/usr/local/lib -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs")
endif

# Update flags
CXXFLAGS += $(OPENCV_CFLAGS) -I$(INCLUDE_DIR)
LDFLAGS := $(OPENCV_LIBS)

# Default target
all: prepare $(TARGET)

# Debug target
debug:
	@$(MAKE) BUILD_TYPE=debug

# Release target
release:
	@$(MAKE) BUILD_TYPE=release

# Create necessary directories
prepare:
	@mkdir -p $(LIB_DIR) $(OUTPUT_DIR)

# Link the executable
$(TARGET): $(OBJS)
	@echo "Linking $@"
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)
	@echo "\033[32mBuild complete!\033[0m"

# Compile object files and generate dependency files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
    # @echo "Compiling $<"
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@
	@mv $(OBJ_DIR)/$*.d $(DEP_DIR)/$*.d 2>/dev/null || true

# Include dependency files
-include $(DEPS)

# Run the executable
run: all
	@echo "Running $(TARGET) ($(BUILD_TYPE) build)"
	@./$(TARGET)

# Install target (copies the binary to /usr/local/bin or equivalent)
install: all
ifeq ($(UNAME_S),Linux)
	@echo "Installing to /usr/local/bin"
	@sudo install -m 755 $(TARGET) /usr/local/bin/$(notdir $(TARGET))
else ifeq ($(UNAME_S),Darwin)
	@echo "Installing to /usr/local/bin"
	@sudo install -m 755 $(TARGET) /usr/local/bin/$(notdir $(TARGET))
endif
	@echo "Installation complete!"

# Clean object files and dependencies
clean:
	@echo "Cleaning object files and dependencies"
	@rm -f $(OBJ_DIR)/*.o $(DEP_DIR)/*.d

# Clean everything including the executable
distclean: clean
	@echo "Cleaning executable"
	@rm -f $(TARGET)

# Uninstall target
uninstall:
	@echo "Uninstalling from /usr/local/bin"
ifeq ($(UNAME_S),Linux)
	sudo rm -f /usr/local/bin/$(notdir $(TARGET))
else ifeq ($(UNAME_S),Darwin)
	sudo rm -f /usr/local/bin/$(notdir $(TARGET))
endif
	@echo "Uninstallation complete!"

# Phony targets
.PHONY: all prepare run install uninstall clean distclean debug release