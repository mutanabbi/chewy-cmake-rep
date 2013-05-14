#!/bin/sh
#
# Copyright 2013 by Alex Turbov <i.zaufi@gmail.com>
#
# Process `Doxyfile` and output a CMake template (Doxyfile.in)
# and extracted defaults to DoxygenDefaults.cmake
#

defaults_file=DoxygenDefaults.cmake
template_file=Doxyfile.in
input_file=$1

# Get Gentoo style spam functions
test -f /etc/init.d/functions.sh && source /etc/init.d/functions.sh

if [ -z "${input_file}" ]; then
    input_file=Doxyfile
fi

if [ ! -f "${input_file}" ]; then
    eerror "Bad input file: ${input_file}"
    exit 1
fi

# Extract defaults first
ebegin "Generate defaults to \`${defaults_file}'"
cat <<EOF >${defaults_file}
#
# DO NOT EDIT!
#
# This file was generated by $0 from ${input_file}
#
# Date: `LC_ALL=C date`
#
EOF

cat ${input_file} \
  | egrep '^[A-Z][A-Z0-9_]+\s+=\s*[^ ]+' \
  | grep -v '\\$' \
  | sed 's,^\([A-Z][A-Z0-9_]\+\)\s\+=\s*\(.\+\),if(NOT DEFINED DOXYGEN_\1)\n    set(DOXYGEN_\1 \2)\nendif(),' \
  | sed -e 's,","\\",' -e 's,"),\\""),' \
  >> ${defaults_file}
eend $?
einfo "`grep 'set(DOXYGEN_' ${defaults_file} | wc -l` default settings collected"

# Transform input file into template
ebegin "Turn \`${input_file}' into template \`${template_file}'"
cat <<EOF >${template_file}
#
# DO NOT EDIT!
#
# This file was turned into template by $0 from ${input_file}
#
# Date: `LC_ALL=C date`
#
EOF
cat ${input_file} \
  | sed 's,^\([A-Z][A-Z0-9_]\+\)\(\s\+=\)\s*\([^\\]\+\)$,\1\2 @DOXYGEN_\1@,' \
  >>${template_file}
eend $?