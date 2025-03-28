#!/bin/sh -e
#
# 2020-2021 Timothée Floure (timothee.floure at posteo.net)
# 2021 Joachim Desroches (joachim.desroches at epfl.ch)
#
# This file is part of skonfig-extra.
#
# skonfig-extra is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# skonfig-extra is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with skonfig-extra. If not, see <http://www.gnu.org/licenses/>.
#
# Generates a configuration file for unbound(8).
#

cat << EOF
# Configuration file for the ${__object_id:?} unbound(8) instance.
# Generated by cdist. DNE: your changes will be overwritten.
server:
EOF

# Server logging
[ "$VERBOSITY" ] && printf "verbosity: %u\n" "$VERBOSITY"

# IP version
[ "$DISABLE_IPV4" ] && echo "do-ip4: no"
[ "$DISABLE_IPV6" ] && echo "do-ip6: no"

# Interfaces to bind to
[ "$PORT" ] && printf "port: %u\n" "$PORT"
if [ -f "${__object:?}/parameter/interface" ];
then
	while read -r intf;
	do
		printf "interface: %s\n" "$intf"
	done < "${__object:?}/parameter/interface"
fi

[ "$IP_TRANSPARENT" ] && printf "ip-transparent: yes\n"

# Access control
if [ -f "${__object:?}/parameter/access-control" ];
then
	while read -r acl;
	do
		printf "access-control: %s\n" "$acl"
	done < "${__object:?}/parameter/access-control"
fi

# Local data
if [ -f "${__object:?}/parameter/local-data" ];
then
	while read -r data;
	do
		printf "local-data: \"%s\"\n" "$data"
	done < "${__object:?}/parameter/local-data"
fi

# DNS64
printf "module-config: \"%svalidator iterator\"\n" "${DNS64:+dns64 }"
[ "$PREFIX64" ] && printf "dns64-prefix: %s\n" "$PREFIX64"

# Remote control
echo "remote-control:"
[ "$ENABLE_RC" ] && echo "control-enable: yes"
[ "$CONTROL_PORT" ] && printf "control-port: %u\n" "$CONTROL_PORT"

if [ "$CONTROL_USE_CERTS" ];
then
	printf "server-key-file: %s\n"   "${RC_SERVER_KEY_FILE:?}"
	printf "server-cert-file: %s\n"  "${RC_SERVER_CERT_FILE:?}"
	printf "control-key-file: %s\n"  "${RC_CONTROL_KEY_FILE:?}"
	printf "control-cert-file: %s\n" "${RC_CONTROL_CERT_FILE:?}"
fi

if [ -f "${__object:?}/parameter/control-interface" ];
then
	while read -r acl;
	do
		printf "control-interface: %s\n" "$acl"
	done < "${__object:?}/parameter/control-interface"
fi

# Forwarding recursive queries
if [ -f "${__object:?}/parameter/forward-zone" ];
then
	while read -r fdzne
	do
		printf "forward-zone:\n"
		printf "name: %s\n" "$(echo "$fdzne" | cut -f1 -d',')"
		echo "$fdzne" | cut -f 2- -d',' | tr ',' '\n' | while read -r addr;
		do
			printf "forward-addr: %s\n" "$addr"
		done
	done < "${__object:?}/parameter/forward-zone";
fi
