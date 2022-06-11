#!/bin/bash
set -eu

GR='\033[0;32m'
NC='\033[0m'

# echo ""
# echo -e "${GR}usage: ./insall-deps.sh${NC}"
# echo ""

echo -e "${GR}Unpacking and installing TreeShrink${NC}"
unzip deps/TreeShrink.zip -d deps > /dev/null 
cd deps/TreeShrink-master
/usr/bin/python3.8 setup.py install --user > /dev/null
cd ../.. && ln -s deps/TreeShrink-master/run_treeshrink.py .

echo -e "${GR}Unpacking and installing pal2nal${NC}"
tar xzvf deps/pal2nal.v14.tar.gz -C deps > /dev/null
ln -s deps/pal2nal.v14/pal2nal.pl .

echo -e "${GR}Unpacking and installing TransDecoder${NC}"
unzip deps/TransDecoder-v5.0.2.zip -d deps > /dev/null
ln -s deps/TransDecoder-TransDecoder-v5.0.2/TransDecoder.LongOrfs .
ln -s deps/TransDecoder-TransDecoder-v5.0.2/TransDecoder.Predict .

echo -e "${GR}Unpacking and installing trimal${NC}"
tar xzvf deps/trimal.v1.2rev59.tar.gz -C deps > /dev/null
cd deps/trimAl/source && make > /dev/null
cd ../../../ && ln -s deps/trimAl/source/trimal .

echo -e "${GR}Unpacking and installing ripgrep${NC}"
tar xzvf deps/ripgrep-0.7.1-x86_64-unknown-linux-musl.tar.gz -C deps > /dev/null
ln -s deps/ripgrep-0.7.1-x86_64-unknown-linux-musl/rg .

# echo -e "${GR}Installing macse${NC}"
# ln -s deps/macse_v2.05.jar .

echo -e "${GR}Done.${NC}"