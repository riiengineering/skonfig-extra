#!/bin/sh
#
# 2020 Timothée Floure (timothee.floure at posteo.net)
# 2020 Matthias Stecher (matthiasstecher at gmx.de)
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
# Generate contents of configuration.py.
#

cat <<EOF
#########################
#                       #
#   Required settings   #
#                       #
#########################

# This is a list of valid fully-qualified domain names (FQDNs) for the NetBox server. NetBox will not permit write
# access to the server via any other hostnames. The first FQDN in the list will be treated as the preferred name.
#
# Example: ALLOWED_HOSTS = ['netbox.example.com', 'netbox.internal.local']
ALLOWED_HOSTS = [${ALLOWED_HOSTS}]

# PostgreSQL database configuration. See the Django documentation for a complete list of available parameters:
#   https://docs.djangoproject.com/en/stable/ref/settings/#databases
DATABASE = {
    'NAME': '${DATABASE_NAME}', # Database name
    'USER': '${DATABASE_USER}', # PostgreSQL username
    'PASSWORD': '${DATABASE_PASSWORD}', # PostgreSQL password
    'HOST': '${DATABASE_HOST}', # Database server
    'PORT': '${DATABASE_PORT}', # Database port (leave blank for default)
    'CONN_MAX_AGE': 300,      # Max database connection age
}

# Redis database settings. Redis is used for caching and for queuing background tasks such as webhook events. A separate
# configuration exists for each. Full connection details are required in both sections, and it is strongly recommended
# to use two separate database IDs.
REDIS = {
    'tasks': {
        'HOST': '${REDIS_HOST}',
        'PORT': ${REDIS_PORT},
        # Comment out \`HOST\` and \`PORT\` lines and uncomment the following if using Redis Sentinel
        # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
        # 'SENTINEL_SERVICE': 'netbox',
        'PASSWORD': '${REDIS_PASSWORD}',
        'DATABASE': $((REDIS_DBID_OFFSET + 0)),
        'SSL': ${REDIS_SSL},
    },
    'caching': {
        'HOST': '${REDIS_HOST}',
        'PORT': ${REDIS_PORT},
        # Comment out \`HOST\` and \`PORT\` lines and uncomment the following if using Redis Sentinel
        # 'SENTINELS': [('mysentinel.redis.example.com', 6379)],
        # 'SENTINEL_SERVICE': 'netbox',
        'PASSWORD': '${REDIS_PASSWORD}',
        'DATABASE': $((REDIS_DBID_OFFSET + 1)),
        'SSL': ${REDIS_SSL},
    }
}
RQ_DEFAULT_TIMEOUT = 300

# This key is used for secure generation of random numbers and strings. It must never be exposed outside of this file.
# For optimal security, SECRET_KEY should be at least 50 characters in length and contain a mix of letters, numbers, and
# symbols. NetBox will not run without this defined. For more information, see
# https://docs.djangoproject.com/en/stable/ref/settings/#std:setting-SECRET_KEY
SECRET_KEY = '${SECRET_KEY}'


#########################
#                       #
#   Optional settings   #
#                       #
#########################

# Specify one or more name and email address tuples representing NetBox administrators. These people will be notified of
# application errors (assuming correct email settings are provided).
ADMINS = [
    # ['John Doe', 'jdoe@example.com'],
]

# URL schemes that are allowed within links in NetBox
ALLOWED_URL_SCHEMES = (
    'file', 'ftp', 'ftps', 'http', 'https', 'irc', 'mailto', 'sftp', 'ssh', 'tel', 'telnet', 'tftp', 'vnc', 'xmpp',
)

# Optionally display a persistent banner at the top and/or bottom of every page. HTML is allowed. To display the same
# content in both banners, define BANNER_TOP and set BANNER_BOTTOM = BANNER_TOP.
BANNER_TOP = ''
BANNER_BOTTOM = ''

# Text to include on the login page above the login form. HTML is allowed.
BANNER_LOGIN = ''

# Base URL path if accessing NetBox within a directory. For example, if installed at http://example.com/netbox/, set:
# BASE_PATH = 'netbox/'
BASE_PATH = '${BASEPATH}'

# Cache timeout in seconds. Set to 0 to dissable caching. Defaults to 900 (15 minutes)
CACHE_TIMEOUT = 900

# Maximum number of days to retain logged changes. Set to 0 to retain changes indefinitely. (Default: 90)
CHANGELOG_RETENTION = 90

