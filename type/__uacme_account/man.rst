cdist-type__uacme_account(7)
============================

NAME
----
cdist-type__uacme_account - Install uacme and register a Let's Encrypt account.


DESCRIPTION
-----------
This type can be used to install :strong:`uacme`\ (1) and set up a
Let's Encrypt account.

**NOTE:** this type will automatically accept the Terms of Use of Let's Encrypt.

:strong:`cdist-type__uacme_obtain`\ (7) depends on this type.


BOOLEAN PARAMETERS
-----------------
deactivate-if-absent
   Deactivate this account before deleting the ``--confdir``
   (if ``--state absent``).

   **NB:** deactivating the ACME account is an irreversible action!
   Users may wish to do this when the account key is compromised or
   decommissioned.  A deactivated account can no longer request
   certificate issuances and revocations or access resources related
   to the account.


OPTIONAL PARAMETERS
-------------------
admin-email
   Administrative contact (e-mail address to attach to the account).

   NB: this parameter is deprecated, please use ``--email`` instead.
confdir
   The configuration directory for this account's private key and location
   to store the requested certificates and corresponding private keys.

   **NB:** this location must be unique! There cannot be two
   :strong:`cdist-type__uacme_account`\ (7) objects with the same ``--confdir``.

   Defaults to: ``/etc/ssl/uacme``
email
   Administrative contact (e-mail address to attach to the account).
state
   One of:

   ``present``
      the uacme package is installed and the ``--confdir`` exists.
   ``absent``
      the uacme package is installed, but ``--confdir`` does not exist.

   Defaults to: ``present``


EXAMPLES
--------

.. code-block:: sh

   # Create account with default settings for the OS and no e-mail.
   __uacme_account default

   # Create an account with email and custom location.
   __uacme_account uacme \
      --confdir /etc/uacme \
      --email admin@example.net


SEE ALSO
--------
* :strong:`cdist-type__uacme_obtain`\ (7)
* :strong:`uacme`\ (1)


AUTHORS
-------
* Dennis Camera <dennis.camera--@--riiengineering.ch>


COPYING
-------
Copyright \(C) 2023-2025 Dennis Camera.
This is a rewrite of the original type:
Copyright \(C) 2020 Joachim Desroches.
You can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.
