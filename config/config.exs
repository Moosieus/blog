import Config

config :esbuild,
  version: "0.18.6",
  default: [
    args: ~w(styles.css --bundle --minify --external:/assets/fonts/* --outfile=site.min.css),
    cd: Path.expand("../static/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
