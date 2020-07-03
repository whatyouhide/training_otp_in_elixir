defmodule PhoenixObserver.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_observer,
    adapter: Ecto.Adapters.Postgres
end
