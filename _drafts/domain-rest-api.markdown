---
layout: post
title: Domain REST APIs
---

_I've been working on several backend services in the past years. In this post I'll explain how I usually design REST APIs for such applications_

## REST APIs

In the last decade, the REST thing became quite popular, and often replaced SOAP or RMI as a means to communicate from server to server. With the advent of Single Page Applications, and the trend of public APIs (twitter, etc.), they became the go-to choice to write HTTP APIs.

Although a very old concept, they are still not quite yet understood by everybody, and in the last years, we've seen new RPC protocols (grpc) and new ways of querying APIs (graphQL) that may suggest that REST APIs already are "old school" for all hype-driven developers out there.

I strongly believe that REST APIs are still very valid as an architecture to build resilient and scalable back-ends, and I tend to see them as a perfect foundation for such applications. The constraints imposed by REST are very powerful to help you understand the domain you work with, and they really help you for creating long lasting APIs.

Here, I won't write down what _is_ a REST API, many already have explained _resources_, _verbs_, _hypermedia_, etc. What I'd like to focus on are the **principles** that I try to abide by when designing REST APIs, and how that helped me and my teams improve our knowledge of the domain we worked on, and improve our applications.

## It all starts with the domain

While I'm not usually following any methodology by the book, I often pick good ideas that exist in some of them. One good example of that is _Domain Driven Design_. What I like (and use a lot) in this method is the idea of an **Ubiquitous language**. One language used by everybody involved in the product you're working on. This brings many benefits while people communicate around the product, but I find that it can go way beyond that for designing software.

The principal aspect of DDD is the notion of **Domain**. This too is extremely useful, it's like a model, but more business oriented. This means that by defining the domain of your product, you actually are writing down the most accurate description of what you do (or want to do). It also tends to contain extremely stable concepts that are the core of your product, which is very important for your APIs future.

Combined together, these two concepts mean that you are writing down an accurate description of your product domain, and everyone is able to communicate about it with the same words/concepts. You're now set to write a system that should be easier to understand and maintain.

## Representing the domain in REST APIs

_Backwards-compatibility included_

### Resources

The first thing to look for are resources, or domain entities. In a project management system, for example, we can find the following resources (among many others):

* Users
* Projects
* Tasks

Naming is hard as we all know, but working on this part is crucial to understand properly the domain. The most difficult part is usually to see whan an entity is actually embedding different concepts, and split it properly.

### Relationships

To denote domain entities relationships, you should use paths:

1. `/users`;
1. `/projects/{projectId}/users`;
1. `/projects/{projectId}/tasks`;
1. `/users/{userId}/tasks`;

Here's what we can learn about this domain thanks to the above paths:

* In `1.`, `users` are entities that are at the top level of the domain;
* In `2.`, `projects` are entities that are at the top level of the domain;
* In `2.`, `users` can belong to `projects`;
* In `3.`, `tasks` can belong to `projects`;
* In `4.`, `tasks` can belong to `users` too.

This way of arranging resources in paths is the backbone of your API, done correctly it will live very long without changing too much. Indeed, the domain of the application will likely not change a lot in the lifetime of the product (ie: a project will always contain tasks).

### Representations

What is interesting is that `users` in `1.` and `2.` (and `tasks` in `3.` and `4.`) can have different representations, one for each context:

* `/users`
```json
{
    "id": 1,
    "name": "Jane Doe",
    "email": "jane.doe@acme.com"
}
```

* `/projects/{projectId}/users`
```json
{
    "id": 1,
    "role": "OWNER"
}
```

In a typical application, I would name the second representation `ProjectUser`, because it _is_ something different than a `User`. Indeed, the context in which a resource exists plays such an important role for the resource that, to me, it changes its very nature.

It also gives valuable information for how to store both resources, we can already see that we'll likely have a `UserEntity` and a `ProjectUserEntity`.

Another place where I believe resources should also have different representations is when the HTTP verb changes. For example:

* `POST /users`
```json
{
    "name": "Jane Doe",
    "email": "jane.doe@acme.com"
}
```

* `PUT /users/{userId}`
```json
{
    "name": "Jane Doe"
}
```

By doing so, you can consider all fields required by default, and you state that the `email` cannot be changed, only the `name` in this endpoint.

Also, if you need to make a change to a given endpoint, it will impact only said endpoint, in contrast to using the same representation everywhere which would make it difficult to understand properly.

### Representation versioning

By versioning, I don't mean something like semantic versioning, where the aim is to be able to compare two versions for breaking/features/bug fixes etc. and which is usually a good fit for libraries.

In the case of REST APIs, we only have one available deployment, and need to make it evolve. So here, I'm talking about the process of making sure a given client won't fail if you make a change.

If your API backbone follows closely the domain model, it means that paths will likely never change (or if they do, they can co-exist next to the old ones).

To me, this implies that a REST API doesn't need to be versioned at the path level, instead only the resource representations need versioning to prevent aforementioned issue.

Doing so is quite easy with HTTP, since you can use custom media types like so:

1. `Accept: application/vnd.my.app.v1+json`
1. `Accept: application/vnd.my.app.v2+json`
1. `Accept: application/json`

If someone writes a client that requires the representation not to change, they can use a specific version, and unless you _decide_ to deprecate/remove support for said version, the client will never fail.

For clients that don't require this, and for browsing the APIs in a browser, the `application/json` media type should always point to the latest version.

### Resource IDs

Another recurring issue I had in the past with REST APIs was the fact that the IDs exposed in APIs are usually tied to a technical implementation detail (UUIDs, incremental integers, etc.).

In line with thinking about the domain, I always try to find business identifiers. For example, if you consider that a user email address cannot be changed, you can use it as the user identifier (not really GDPR compliant now though :-) ).

So you might write `/users/jane.doe@acme.com/tasks` and it reads easily. It doesn't always make sense to use business IDs (and it's not always possible), but it does make your API easier to understand and navigate when they can be used. I've noticed that it usually works well for the most important entities of your domain though.

## Context matters

TODO:

* Security
  * Rights
  * Tenants

## Splitting a domain REST API

Another interesting concept that emerged in recent years is micro-services. I naturally tend to apply this concept in complex domain designs because it brings many benefits (and some caveats, but this is not the subject of this post). The main one being that you deal with smaller applications to build and maintain.

There are many ways of doing microservices implementation of a domain. One of the main concepts to keep in mind when splitting the domain properly is the notion of _bounded contexts_. Having a bounded context means that a service cannot be responsible for things outside of its context, and must instead ask for the responsible service when needed.

When implementing micro services, the first choice to make is whether we want a set of multiple domain APIS, or a global API in which endpoints are implemented by different services.

Usually, the first solution is implemented, since it's the most natural one, and is more flexible. However, I see it as too chaotic, and I find it hard to ensure domain consistency this way. Also, it often leads to many subdomains that exist next to each other. There is nothing in the system that binds these sub-domains together, except the fact that they are in the same system.

On the other hand, the _Global API_ enforces the fact that the domain design is _shared_ by every service, and each service contributes to it in a more cooperative way. What I mean by that is that TODO

For example, with our project management domain, we could have a service responsible for the `users` sub-domain, and another one for the `projects` sub-domain.

Indeed, REST APIs are interesting because they only contain resources in the URL path, and paths are an excellent way of representing sub-domains as a hierarchical set of resources. Note that this automatically documents the whole domain (which is really valuable).

If we really want to represent our domain with the REST API, this forces us to understand the domain completely (or a bounded part of that domain) before actually writing code for it. APIs become the de facto entry point for our domain and thus, need to be designed with extra care.
Hints for designing "good" REST APIs
