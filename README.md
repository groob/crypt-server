__[Crypt][1]__ is a system for centrally storing FileVault 2 recovery keys. It is made up of a client app, and a Django web app for storing the keys.

This Docker image contains the fully configured Crypt Django web app. A default admin user has been preconfigured, use admin/password to login.
If you intend on using the server for anything semi-serious it is a good idea to change the password or add a new admin user and delete the default one.

The secrets are encrypted, with the encryption keys stored at ``/home/docker/crypt/keyset``. You should mount this on your host to preserve the keys:

```
-v /somewhere/on/the/host:/home/docker/crypt/keyset
```

__Changes in this version__
=================

- 10.7 is no longer supported.
- Improved logging on errors.
- Improved user feedback during long operations (such as enabling FileVault).

__Client__
====
The client is written in Pyobjc, and makes use of the built in fdesetup on OS X 10.8 and higher. An example login hook is provided to see how this could be implemented in your organisation.

__Features__
=======
- If escrow fails for some reason, the recovery key is stored on disk and a Launch Daemon will attempt to escrow the key periodically.
- If the app cannot contact the server, it can optionally quit.
- If FileVault is already enabled, the app will quit.


  [1]: https://github.com/grahamgilbert/Crypt

# Docker Environment variables
The `macadmins/crypt-server` container exposes several environment variables that you can configure at runtime.  
If you're new to using docker, see the [official documentation](https://docs.docker.com/engine/reference/run/#env-environment-variables) for how to specify environment variables.

Configurable parameters and defaults
```
TZ America/New_York
# To define multiple admins: Some Name,some@where.com:Another One,another@host.net
DOCKER_CRYPT_ADMINS Admin User,admin@test.com
DOCKER_CRYPT_LANG en_US
DOCKER_CRYPT_TZ America/New_York

# django admin password. This setting is only used on first setup
ADMIN_PASS

# database configuration
# these can be specified directly, or by linking a database container with --link some-postgres:db
# :db becomes DB_ when the containers are linked
DB_NAME
DB_USER
DB_PASS
DB_PORT_5432_TCP_ADDR
DB_PORT_5432_TCP_PORT
```

