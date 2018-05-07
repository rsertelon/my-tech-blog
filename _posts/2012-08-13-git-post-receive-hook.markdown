---
layout: post
title: Git post-receive hook
---

This article describes how to deploy [Jekyll](https://github.com/mojombo/jekyll) code with git and post-receive hook.

## How I deployed my code before

As I've been upgrading all my hosted services, I was thinking about a better way to deploy my git-versioned projects, particularly my blog and my soon-to-be [personal website](http://bluepyth.fr). Here is how I deployed my [Jekyll](https://github.com/mojombo/jekyll)-based blog before:

1. Push all my changes to a repository hosted on my server.
2. Wait for a cron task to execute jekyll to generate my blog
3. Once the blog was generated, it was copied to the root folder of my blog's virtual host

As you can see, it's already automatic, I just had to push my code to my server, instead of having to generate it myself and push it every single time I wanted to modify a word in an article.

I liked this process, but something didn't feel quite right. The cron task was reapeated each day, even though I didn't make any changes to my blog. This was a waste of resources (I want my server to be as efficient as possible) and I had to wait 'till midnight to see my modifications...

## Git Hooks at your service

For those of you who know git, you must have read or heard about git hooks. They are executed at precise moments during git's workflow. When I remembered about them, I was like "hey let's _tell_ my server to deploy, instead of having it _ask_ if there's something to deploy!" (yeah, I felt like a genius for one second)

So I started to look for information and found how I could use these hooks to have my code being deployed on push: `post-receive` hook.

## Of creating the hook

Creating a hook for git is a piece of cake for anyone who knows the basics of shell scripting.

First thing to know: hooks are installed per-repository. If you delete your repository, you'll have to re-create your hooks. 

Second thing: they are simple shell scripts put in the hooks folder of your git repository (if it's a bare directory `your-repo/hooks` if it is a working repository `your-repo/.git/hooks`) with executable rights.

With all this, let's go and create a simple hook that will build and publish a jekyll website right after you push your changes.

### Creating the hook file

First, let's add the hook (I'll use a bare git repository in this example) :

```bash
~/my-repo $ cat > hooks/post-receive
#!/bin/bash
~/my-repo $ chmod +x hooks/post-receive
```

This is it, we have created the hook.

### Generating with jekyll and deploying

Now, we have to fill the script with useful stuff:

```bash
#!/bin/bash
mkdir -p /tmp/my-jekyll-website                                             #1
GIT_WORK_TREE=/tmp/my-jekyll-website git checkout -f                        #2
rm -r -f /var/www/my-jekyll-website/*                                       #3
jekyll --no-auto --safe /tmp/my-jekyll-website/ /var/www/my-jekyll-website/ #4
rm -r -f /tmp/blog.bluepyth.fr                                              #5
```

Let's explain this little script:

1. Create a temporary directory to store the actual code of the website since we were in a bare repository
2. Checkout the code in this folder. The `GIT_WORK_TREE` environment variable tells git where to work (by default it is the current directory)
3. Remove all contents from the current website (to avoid deleted files/folders not be deleted)
4. Generate the website from the source code, to the good directory.
5. Delete the temporary directory

Here you go!

## Conclusion

Now let's try it, just type in from your working directory:

```bash
~/sources/my-jekyll-website $ git push web
```

And voila! You can see in the console that the jekyll website has been generated and deployed!
