---
layout: post
title: Habitat Introduction
---

_In a [recent post](../tech/getting-involved-in-open-source.html), I explained how I got involved in [Habitat](https://habitat.sh), time to present it a bit more._

## The new Frontier

In the last years, we've seen a shift in how applications should be run, packaged and therefore built. Microservices and containers are the big trend, and everyone wants them, because fashion. Or is it really the only reason?

The big thing that has come up is, to me, of the same nature as the Agile Manifesto. We call it DevOps. To me, DevOps is an organizational structure that facilitates the communication of developers and operations. Not via word documents and releases thrown over the wall, but rather by making the teams collaborate more.

There's often a reduction of DevOps to the tools that can help implement such an organizational change, but it would be like saying that Jira makes you Agile (which of course, it does not). Of course they help, but using one of those tools won't make you a DevOps organization.

Cloud providers and [docker](https://docker.io) (ie: containers for everybody) played a big role in how we now think about software deployment. They took the whole infrastructure at another level. Now, ops use the same kind of tools as developers do to maintain their infrastructure, it's versioned, declarative, repeatable, immutable, ...

This is where we are now: the new Frontier, new things have to be discovered, and new design patterns are emerging.

## The way we deploy software

Up until now, the way apps were deployed usually followed the following pattern:

1. Provision a new machine
2. Install the application runtime dependencies (JVM, interpreter, sidecar tools)
3. Install the application
4. Run the application and its dependencies

This worked, but needed a lot of documentation and discussions to make sure everything would work as expected. The difficulty, IMHO, lies in the communication between humans here. So containers came in and we got to:

1. Provision a new machine (or use a container orchestrator)
2. Install the container(s)
3. Run the container(s)

This is better here, because the container contains all that the application needs to work properly and they all look alike in terms of installation and running them. Although, there are two subtleties here:

* The scheme doesn't change in fact. The container just embeds the app runtime dependencies installation. It's easier, but still starts from the OS up until the app, thus requires good coordination effort to make it right. Also, the container images have to be maintained properly: who is going to make sure that the images use the latest OpenSSL version?
* The medium used as container image must be used by operations and developers. This means that applications and infrastructure are highly coupled and must both use the same tools ([OCI](https://www.opencontainers.org/) tries to address that in the container space)

All the tools and methods used to deploy software usually start from the OS, up until the app, this doesn't define a clear interface between infrastructure and applications, as infrastructure leaks into the application space (container). What if we could handle this the other way around? We could create our application, and build its habitat around it, so that it would perfectly fit. This is what [Habitat](https://habitat.sh) does, and this apparently simple shift in model brings a lot of cool features with it.

## A Habitat for your application

The smallest unit in Habitat is a package. Packages can only depend on other packages and are created for a target architecture (Linux or Windows at the moment). So your application package will depend on your application dependencies, and installing the package will install those dependencies too.

Packages can be turned into services at runtime thanks to the habitat supervisor. It manages your service's process life cycle, this allows it to manage your application's configuration via a templating solution which can adapt to all applications. All of this configuration is part of the package too, and is self documented in the `plan.sh` (package descriptor).

As the dependency tree is completely known by habitat, packages can be exported to infrastructure formats such as Mesos/Docker containers or even a simple `tar.gz` that can be installed on a classic VM. This makes habitat packages a good pivot format and allows decoupling of developer and operations team pretty nicely.

The supervisor can communicate with other supervisors, making is a decentralized application management solution. Multiple instances of the same service can share configuration, services can be updated by the supervisor, configurations can be bound to other services to provide a sort of service discovery (configuration dependencies).

All these packages can be stored in a depot, named [builder](https://bldr.habitat.sh). As the name suggests, it's more than that, it has the ability to connect to github repositories and build packages on pushes. Furthermore, it will rebuild all packages that depend on the one it has just rebuilt. This way, if say, OpenSSL is updated, then all the packages depending on it would be rebuilt.

Finally, builder has continuous delivery channels support. When packages are built, they are put in the unstable channel, and you can promote them to another of your choice. With supervisors listening to a specified channel for auto-updates, this makes it a simple solution for continuous deployment.

This is a high level overview of Habitat. If you want to know more, you should read the [product's website](https://www.habitat.sh), and if you have questions, don't hesitate, join the discussion on [Slack](http://slack.habitat.sh)!