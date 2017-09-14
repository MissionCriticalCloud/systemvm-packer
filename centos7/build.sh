#!/bin/bash

set -x

echo "Removing previous artifacts"
rm -rf ./packer_output
echo "Running Packer"
packer build template.json
