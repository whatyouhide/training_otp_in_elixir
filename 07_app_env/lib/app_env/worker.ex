defmodule AppEnv.Worker do
  use GenServer

  require Logger

  @compile_time_env Application.get_all_env(:app_env)
  IO.inspect(@compile_time_env, label: "@compile_time_env")

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    Application.put_env(:app_env, :runtime_key, :new_runtime_value)
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    _ = Logger.info("Starting worker: #{inspect(opts[:name])}")
    IO.inspect(Application.get_all_env(:app_env), label: "Env when starting worker")
    {:ok, :no_state}
  end
end
