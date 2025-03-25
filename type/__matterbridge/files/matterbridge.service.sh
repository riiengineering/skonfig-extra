#!/bin/sh
#
# 2020 Timothée Floure (timothee.floure at posteo.net)
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
# Generate the contents of matterbridge.service.
#

cat <<EOF
[Unit]
Description=IM bridging daemon
Wants=network-online.target
After=network-online.target

[Service]
User=${USER}
Group=${GROUP}
Type=simple
Restart=on-failure
ExecStart=${BINARY_PATH} -conf=/etc/matterbridge/matterbridge.toml

[Install]
WantedBy=multi-user.target
EOF
