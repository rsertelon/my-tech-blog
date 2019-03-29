---
layout: post
title: Habitat for Configuration Centralization
---

_Habitat does a lot of good things to help you automate your applications. Here, I'll expose one possible way to manage your application configuration in a versioned and automated way thanks to Habitat's gossip ring._

# Packaging the application with Habitat

For this post, we'll suppose that our application is not using Habitat at all. Thus, first step is to package our application with Habitat, and make use of the configuration templates. I won't get into the details of how packaging works in Habitat, as I [already covered that in another blog post]({{site.baseurl}}{% link _posts/2018-05-15-habitat-packages.markdown %}). Without further ado, let's dive in and package our application.

The application used in this blog post is at [Github](https://github.com/rsertelon/http-echo). It is a simple application showing a nice habitat page, with customizable text based on the `application.properties` configuration file. Here are the `plan.sh` and `run` hook for this application (located in the `habitat` folder of the sources):

```shell
#plan.sh
pkg_name=http-echo
pkg_origin=rsertelon
pkg_version="0.1.0"
pkg_maintainer="Romain Sertelon <romain@sertelon.fr>"
pkg_license=("Apache-2.0")
pkg_deps=(core/jre8)
pkg_build_deps=(core/maven)
pkg_lib_dirs=(lib)

do_build() {
  # Build the executable jar for the app
  pushd $PLAN_CONTEXT/..
    mvn clean install
  popd
}

do_install() {
  # Copy the built jar to the habitat package
  mkdir -p "${pkg_prefix}/lib"
  cp "$PLAN_CONTEXT/../target/${pkg_name}-${pkg_version}.jar" "${pkg_prefix}/lib/"
}
```

{% raw %}
```shell
#hooks/run
# This tells habitat how to run the app
java -jar {{pkg.path}}/lib/{{pkg.name}}-{{pkg.version}}.jar 
```
{% endraw %}

If we package the application like so, it will always make use of its default embedded configuration. Time to make our app configuration managed by Habitat.

# Habitatizing the app configuration

_Habitatize should definitely become a word_

For Habitat to manage your application configuration, you have to provide at least two things:

* A `default.toml` file that will describe the configurable items for your package
* Configuration file templates in the `config/` directory of your `plan.sh`

In our case, the application can be passed a properties file with configuration values, eg:

```properties
app.text=Hello, World!
app.subtext=Nice to see you all here!
server.port=8080
```

Let's habitatize this! First, to define the configuration API exposed to Habitat supervisor with the `default.toml` file:

```toml
text="Hello, Habitat!"
port=8080
```

We've followed the application naming for properties, but removed the `app` prefix. This is another interesting feature that Habitat provides. This allows you to expose a given set of configuration properties, with its own API, and decouple the manageable configuration from the actual configuration properties.

> In the future, we might even be able to version this exposed configuration, as I [proposed here]({{site.baseurl}}{% link _posts/2018-08-28-habitat-service-versioning-proposal.markdown %})

Along with this `default.toml`, we also have to create the configuration file template, here at `config/app.properties`:

{% raw %}
```properties
app.text={{cfg.text}}
app.subtext=Current version: {{pkg.version}}
server.port={{cfg.port}}
```
{% endraw %}

Now, Habitat will create a configuration file when it starts our application, by filling in the template values from the `default.toml` or from the supervisor for the package version.

Note that for now, the application would still use its default embedded configuration. We need to change the `run` hook to account for this newly created configuration file:

{% raw %}
```shell
java -jar {{pkg.path}}/lib/http-echo-{{pkg.version}}.jar \
     --spring.config.location=file:{{pkg.svc_config_path}}/application.properties
```
{% endraw %}

This is it for how to package an application so that Habitat manages its configuration. In the next section, we'll see how we can dynamically change the application configuration values, and one of many ways to version and publish these values.

# Centralized configuration management

## Deploying our habitat application

Before seeing how we can use Habitat to manage our configuration easily, let's see how we can deploy our small application with Habitat.

Note that there are as many ways to deploy applications with Habitat as there are provisioning and infrastructure management tools out there, here, I'll simply make use of the simplest `hab` commands to get a running application.

1. Install `hab` on the server
1. Make sure the supervisor starts with the OS (using a `systemd` service file for example)
1. `hab svc load rsertelon/http-echo`
1. Done.

The application should now run as an Habitat service, in the default group: `http-echo.default`

You can now change its configuration with a `hab` command:

```shell
# You can provide a complete configuration, or the whole set of properties you want 
# to change. Here, the port won't change, but the welcome text will
echo 'text = "Hello, Habitat!"' > /tmp/config.toml
# First arg is the service group to which the config should be applied, then the runtime 
# version of the config in the ring, it must be increased to be applied by Habitat
hab config apply http-echo.default $(date +%s) /tmp/config.toml 
```

The application should now have restarted automatically and should show the new welcome text: `Hello, Habitat!`.

## Versioning our configuration values

Providing ad-hoc configuration values works well, but it would be best to have an history of the configuration values that were applied, and ideally, an automated way of deploying them. We're finally digging into what the title of this article advertised!

The solution I will explain here is really simple. I've used it in production, and we actually did all that this post explains (0 to habitat to config management) in a handful of days!

We will use a new git repository to store the runtime configuration values for our application(s), and add a post-receive hook that will apply the configuration on each push received.

Here is the structure of the configuration repository:

```bash
├── http-echo.ppr
│   └── config.toml
├── http-echo.prd
│   └── config.toml
└── deploy-configs.sh
```

We have one folder by service group, which contains the configuration to be deployed in the `config.toml` file. And the `deploy-configs.sh` script that will call `hab config apply` for each service group, it looks something like this:

```bash
for f in $(ls .); do
  hab config apply $f $(date +%s) $f/config.toml
done
```

> Note that for this to work, you actually have to have all your service groups in the same Habitat ring.

Finally, we only have to set up a git repository with a `post-receive` hook calling the `deploy-configs.sh` script on a server that had access to the ring. Then, it's just a matter of making a config change, committing and pushing it.

This is it! With that, you can manage the runtime configuration values of your habitat services quite easily, and benefit from an history of the changes that happened.

# Conclusion

Habitat's strengths are multiple. We've seen that its packaging system allows for easy deployment of any type of application (here a java/spring boot one). The Habitat supervisor is making it really easy to provide a standardized configuration management solution for all applications. And thanks to its simple API, it's quite easy to inject configuration values into the supervisor ring for every application, and from any kind of config management tooling.