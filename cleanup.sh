#!/bin/bash

# Script for cleaning up blockly-specific files when merging blockly into scratch-blocks
# Removes files and directories that scratch-blocks doesn't want.
# Rachel Fenichel (fenichel@google.com)

# Note: 'ours' is scratch-blocks, 'theirs' is blockly.

# Formatting helpers.
indent() { sed 's/^/  /'; }
indent_more() { sed 's/^/\t/'; }
empty_lines() { printf '\n\n'; }


empty_lines
echo Cleaning up a merge from Blockly to Scratch-Blocks...

# Get rid of Blockly's internationalization/messages.  This is not usually worth
# scrolling up to look at.
empty_lines
echo Cleaning up Blockly message files...
# Turn on more powerful globbing
shopt -s extglob

# Having trouble with directories.  Let's just go there.
cd msg/json
git rm -f !(en.json|synonyms.json) | indent_more
cd ../..

# Having trouble with directories.  Let's just go there.
cd msg/js
git rm -f !(en.js) | indent_more
cd ../..

# Turn powerful globbing off again
shopt -u extglob

# Whole directories that we want to get rid of.
empty_lines
echo Removing blockly-specific directories...
dirslist="accessible demos tests/generators appengine blocks local_build"
for directory in $dirslist
do
  echo 'Cleaning up' $directory | indent
  git rm -rf $directory | indent_more
done

# Scratch-blocks keeps the language generators (e.g. dart.js) but does not
# keep generators for each block in each language.
empty_lines
echo Removing generators...
generated_langs="dart javascript lua php python"
for lang in $generated_langs
do
  echo 'Cleaning up' $lang | indent
  # Directories containing block generators.
  git rm -rf generators/${lang} | indent_more
  # Individual generator files.  Use Blockly's.
  git checkout --theirs generators/${lang}.js && git add generators/${lang}.js | indent_more
  git checkout --theirs ${lang}_compressed.js && git add ${lang}_compressed.js | indent_more
done

# Built stuff that we should get rid of.
empty_lines
echo Removing built files...
built_files="blockly_compressed.js \
blockly_uncompressed.js \
blockly_accessible_compressed.js \
blockly_accessible_uncompressed.js \
blocks_compressed.js"

for filename in $built_files
do
  git rm $filename | indent_more
done

empty_lines
echo Miscellaneous cleanup...
# Use ours.
keep_ours=".github/ISSUE_TEMPLATE.md \
.github/PULL_REQUEST_TEMPLATE.md \
.gitignore \
.travis.yml"

for filename in $keep_ours
do
  git checkout --ours $filename && git add $filename | indent_more
done

# Scratch-blocks has separate vertical and horizontal playgrounds and block
# rendering.
git rm -f tests/playground.html core/block_render_svg.js | indent_more

empty_lines
echo Done with cleanup.
