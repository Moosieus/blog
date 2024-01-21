source .env
mix compile --force
mix build
mix esbuild default
npx wrangler pages deploy ./static --project-name=blog
