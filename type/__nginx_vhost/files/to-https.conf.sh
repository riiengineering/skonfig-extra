#!/bin/sh
#
# 2021 Timothée Floure (timothee.floure at posteo.net)
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
# Template for HTTPS redirection.
#

echo 'server {'

# Listen
cat <<- EOF
	listen ${LPORT:?};
	listen [::]:${LPORT:?};
EOF

# Name
echo "server_name ${DOMAIN:?} $ALTDOMAINS;"

# ACME challenges.
cat << EOF
location /.well-known/acme-challenge/ {
	alias ${ACME_CHALLENGE_DIR:?};
}
EOF

# HTTPS redirection.
echo 'include snippets/301-to-https;'

echo '}'
