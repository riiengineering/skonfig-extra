cdist-type__nextcloud(7)
========================

NAME
----
cdist-type__nextcloud - Installs and manages a nextcloud instance


DESCRIPTION
-----------
This type installs, upgrades and configure a nextcloud instance. The object
id is the absolute path for the installation directory. Nextcloud will be
installed unter that directory.


REQUIRED PARAMETERS
-------------------
version
    The version that should be installed. If it is already installed and the
    installed version lower, it will upgrade nextcloud if ``--install-only`` is
    not set.

    You get version numbers from the `official changelog
    <https://nextcloud.com/changelog/>`_ or from the `GitHub Releases
    <https://github.com/nextcloud/server/releases>`_ page. The type will
    download the tarball over the official nextcloud website.

    The type will never downgrade a nextcloud instance. Rather, it will fail,
    as this is a missconfiguration. Downgrades are not recommended and
    supported by upstream. Such cases can happen if the nextcloud instance was
    upgraded via the built-in nextcloud installer. In such cases, it is
    recommended to use the ``--install-only`` option.

    You should only upgrade to the next major release from the latest point
    release (latest release available in that major); see the `how to upgrade
    Guide <https://docs.nextcloud.com/server/latest/admin_manual/maintenance/upgrade.html>`
    from the official Nextcloud documentation. This type will prevent skipping
    major releases except the check is explicitly disabled through the
    ``--disable-version-check`` parameter.

    Currently, no loop is implemented to do these upgrades automaticly for you,
    as the type does not implement any version knowledge. Manifest must be
    changed and skonfig needs to be rerun to get to the correct version you need.

admin-password
    The administrator password to access the nextcloud instance. Must be given
    in plain text. This parameter has no effect if nextcloud will not be
    installed.


OPTIONAL PARAMETERS
-------------------
mode
    Sets the unix file mode of the nextcloud directory. This is not inherited
    to child files or folders. Defaults to `755`.

user
    The user which owns the complete nextcloud directory. The php application
    should be executed with this user. All nextcloud commands will be executed
    with this user. This type will not create the unix user.

    The type assumes the default `www-data` user, which is common on Debian
    systems. **If you change this option, please do the same with the group
    parameter!**

group
    The group all files and folders of the nextcloud installation should have.
    Defaults to `www-data`. Should be changed with ``--user``.


BOOLEAN PARAMETERS
------------------
install-only
    Skips all nextcloud upgrades done by this type. Should be used when
    nextcloud upgrades are (*exclusively*) done via the built-in updater.

disable-version-check
    Disables the version security checks that avoid breaking your Nextcloud.
    Only do this on your own risks, as it can seriously break your instance.

    Is this parameter omitted, the type will check if the new major version
    gap is greather than 1. It will not perform more fine-tuned version checks
    cause of a lack of more detailed versioning data.


NEXTCLOUD CONFIG PARAMETERS
---------------------------
host
    All hostnames where the the users can log into nextcloud. If you access
    nextcloud via a hostname not given to this list, the access fails. This
    parameter can be set multiple times.

admin-user
    The username of the administrative user which will be created while the
    installation. If not set, nextcloud defaults to "admin". This parameter has
    no effect if nextcloud will not be installed.

admin-email
    The email address of the administrative user. This parameter has no effect
    if nextcloud will not be installed.

data-directory
    This will set or change the data directory where nextcloud will keep all
    its data, including the SQLite database if any. By default, it will be
    saved in the ``data`` directory below the nextcloud directory.

    If this directory change, this type will move the old location to the new
    one to preserve all data. This is not supported by upstream, as some apps
    may not handle this.

database-type
    Sets the type of database that should be used as backend. Possible backends
    are:

    SQLite
        Use ``sqlite3`` as value. Saves everything in a database file
        stored in the data directory. It is only recommended for very small
        installations or test environments from upstream.

        *All further database options are ignored if SQLite is selected as
        database backend.*

    MariaDB
        Use ``mysql`` as value. MariaDB and MySQL are threated the same
        way. They are the recommended database backends recommended from
        upstream.

    PostgreSQL
        Use ``pgsql`` as value.

    **This parameter defaults to the SQLite database backend, as it is the
    simplest one to setup and do not require extra parameters.**

    If this parameter change, the type will migrate to the new database type.
    It will not work for SQLite because the upstream migration script does not
    support it. **Be aware that migrations take there time, plan at minimum
    40 seconds of migration for a stock installation.**

database-host
    The database host to connect to. Possible are hostnames, ip addresses or
    UNIX sockets. UNIX sockets must set in the format of
    ``localhost:/path/to/socket``. If an non-standard port is used, set it
    after the hostname or ip address seperated by an colon (``:``). If this
    value is not set, nextcloud defaults to the value ``localhost``.

    This type will not migrate data if the type does not change. You must do
    this manually by setting the maintainer mode (to avoid data changes) and
    then cloning the database to the new destination. After that, run skonfig to
    apply the config changes. It should automaticly remove the maintainer mode.

database-name
    The name of the database to connect to. Required if MariaDB or PostgreSQL
    is used.

database-user
    The username to access the database. Required if MariaDB or PostgreSQL is
    used.

