defmodule RedisClientBlocking do
  use GenServer

  defstruct [:socket]

  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def command(pid, commands) when is_list(commands) do
    GenServer.call(pid, {:request, commands})
  end

  @impl true
  def init(opts) do
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)

    {:ok, socket} = :gen_tcp.connect(String.to_charlist(host), port, [:binary, active: false])
    {:ok, %__MODULE__{socket: socket}}
  end

  @impl true
  def handle_call({:request, commands}, _from, state) do
    packed = RedisClient.Protocol.pack(commands)
    :ok = :gen_tcp.send(state.socket, packed)

    {:ok, data} = :gen_tcp.recv(state.socket, 0)
    {:ok, response, ""} = RedisClient.Protocol.parse(data)

    {:reply, response, state}
  end
end
