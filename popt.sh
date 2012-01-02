#!/bin/sh

#
# popt.sh - popt parameter aliasing emulation in sh
#
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42, (c) Poul-Henning Kamp):
# TEUBEL György <tgyurci@freemail.hu> wrote this file. As long as you retain
# this notice you can do whatever you want with this stuff. If we meet some day,
# and you think this stuff is worth it, you can buy me a beer in return. 
#
# TEUBEL György
# ----------------------------------------------------------------------------
#

rev="1"
PREFIX="${PREFIX:-"/usr/local"}"
DEBUG="${DEBUG:-"no"}"

fail() {
	echo "$0:" "$@" >&2
	exit 1
}

case $DEBUG in
	[Yy][Ee][Ss])
		debug() {
			echo $@ >&2
		}
	;;
	[Nn][Oo])
		debug() {
			: # nop
		}
	;;
	*)
		fail "Debug must be yes or no!"
	;;
esac

get_real_cmd() {
	local cmd
	cmd="$1"
	local poptcmd cmdname realcmd

	for poptcmd in "$HOME/.poptcmd" "$PREFIX/etc/poptcmd"; do
		if [ -f "$poptcmd" ]; then
			debug "Parsing $poptcmd"
			while read cmdname realcmd; do
				case "$cmdname" in
					$cmd) # match line
						debug "Found command alias: '$realcmd' for '$cmdname'"
						echo $realcmd
						return 0
					;;
					\#*) # ignoring comment
					;;
					*) # do not match
					;;
				esac
			done <  "$poptcmd"
		fi
	done

	fail "No cmd alias!"
}

get_param_alias() {
	local cmd param 
	cmd="$1"
	param="$2"
	local poptrc cmdname aliasname paramalias expansion

	for poptrc in "$HOME/.popt" "$PREFIX/etc/popt"; do
		if [ -f "$poptrc" ]; then
			debug "Parsing $poptrc"
			while read cmdname aliasname paramalias expansion; do
				case "$cmdname" in
					$cmd) # match line
						[ "$aliasname" = "alias" ] || fail "Second word must be alias: $aliasname"

						if [ "$paramalias" = "$param" ]; then
							debug "Found parameter expansion for $param: $expansion"
							echo "$expansion"
							return 0
						fi
					;;
					\#*) # ignoring comment
					;;
					*) # do not match
					;;
				esac
			done < "$poptrc"
		fi
	done

	# No match, return the passed parameter
	echo "$param"
	return 0
}

cmd="`basename $0`"
realcmd="`get_real_cmd "$cmd"`" || exit 1

debug "Real command: $realcmd"

params=

for param in "$@"; do
	expansion="`get_param_alias "$cmd" "$param"`" || exit 1
	params="$params $expansion"
done

debug "Expanded parameters: $params"

"$realcmd" $params
