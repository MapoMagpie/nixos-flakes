function yy() {
	local cwd_file="/tmp/yazi-cwd.txt"
	# local cho_file="/tmp/yazi-cho.txt"
	echo "" >$cwd_file
	# echo "" >$cho_file
	# yazi "$@" --cwd-file="$cwd_file" --cho-file="$cho_file"
	# yazi "$@" --cwd-file="$cwd_file" --chooser-file="$cho_file"
	yazi "$@" --cwd-file="$cwd_file"
	# export fx=$(cat -- "$cho_file")
	if cwd="$(cat -- "$cwd_file")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
}
