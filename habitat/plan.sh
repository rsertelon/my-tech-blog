pkg_name=my-tech-blog
pkg_origin=rsertelon
pkg_maintainer="Romain Sertelon <romain@sertelon.fr>"
pkg_license=('CC-BY-SA-4.0')
pkg_deps=(
  rsertelon/thttpd
)
pkg_build_deps=(
  core/coreutils
  core/gcc
  core/make
  core/ruby27
)

pkg_version() {
  date +%s
}

do_before() {
  update_pkg_version

  gem install jekyll:3.8.6 redcarpet -N
}

do_build() {
  jekyll build --safe --config "${PLAN_CONTEXT}/../_config.yml" -s "${PLAN_CONTEXT}/.." -d "${pkg_prefix}"
}

do_install() {
  chmod -x "${pkg_prefix}/css/main.css"
}