# API Cross-Origin Resource Sharing (CORS) settings. If CORS_ORIGIN_ALLOW_ALL is set to True, all origins will be
# allowed. Otherwise, define a list of allowed origins using either CORS_ORIGIN_WHITELIST or
# CORS_ORIGIN_REGEX_WHITELIST. For more information, see https://github.com/ottoyiu/django-cors-headers
CORS_ORIGIN_ALLOW_ALL = False
CORS_ORIGIN_WHITELIST = [
    # 'https://hostname.example.com',
]
CORS_ORIGIN_REGEX_WHITELIST = [
    # r'^(https?://)?(\w+\.)?example\.com$',
]

# Set to True to enable server debugging. WARNING: Debugging introduces a substantial performance penalty and may reveal
# sensitive information about your installation. Only enable debugging while performing testing. Never enable debugging
# on a production system.
DEBUG = False

# Email settings
EMAIL = {
    'SERVER': '${SMTP_HOST}',
    'PORT': ${SMTP_PORT},
    'USERNAME': '${SMTP_USER}',
    'PASSWORD': '${SMTP_PASSWORD}',
    'USE_SSL': ${SMTP_USE_SSL},
    'USE_TLS': ${SMTP_USE_TLS},
    'TIMEOUT': 10,  # seconds
    'FROM_EMAIL': '${SMTP_FROM_EMAIL}',
}

# Enforcement of unique IP space can be toggled on a per-VRF basis. To enforce unique IP space within the global table
# (all prefixes and IP addresses not assigned to a VRF), set ENFORCE_GLOBAL_UNIQUE to True.
ENFORCE_GLOBAL_UNIQUE = False

# Exempt certain models from the enforcement of view permissions. Models listed here will be viewable by all users and
# by anonymous users. List models in the form \`<app>.<model>\`. Add '*' to this list to exempt all models.
EXEMPT_VIEW_PERMISSIONS = [
    # 'dcim.site',
    # 'dcim.region',
    # 'ipam.prefix',
]

EOF

if [ "${HTTP_PROXY}" != "" ] || [ "${HTTPS_PROXY}" != "" ]
then
    cat <<EOF
# HTTP proxies NetBox should use when sending outbound HTTP requests (e.g. for webhooks).
HTTP_PROXIES = {
EOF
    if [ "${HTTP_PROXY}" != "" ]
    then
        cat <<EOF
    'http': '${HTTP_PROXY}',
EOF
    fi
    if [ "${HTTPS_PROXY}" != "" ]
    then
        cat <<EOF
    'https': '${HTTPS_PROXY}',
EOF
    fi
    cat <<EOF
}
EOF
fi

cat <<EOF
# IP addresses recognized as internal to the system. The debugging toolbar will be available only to clients accessing
# NetBox from an internal IP.
INTERNAL_IPS = ('127.0.0.1', '::1')

# Enable custom logging. Please see the Django documentation for detailed guidance on configuring custom logs:
#   https://docs.djangoproject.com/en/stable/topics/logging/
LOGGING = {}

# Setting this to True will permit only authenticated users to access any part of NetBox. By default, anonymous users
# are permitted to access most data in NetBox (excluding secrets) but not make any changes.
LOGIN_REQUIRED = ${LOGIN_REQUIRED}

# The length of time (in seconds) for which a user will remain logged into the web UI before being prompted to
# re-authenticate. (Default: 1209600 [14 days])
LOGIN_TIMEOUT = None

# Setting this to True will display a "maintenance mode" banner at the top of every page.
MAINTENANCE_MODE = False

# An API consumer can request an arbitrary number of objects =by appending the "limit" parameter to the URL (e.g.
# "?limit=1000"). This setting defines the maximum limit. Setting it to 0 or None will allow an API consumer to request
# all objects by specifying "?limit=0".
MAX_PAGE_SIZE = 1000

EOF

if [ "${MEDIA_ROOT}" != "" ]
then
    cat <<EOF
# The file path where uploaded media such as image attachments are stored. A trailing slash is not needed. Note that
# the default value of this setting is derived from the installed location.
MEDIA_ROOT = '${MEDIA_ROOT}'

EOF
fi

cat <<EOF
# By default uploaded media is stored on the local filesystem. Using Django-storages is also supported. Provide the
# class path of the storage driver in STORAGE_BACKEND and any configuration options in STORAGE_CONFIG. For example:
# STORAGE_BACKEND = 'storages.backends.s3boto3.S3Boto3Storage'
# STORAGE_CONFIG = {
#     'AWS_ACCESS_KEY_ID': 'Key ID',
#     'AWS_SECRET_ACCESS_KEY': 'Secret',
#     'AWS_STORAGE_BUCKET_NAME': 'netbox',
#     'AWS_S3_REGION_NAME': 'eu-west-1',
# }

