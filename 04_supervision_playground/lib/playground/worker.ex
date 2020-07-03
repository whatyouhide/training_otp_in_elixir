defmodule Playground.Worker do
  use GenServer

  require Logger

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    _ = Logger.info("Starting worker #{inspect(opts[:name])}")
    Process.flag(:trap_exit, true)
    {:ok, opts[:name]}
  end

  @impl true
  def terminate(reason, name) do
    _ = Logger.info("Terminating worker #{inspect(name)} with reason: #{inspect(reason)}")
  end
end
