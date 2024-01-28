# Docker for production and development (draft)
Why can't the world be perfect.

*This is a rough draft from a discussion I had. I'll reflect on it perhaps publish something at some point. AFAICT the story for using Docker in development isn't super straightforward. In time I'll hopefully know for certain.*

## In a perfect world
Developers would do this:
```sh
git clone https://github.com/joe_ligma/balls
cd balls
lazydocker # b -> up
```

Everything's now running, and developers can use whatever tools they want to develop shit.

They shouldn't have to touch Docker, sans requiring additional system dependencies.

The experience should feel transparent to local development. Read: they should have all the tools they desire to use at their disposal.

When they're done, they `git push` and file a merge request.

## What's the production story look like?

## Geordi's take (probably correct):
- The contents of a container should be the exact same.
- The behaviour of the entrypoint script should switch based on env vars.

This ensures consistency at the expense of flexibility; namely being able to have varying container configs.

At this juncture, I consider this the correct default for having development and production containers.

## In larger, imperfect projects:
Some projects may have to deviate between their dev and prod containers. Care should be taken not to let the diverage too much.

The upside remains that everything is containerized, documented, and trivial to spin up.

Geordi argues that this situtation should never arise, **not even in Fortune 500 tech companies.** I'm inclined to agree, but lack the personal experience to know for sure.

If you need a "file bucket", and use S3 for prod but a file system for dev, **no you shouldn't**. You should have something that emulates S3 as a service in dev and actual S3 in production.

## Note:
[Facebook doesn't even use staging environments](https://news.ycombinator.com/item?id=30899362) because they're certain enough. I strive to emulate this.
