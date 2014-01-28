---
layout: post
title: Leaving Google
---

In this article, I explain why I'm leaving Google. I'll write more about it and explain how to do it.

## Killing Google

I was born in 1987, the Internet was growing fast when I was a teenager; interested in computers, I naturally fell into the _web_. Since then, I lived with [Google](http://www.google.com).

First, it was a web search engine, it was fun, and one day I received a beta invitation for what has made me a Google fan : [GMail](https://mail.google.com). From this moment on, I followed every new thing launched by Google, I loved their "Don't be evil" motto and the quality of their [products](http://www.google.com/about/products/). I always thought that the web was the future, and as soon as it was possible to make something 'online', I tried it.

From my point of view, Google has been my 'Internet father', educating me on how to use the web, and pushing me to discover many things. This is why this section is called 'Killing Google'. Now, I'm not a web-teenager anymore, I want to live on my own Internet, I have to kill Google to do so.

## Where is my data? What is it used for?

Appart from this teenager crisis, there are other serious facts that push me out of Google's services.

### One privacy policy to rule them all

[Earlier this year](http://www.google.com/intl/en/policies/), they decided that every data collected by one of their services could be available to every other. From a user point of view, this is nice, I have a [Google+](https://plus.google.com/108216280996284757484) profile, and every other service is linked to it. 

Want to send an email? No problem, GMail searches in my contacts and circles. Have an event to plan? GMail can show it, so does G+. Everything is linked, and this one central database makes your life easier.

But it raises concerns about my privacy and how my data will be used. It's no surprise for anyone that Google makes all its money from advertisement, and this policy allows them to know everything about me. They can track me better than Facebook, because my online life is Google. I don't like it, I don't want to feel like I'm a product they sell (even if it has always been the case...).

### The USA and their 'Patriot Act'

Google is an American company, as such, they must comply to US laws. It's been years that the US laws try to close the Internet, to privatize it. Should it be for [security reasons](http://en.wikipedia.org/wiki/Patriot_Act) or for money (majors).

This means that me, French citizen, can be spied by the USA because my data is stored by Google. It is not that I have something to hide (if you follow me on twitter, you'll see I speak about anything publicly), but I don't like that another country, with different laws could use this data against me or others someday (see Julian Assange, Wikileaks and Megaupload cases...).

## Leaving Google

### Is getting out of Google (and the USA) easy?

Simply put: No. I won't lie, this isn't an easy shift. Google's services are so integrated with each other, and in my life, that it was not that easy to move my data (and habits) out of it.

It's been 10 years that I've used GMail and other services, I use Calendar to share my agenda with my fiancée, everyone I know can contact me through my GMail address or via GTalk, all my feeds are in Google Reader. I monitor the visits on my websites thanks to Analytics.

I even had an Adsense account (that they closed for a reason I could never know...), etc.

The most difficult part is to give up your old habits and then, to find the right service to replace Google.

### My solution

So here I am, finally writing about how you can get away from Google ;-).

I rent a [dedicated server](http://www.ovh.com) in France, so I tried to find self-hosted solutions to replace Google. This added some difficulty because I wanted to find software that would be:

* Free of charge
* Open Source (or [Free Software](http://www.fsf.org) if possible)
* Android compatible (with Native App if possible)

These criteria seemed impossible to meet, but I've found software to replace several Google Services:

| Google Service |   Self hosted service I use   |
|----------------|-------------------------------|
|      GMail     | [Roundcube](http://roundcube.net) + [Postfix](http://www.postfix.org) + [Dovecot](http://dovecot.org) |
|      GTalk     |    [ejabberd](http://ejabberd.im) + [Pidgin](http://pidgin.im)/[OTalk](https://github.com/HenrikJoreteg/otalk)    |
|  Google Reader |        [Tiny Tiny RSS](http://tt-rss.org)          |
|    Analytics   |            [Piwik](http://piwik.org)              |

And finally these are the products I haven't replaced yet:

* Google Search (=> [Duck Duck Go](http://duckduckgo.com))
* Google Chrome (=> [Firefox](http://mozilla.org/firefox) for self hosted bookmark sync)
* Google Contacts (=> [OpenLDAP](http://openldap.org) addressbook)
* Google + (=> [Diaspora](http://joindiaspora.com))
* Android (=> Keep it)
* Google Agenda (=> Own CalDAV server)
* Google Docs (=> Nothing yet)
* Google Maps (=> Keep it)
* Picasa (=> ?)
* Google Webmaster Tools (=> Keep it)

## Conclusion

This is it for my motivations and a sneak peek on the solutions I've chosen. I'll write several posts about how I chose and installed them. Feel free to participate in the comments of this post and stay tuned!


__EDIT:__ Added Google Webmaster Tools to the list.
