defmodule RedisClient do
  use GenServer

  defstruct [:socket]

  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def command(_pid, commands) when is_list(commands) do
    raise "not implemented yet"
  end

  @impl true
  def init(opts) do
    _host = Keyword.fetch!(opts, :host)
    _port = Keyword.fetch!(opts, :port)

    raise "not implemented yet"
  end
end
