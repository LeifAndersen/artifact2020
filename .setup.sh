#!/usr/bin/env bash

# Force update THIS repo
rm -rf ~/Desktop/examples
pushd ~/Desktop
git clone git://github.com/LeifAndersen/artifact2020.git examples
popd

# Update the interactive-syntax repo
pushd ~/Desktop/interactive-syntax
git pull
raco setup
popd

# Build the Readme File
rm -rf ~/Desktop/.README
mkdir -p ~/Desktop/.README
cp ~/Desktop/examples/.README.scrbl ~/Desktop/.README/README.scrbl
pushd ~/Desktop/.README
scribble README.scrbl
popd
echo '#!/usr/bin/env bash
epiphany ~/Desktop/.README/README.html' > ~/Desktop/README
chmod +x ~/Desktop/README

# Copy the paper to the desktop
cp ~/Desktop/examples/.paper.pdf ~/Desktop/paper.pdf

# Copy the test-all script
cp ~/Desktop/examples/.test-all.sh ~/Desktop/test-all.sh
chmod +x ~/Desktop/test-all.sh

# Run each file
~/Desktop/test-all.sh
