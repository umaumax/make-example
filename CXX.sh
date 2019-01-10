#!/usr/bin/env bash

OUTPUT_WD=${1:-$PWD}
shift 1
CXX=${1:-c++}
shift 1

function main() {
	local cmd="$CXX $*"
	local output_filepath=$(echo "$cmd" | grep -E -o ' *\-o *[~/a-zA-Z0-9\-_.]*' | sed 's/ *-o *//g')
	[[ -z $output_filepath ]] && return # NOTE: no -o option
	local asmcmd=$(echo "$cmd" | sed -E 's: *-o *[~/a-zA-Z0-9\-_.]*::')" -S -o $output_filepath.asm"
	local output_filename=$(basename $output_filepath)
	echo "echo '$output_filename:'; pushd $PWD >/dev/null 2>&1; $asmcmd; popd >/dev/null 2>&1" | tee -a $OUTPUT_WD/make.asm.sh
	eval "$cmd"
	return
}

main "$@"
exit $?
