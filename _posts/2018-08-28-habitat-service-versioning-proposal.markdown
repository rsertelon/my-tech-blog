---
layout: post
title: Habitat Service Versioning Proposal
---

_I've been contributing to [habitat core plans](https://github.com/habitat-sh/core-plans) this year and we stumbled upon a problem with how we had to change the configuration for non major package upgrades. In this post, I put some of the ideas I had to try to solve this problem._

# How habitat manages packages

[Habitat](https://www.habitat.sh) is really a great software. If you're a developer: you can create simple packages that embed all that your applications need to run. If you're an ops, you can export this package to any infrastructure with the guarantee that it'll just work, and you'll also benefit from a standard configuration interface.

You can describe what components your application needs at build time (`pkg_build_deps`), and at runtime (`pkg_deps`, and bindings).

When installing the package (or exporting it), habitat will install all its runtime dependencies. It'll make sure that your service will run with the exact same dependencies everywhere, thanks to the package identifiers: `core/redis/1.2.0/20180703122324` (this one does not exist ;)).

When you want to actually run the application, you load the service that the package describes into the habitat supervisor, you provide its binds if any, and then you can start it.

When loading the service, you can ask habitat to auto-update the package, either in the default 'stable' channel, or any other of your choice. This way, you can promote a package in builder when you want to deploy it to a given environment.

# What can go wrong, will go wrong

This works really well, but a lot can go bad regarding service changes. The service descriptor is embedded in the same package as is the software needed to spawn it, and has the same version. Usually, the version is tied to the _software_: if you're to change the way the application is configured, but don't touch the software, you keep the same version &mdash; only the release part of the identifier will change.

What happens then if you change the name of a configuration parameter? How can you manage the change, and be sure that it won't break in production?

There's a lot that could be done actually. IMHO, this will mostly be done by creating human processes, or by adding automation around habitat. Likely every team using habitat will have to solve this problem once their project starts to evolve in production.

We could then source how the community solved it and document it as a best practice. But I think that Habitat should provide a way to manage service evolutions, because I believe that this is exactly where Habitat shines :)

# Versioning services

When we talk about a package in Habitat, we actually talk about two things as I said earlier: the software &mdash; usually libs, scripts and/or executables &mdash; and the service that it provides &mdash; configuration, binds &mdash;, if any: many core packages are just binaries.

I think habitat plans should version the service contained inside the package. This version would evolve at a different pace than the software version, to keep track of how the configuration API created in the plan evolves (eg: how we name toml variables). This version could then be used by habitat to:

* check that an auto-update won't break the service
* allow ops to create configurations for different versions of a service ahead of time
* warn ops when they try to update a package and its service version changes (as does npm)

This would then allow core plan maintainers to make changes to services, and users would pull them knowing that changes have to be applied. This would also encode processes for upgrading a package if its configuration changes for example.

# Technicalities

## Service versioning in plans

We could use a plan variable named `pkg_svc_version=M.m.p`, using semver, as we do for the package version. If none is found, then habitat shouldn't bother with service versionning at all.

## Manual package update

On `hab install core/redis[/version[/release]]`, if habitat detects that current installed package and update candidate have a different service version, then:

* If it's a patch change, information could be shown to tell the user.
* If it's a minor change, information should be shown to tell the user.
* If it's a major change, user should confirm the update.

## Service groups

We should have service groups mapped to a given version of the service, suppose we have `pkg_svc_version=1.2.0` in `core/redis`:

* `redis.<grp>` => will be used for any version (current)
* `redis.1.<grp>` => will be used for `1.x.x` versions
* `redis.1.2.<grp>` => will be used for `1.2.x` versions
* `redis.1.2.0.<grp>` => will be used for `1.2.0` only

This helps setting the right configuration for a future version for example, and then trigger the auto-update by promoting the package.

## Loading a service

When loading a service, ops should be able to define if the supervisor should allow updates on service version change between two software version:

```shell
# allow patch service version change (default)
hab svc load core/redis --strategy rolling
# allow minor service version change
hab svc load core/redis --strategy rolling --safe-service-update
# allow major service version change
hab svc load core/redis --strategy rolling --unsafe-service-update
```

I chose to protect by default, I feel its safer, and if people don't use the `pkg_svc_version` variable, this will work as it does today.

# Conclusion

When I first used habitat, I found the package system really cool, for exports and isolation. As I started to manage an app comprised of around a dozen of microservices, the thing that struck me most was that we were actually creating an API for our app configuration. In this post, I just pushed the idea a little bit, and added versioning, as every good API should have... :)