database-password
    The password required to authorize the given user. Required if MariaDB or
    PostgreSQL is used.

database-prefix
    The table prefix used by nextcloud. If nothing set, nextcloud defaults to
    ``oc_``.


MESSAGES
--------
installed
    Nextcloud was successfully installed.

upgraded $old to $new
    The nextcloud version was upgraded from `$old` to `$new`.

configured
    Nextcloud configuration was changed.


ABORTS
------
Aborts in the following cases:

The current installed version is greather than the version that should be
installed. See the parameter description of `--version` for detailed
information. The problem can be fixed by bumping the version value to at least
the version that is currently installed or use the parameter `--install-only`.

It may abort if the data directory can not be moved correctly. Then, the
nextcloud configuration is broken and must be resolved manually: Move the data
directory to the correct location or change the configuration to point to the
old destination and retry.

It aborts if it should migrate to a SQLite database. This will be done before
the upstream migration script is executed, as it would throw the same error.

The explorers will abort if they found a valid nextcloud installation, but no
installed `php`. Currently, this is intended behaviour, because it can not
safely get the current nextcloud version, also do not get the nextcloud
configuration. For more information, see the *NOTES section*.


EXAMPLES
--------

.. code-block:: sh

  # minimal nextcloud installation with sqlite and other defaults
  # please only use sqlite for minimal or test installations as recommend :)
  __nextcloud /var/www/html/nextcloud --version 20.0.0 \
        --admin-password "iaminsecure" \
        --host localhost --host nextcloud

  # installation under the webroot
  __nextcloud /var/www/html/ --version 20.0.0
        --admin-password "notthatsecure" --host mycloud.example.com

  # more extensive configuration
  __nextcloud /var/www/cloud --version 20.0.0 --admin-password "iaminsecure" \
        --host localhost --host nextcloud --host 192.168.1.67 \
        --data-directory /var/lib/nextcloud/what \
        --database-type mysql --database-host "localhost" --database-name "nextcloud" \
        --database-user "test" --database-password "not-a-good-password"


NOTES
-----
This type does not cover all configuration options that nextcloud offer.
If you need more configuration options for nextcloud, you are welcome to extend
this type and contribute it upstream!

- `Nextcloud configuration reference
  <https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html>`_

Currently, the state of this object is always `present`. So it will always be
installed without the option to uninstall it again (`absent`). This was done
because it will not be a common demand to uninstall nextcloud again. If you
need to toggle the state, you are welcome to contirbute!

Parameters given for the admin user which will be set up at installation time
(`--admin-*` ones) are not applied if nextcloud will not be installed.
Therefor, parameter changes are not applied to the installation. Currently not
implemented - but possible - is to use the type
:strong:`cdist-type__nextcloud_user`\ (7) to do all the later work.

Database migration is only partly supported if the database will be changed to
``mysql`` or ``pgsql``, because it is supported by an upstream script. You are
welcome to extend this type for database migrations between the same database
type. For an implementation, you may use shell utilites like ``mysqldump(1)``
(be aware that this may not already be installed) or use the already installed
php code to migrate.

The type will abort if a valid nextcloud directory already exists in the
explorer execution, but no `php` exists to explore the setup. Therefor, the
manifest could not install `php` yet. This is not the case for a new
installation, as there does not exist a nextcloud directory with a valid
structure. While some code could be skipped and the other replaced with `awk`
with something like
``awk '$1 == "$OC_VersionString" {gsub(/['\'';]/, "", $3); print $3}' version.php``,
it is not handled for the following cases:

1.  This case should not happen very often.
2.  Maybe because of ``libapache2-mod-php`` or ``php-fpm``, `php` already
    exists for the cli.
3.  While the `awk` replacement for the version is just a bit worser, it would
    bring stable results, while it would be more difficult to dump out the
    configuration without custom `php` or the help from ``php occ``. Therefor,
    it would make false assumptions like it want to install nextcloud again,
    do not delete configuration options and set all available nextcloud options
    that are available through this type.

If the nextcloud installation does not work and you stuck in a plaintext error
screen, try to restart your Apache WWW server first! This type will install all
php dependencies, but there are not recognised by the server-internal php
environment. This can happen after a database migration between different
database types, as it installs the database module only when it is required.

If the tarball needs to be downloaded, it will be directly downloaded into the
directory ``/tmp`` and will be unpacked to the destination for an installation
or to the same directory but prefixed with a dot for an update. It will
download it into the temp directory because it does not find a better location.
In legacy, it was downloaded to the parent directory, but this may not the best
location as the installation dir can be everywhere.

This type does not garantee to always show the maintenance mode screen because
nextcloud does not show it in every case:

1.  For fresh installations, the maintenance mode can not be set.
2.  While upgrades starting at version 20, the user is promted to execute the
    update manually via the webinterface instead of the maintenance screen.

It is recommended to show an own maintanance screen via the webserver if this
is critical for you.


SEE ALSO
--------
`Nextcloud documentation <https://docs.nextcloud.com/server/latest/admin_manual/index.html>`_

:strong:`cdist-type__nextcloud_user`\ (7)


AUTHORS
-------
Matthias Stecher <matthiasstecher at gmx.de>


COPYING
---------
Copyright \(C) 2020 Matthias Stecher. You can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
