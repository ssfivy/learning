#!/bin/bash

# Run the mmdc command line against our README

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))

cd "$THIS_SCRIPT_DIR"

time ./node_modules/.bin/mmdc -i flowchart.mmd -o flowchart.svg
time ./node_modules/.bin/mmdc -i sequence.mmd -o sequence.pdf -t forest
time ./node_modules/.bin/mmdc -i gantt.mmd -o gannt.png -b transparent

# These fails and halts but does not exit the program
#time ./node_modules/.bin/mmdc -i README.md -o README.png || echo "mermaid-cli unable to process mixed content"
#time ./node_modules/.bin/mmdc -i multiple.mmd -o multiple.png || echo "mermaid-cli unable to process multiple graphs"
