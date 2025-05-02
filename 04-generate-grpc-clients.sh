#!/bin/bash
set -e
set -o pipefail
# set -u

echo "--- Generating gRPC Clients from Proto Definitions ---"

PROTO_DIR="src/core/proto"
# Adjust output dir if needed based on actual project structure/config
OUTPUT_DIR="src/core/grpc/generated" # Example output directory

# Check if protoc exists
if ! command -v protoc &> /dev/null; then
    echo "ERROR: protoc command not found. Please install the protobuf compiler."
    echo "See https://grpc.io/docs/protoc-installation/"
    exit 1
fi

# Check if the proto directory exists
if [ ! -d "$PROTO_DIR" ]; then
    echo "ERROR: Proto directory '$PROTO_DIR' not found."
    exit 1
fi

# Check if the protobuf-ts generator plugin is installed (common choice based on docs)
# Adjust the plugin name if using a different generator (@grpc/grpc-js tools, etc.)
PLUGIN_NAME="protoc-gen-ts"
PLUGIN_PATH=$(pnpm bin)/$PLUGIN_NAME # Adjust if plugin is installed globally or differently
if ! command -v "$PLUGIN_PATH" &> /dev/null; then
   echo "ERROR: gRPC TypeScript generator plugin ('$PLUGIN_NAME') not found."
   echo "Ensure 'protobuf-ts' (or your chosen generator) is installed (likely in devDependencies)."
   echo "Attempted path: $PLUGIN_PATH"
   exit 1
fi
echo "Using plugin: $PLUGIN_PATH"


# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Finding .proto files in $PROTO_DIR..."
# Find all .proto files and execute protoc
# Adjust protoc flags based on your specific generator and needs
# This example uses protobuf-ts flags. Modify if using grpc-web or @grpc/grpc-js generators.
find "$PROTO_DIR" -name "*.proto" -print0 | while IFS= read -r -d $'\0' proto_file; do
    echo "Processing: $proto_file"
    protoc \
        --plugin="protoc-gen-ts=${PLUGIN_PATH}" \
        --ts_out "${OUTPUT_DIR}" \
        --proto_path "${PROTO_DIR}" \
        "$proto_file"
    # Add other generator flags if needed (e.g., --js_out, --grpc-web_out)
done

echo "--- gRPC Client generation completed successfully ---"
exit 0