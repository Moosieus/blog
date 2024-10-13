%{
  title: "What about WordPress Works",
  description: "I'd like to share what features and abstractions of WordPress gets fundamentally correct that I feel other CMSs should emulate.",
  image: "https://moosie.us/assets/wordpress/linotype.jpg"
}
---
<div style="display:flex;justify-content:center;">
  <img src="./assets/wordpress/linotype.jpg" alt="Linotype Operators" style="margin-bottom: 2rem;">
  <!-- source: https://www.loc.gov/item/2017788930/ -->
</div>

I'd like to share some features and abstractions I think WordPress gets fundamentally correct that I feel other CMSs should emulate.

For some context on my perspective:
- I worked with WordPress on and off for about 4 years, but I didn't start my career that way.
- I have no skin in the CMS market.
- I put maybe all of 15 minutes into gathering my thoughts here.

## The Classic Editor
My first step in all but one WordPress project was to use the [classic editor](https://wordpress.org/plugins/classic-editor/) in lieu of the "Gutenberg" block editor that was introduced in 2018. In my opinion, the admin UI should serve as a data entry interface for HTML, markup, media, and text. A "WYSIWYG experience" is of less importance, and loading a preview page in a new tab is sufficient.

I recall using the Gutenberg editor in earnest on exactly one WordPress project (maybe two), and it proved not worth the trouble.

## Pivotal Plugins
There's lots of functionality relevant to most websites that WordPress doesn't implement, but is instead addressed by popular community plugins. Without them, I'd argue that WordPress would feel incomplete for most users. The two I most immediately recall are **Advanced Custom Fields (ACF)** and **Yoast SEO**:

- **ACF** allows users to define schemas for structured content in the database, and to incorporate them into templates.

- **Yoast SEO** adds lots of niceties for SEO, which is hugely important in marketing.

Any successor CMS would do well to either have these features built in, or maintained as first party extensions. This is far from an exhaustive list though.

## Posts, Pages, and Taxonomy
I would almost regard WordPress' hierarchy of posts, pages, post types, categories, tags, and custom post types as a solved problem. Emulating this structure may also drive conversion among existing users.

## Interpreted templates and code
**This is probably the most important bit:** I'm going to do my best here to explain why PHP has the right execution model for CMSs like WordPress - bear with me.

For starters, the full language is available from within server side rendered templates, akin to Embedded Ruby (.erb), JSX (.jsx), or Embedded Elixir (.eex). This is an important distinction compared to templating languages like Jinja or Go templates. Embedding full languages in templates mitigates context switching for developers and provides crucial flexibility. Server side rendering also dramatically simplifies things and is likewise vital.

PHP is also entirely interpreted from a developer's perspective. There's no need to compile code, fight a compiler toolchain, or resolve mismatching build system versions. Loading novel PHP code into a WordPress website is a simple matter of uploading it, and sometimes clicking a few buttons. 

Finally, WordPress' template system seems a pretty successful pattern.

## Made for power users
All of the points discussed so far are in service of this one: **WordPress excels for power users who cannot code**. Plenty of WordPress 'Developers' don't know a lick of PHP and have still made professional careers creating WordPress websites for clients. These are the users to optimize for.

## What not to do
- Bet on HTML. Markdown is for nerds.

- A modern work-alike would do well to curtail users from needing too many plugins, and to manage plugin dependencies with semver.

- Eschew React. A CMS should be concerned with rendering HTML pages, and not get bogged down in complex re-rendering logic.

## Conclusion
I honestly don't know how on point I am about all this. These were really just invasive thoughts I needed to put to page and out of my head. Pursuant to that, I'd like to add a few closing remarks at peril of derailing discussion:

- I'm not fond of PHP having used it in-anger on several projects. I don't think "modern PHP" remediates enough problems with the language to make it desirable either.

- There's some contention between the concerns of building a website and a webapp, I suppose. Websites almost inevitably need some form of interactivity, but the majority of 'content' shouldn't get caught up in that.
