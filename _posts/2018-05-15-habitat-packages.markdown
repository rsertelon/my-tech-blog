---
layout: post
title: Habitat Packages
---

_The first thing we need to understand is how packages are named, and how they are built._

## Package identifier

A Habitat package has a unique identifier, eg: `rsertelon/java-app/1.0.0/20180508112324`. It is comprised of 4 parts:

* The **origin**: `rsertelon` which indicates who created the package.
* The **package name**: `java-app` which is a unique name in that origin.
* The **version number**: `1.0.0` which corresponds to the packaged application version
* The **release number**: `20180508112324` which is similar to the build number of the package

The hierarchy represented by this identifier, is also a path and is used by habitat to store installed packages in `/hab/pkgs`. This structure combined with the build time insurances given by habitat is what makes packages isolated properly. This is important to understand, as when you'll create your packages, you have to make sure they're self-contained.

The package name and version number are usually used by everyone to describe a software package. Note that habitat will use a semantic versioning like comparison between versions to find the latest one when needed (ie: when specifying `rsertelon/java-app` as dependency &mdash; without the version and release number).

Upon those two parts, the origin acts as both a namespace and a trusted origin via cryptographic key signing. Owning the private key of an origin allows you to publish packages for it. Habitat will _always_ check that its downloads are signed properly before installing it locally.

Finally, the release number is an always increasing number corresponding to the moment the package was built. It is important for habitat, as the same application version could have multiple published packages, but only one would be used by another package. This could be increased, for example, when a dependency is updated, but the software is still the same.

## Building a package

OK, now, let's build a habitat package. For this post, we'll be packaging [libunistring](https://www.gnu.org/software/libunistring/) for linux x64. This package is the simplest I can think about, that's why ;)

> To build linux packages, we have to write a `plan.sh` file that will define a set of variables that will allow habitat to make its soup. The plan is a shell script for linux, or a powershell script for Windows.

Here's the `plan.sh` for our package (taken directly from habitat's [core plans](https://github.com/habitat-sh/core-plans/blob/master/libunistring/plan.sh)):

```shell
pkg_origin=rsertelon
pkg_name=libunistring
pkg_version=0.9.6
pkg_description="Library functions for manipulating Unicode strings"
pkg_upstream_url="https://www.gnu.org/software/libunistring/"
pkg_license=('LGPL-3.0')
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://ftp.gnu.org/gnu/libunistring/libunistring-${pkg_version}.tar.xz"
pkg_shasum="2df42eae46743e3f91201bf5c100041540a7704e8b9abfd57c972b2d544de41b"
pkg_deps=(
  core/glibc
)
pkg_build_deps=(
  core/diffutils
  core/gcc
  core/make
)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_bin_dirs=(bin)

do_check() {
  make check
}
```

### Plan variables

So this shouldn't look too wierd, even if you didn't write many bash scripts in your life. The first three variables (`pkg_origin`, `pkg_name`, `pkg_version`) make the identity of the package. Note that the signing key used when building the package will determine the origin in the end.

The next four (`pkg_description`, `pkg_upstream_url`, `pkg_license`, `pkg_maintainer`) are pure metadata, they would be useful for package users mainly.

Then we enter in the important bits of the plan. First, there are variables that contain the dependencies of the package. In habitat, you can have build dependencies and runtime dependencies. The build dependencies are available uniquely during the build of the package, usually, you'll find build tools (make, maven, ...) and compilers (gcc, jdk, ...). The runtime dependencies are the ones that will be installed at the same time as your package. They are required for the package to work properly. `pkg_build_deps` and `pkg_deps` are the arrays containing this information, in our case, we need only `core/glibc` at runtime (the lib links to it) but we need `core/diffutils`, `core/gcc` and `core/make` to build the library.

`pkg_source` and `pkg_shasum` tell habitat where it can download a source tarball to build the package from, and its SHA256 sum, so it can validate the downloaded file is the expected one. The file will be unzipped by habitat automatically so the build can happen.

The next three variables (and the last of this plan) are indications for habitat to manage common environment variables correctly (`PATH`, `CFLAGS`, `CXXFLAGS`, `CPPFLAGS`, `LD_RUN_PATH`, `LDFLAGS`, ...). If you're not working with native code (C/C++ mainly), most of these aren't important for you, except for `PATH`, of course.

Here, `pkg_include_dirs` is an array of all the directories containing C/C++ header files, `pkg_lib_dirs` is an array of all the directories containing `.so` files, and `pkg_bin_dirs` is an array of all the directories containing executable binaries that should be made available by this package. These paths are all relative to the package path on disk.

### Build phase callbacks

Finally, there's this `do_check()` function here, what does it do? It is what we call a build callback, [there are several](https://www.habitat.sh/docs/reference/#reference-callbacks) in a `plan.sh` that are defined for you, with good defaults for most C/C++ software which are a big part of those in the core origin.

The callbacks that I've seen defined the most are:

* `do_setup_environment()` &mdash; adds run/build time env vars that will be managed by habitat
* `do_prepare()` &mdash; prepare the script, define/override local variables mainly
* `do_build()` &mdash; actually build the software in the package
* `do_check()` &mdash; runs 'unit tests' on the built binaries (if `DO_CHECK` env var is defined)
* `do_install()`&mdash; installs the built binaries into the `pkg_prefix`, ie: the package path on disk.

In our case, we use the default `do_build()` which is:

```shell
do_build() {
  ./configure --prefix="${pkg_prefix}"
  make
}
```

This is the standard way of building C/C++ programs. The default `do_setup_environment()`, `do_prepare()` and `do_check()` callbacks do nothing. Since this package has a 'check' make target for running 'unit tests', we define the `do_check()` callback.

Finally the default `do_install()` is:

```shell
do_install() {
  make install
}
```

Which works fine in our case too, it will copy all libs and headers to the right package folders, per standards.

### hab pkg build

This is the plan we're going to build. If you want to try, first make sure you have a copy of habitat available in your `PATH`, installation documentation is [available here](https://www.habitat.sh/docs/install-habitat/) (you'll need to configure habitat with `hab cli setup`, the personal access token isn't necessary for this step).

Then, copy the contents of the file above, and put them in `/my/path/to/plan.sh` and run `hab pkg build /my/path/to/`. Here is a sample output from the end of the build:

```shell
# ...
libunistring: 
libunistring: Source Path: /hab/cache/src/libunistring-0.9.6
libunistring: Installed Path: /hab/pkgs/core/libunistring/0.9.6/20180515065049
libunistring: Artifact: /src/results/core-libunistring-0.9.6-20180515065049-x86_64-li...
libunistring: Build Report: /src/results/last_build.env
libunistring: SHA256 Checksum: 5625b4c005d66621a3f1543d885c6c18302b9f623107397787d034...
libunistring: Blake2b Checksum: e931b833bb37dbef39b753aed7817dc76c8f0a1508a7038b4507f...
libunistring: 
libunistring: I love it when a plan.sh comes together.
libunistring: 
libunistring: Build time: 1m29s
```

After the build succeeded, you should have a new `results/` directory containing a `.hart` file corresponding to the plan you just built.

That's it for this post, more could be said of course :) You can find more information on the [Habitat website](https://www.habitat.sh). I hope you now get a clear understanding of how you can build habitat packages.