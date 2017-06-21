
# /usr/sbin/policy-rc.d [options] <initscript ID> <actions> [<runlevel>]
# /usr/sbin/policy-rc.d [options] --list <initscript ID> [<runlevel> ...]

# During the initial chroot install, we do not want any services to be started
echo "policy-rc.d: DENY $*" >&2
exit 101