# Expose Prometheus monitoring metrics at the HTTP endpoint '/metrics'
METRICS_ENABLED = False

# Credentials that NetBox will uses to authenticate to devices when connecting via NAPALM.
NAPALM_USERNAME = ''
NAPALM_PASSWORD = ''

# NAPALM timeout (in seconds). (Default: 30)
NAPALM_TIMEOUT = 30

# NAPALM optional arguments (see http://napalm.readthedocs.io/en/latest/support/#optional-arguments). Arguments must
# be provided as a dictionary.
NAPALM_ARGS = {}

# Determine how many objects to display per page within a list. (Default: 50)
PAGINATE_COUNT = 50

# Enable installed plugins. Add the name of each plugin to the list.
PLUGINS = []

# Plugins configuration settings. These settings are used by various plugins that the user may have installed.
# Each key in the dictionary is the name of an installed plugin and its value is a dictionary of settings.
# PLUGINS_CONFIG = {
#     'my_plugin': {
#         'foo': 'bar',
#         'buzz': 'bazz'
#     }
# }

# When determining the primary IP address for a device, IPv6 is preferred over IPv4 by default. Set this to True to
# prefer IPv4 instead.
PREFER_IPV4 = False

# Rack elevation size defaults, in pixels. For best results, the ratio of width to height should be roughly 10:1.
RACK_ELEVATION_DEFAULT_UNIT_HEIGHT = 22
RACK_ELEVATION_DEFAULT_UNIT_WIDTH = 220

EOF

if [ "${USE_LDAP}" ]
then
    cat <<EOF
# Remote authentication support with ldap
REMOTE_AUTH_ENABLED = True
REMOTE_AUTH_BACKEND = 'netbox.authentication.LDAPBackend'
EOF
else
    cat <<EOF
# Remote authentication support
REMOTE_AUTH_ENABLED = False
REMOTE_AUTH_BACKEND = 'netbox.authentication.RemoteUserBackend'
EOF
fi

cat <<EOF
REMOTE_AUTH_HEADER = 'HTTP_REMOTE_USER'
REMOTE_AUTH_AUTO_CREATE_USER = True
REMOTE_AUTH_DEFAULT_GROUPS = []
REMOTE_AUTH_DEFAULT_PERMISSIONS = {}

# This determines how often the GitHub API is called to check the latest release of NetBox. Must be at least 1 hour.
RELEASE_CHECK_TIMEOUT = 24 * 3600

# This repository is used to check whether there is a new release of NetBox available. Set to None to disable the
# version check or use the URL below to check for release in the official NetBox repository.

EOF

if [ "${UPDATE_CHECK}" != "" ]
then
    cat <<EOF
RELEASE_CHECK_URL = 'https://api.github.com/repos/netbox-community/netbox/releases'

EOF
else
    cat <<EOF
RELEASE_CHECK_URL = None

EOF
fi

if [ "${REPORTS_ROOT}" != "" ]
then
    cat <<EOF
# The file path where custom reports will be stored. A trailing slash is not needed. Note that the default value of
# this setting is derived from the installed location.
REPORTS_ROOT = '${REPORTS_ROOT}'

EOF
fi

if [ "${SCRIPTS_ROOT}" != "" ]
then
    cat <<EOF
# The file path where custom scripts will be stored. A trailing slash is not needed. Note that the default value of
# this setting is derived from the installed location.
SCRIPTS_ROOT = '${SCRIPTS_ROOT}'

EOF
fi

cat <<EOF
# By default, NetBox will store session data in the database. Alternatively, a file path can be specified here to use
# local file storage instead. (This can be useful for enabling authentication on a standby instance with read-only
# database access.) Note that the user as which NetBox runs must have read and write permissions to this path.
SESSION_FILE_PATH = None

# Time zone (default: UTC)
TIME_ZONE = 'UTC'

# Date/time formatting. See the following link for supported formats:
# https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
DATE_FORMAT = 'N j, Y'
SHORT_DATE_FORMAT = 'Y-m-d'
TIME_FORMAT = 'g:i a'
SHORT_TIME_FORMAT = 'H:i:s'
DATETIME_FORMAT = 'N j, Y g:i a'
SHORT_DATETIME_FORMAT = 'Y-m-d H:i'
EOF
