# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phoenix_observer,
  ecto_repos: [PhoenixObserver.Repo]

# Configures the endpoint
config :phoenix_observer, PhoenixObserverWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YSaxr5zoC4fRV7p5EmwPXp9kF2eZdY9jTYdPXILrOkz/LmeIx0YvkAJgZlktYrbx",
  render_errors: [view: PhoenixObserverWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: PhoenixObserver.PubSub,
  live_view: [signing_salt: "QWSXy9oT"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
