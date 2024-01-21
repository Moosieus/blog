source .env
mix build
mix esbuild default
npx wrangler pages publish ./static --project-name=blog
