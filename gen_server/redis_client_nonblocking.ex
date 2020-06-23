Code.require_file("redis_protocol.ex", __DIR__)

defmodule RedisClient do
  use GenServer

  defstruct [:socket, :requests]

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

    {:ok, socket} = :gen_tcp.connect(String.to_charlist(host), port, [:binary, active: true])
    {:ok, %__MODULE__{socket: socket, requests: :queue.new()}}
  end

  @impl true
  def handle_call({:request, commands}, from, state) do
    packed = RedisProtocol.pack(commands)
    :ok = :gen_tcp.send(state.socket, packed)

    state = %{state | requests: :queue.in(from, state.requests)}
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, %__MODULE__{socket: socket} = state) do
    # Big oversimplification here, because Redis or the OS will likely optimize and
    # pack data in a single packet. We can see this in action with a simple example:
    # getter = fn -> RedisClient.command(pid, ["GET", "mykey"]) end
    # [Task.async(getter), Task.async(getter)] |> Enum.map(&Task.await/1)

    {:ok, response, ""} = RedisProtocol.parse(data)

    {{:value, from}, queue} = :queue.out(state.requests)

    GenServer.reply(from, response)

    state = %{state | requests: queue}
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, %__MODULE__{socket: socket} = state) do
    {:stop, _reason = :tcp_closed, state}
  end

  def handle_info({:tcp_error, socket, reason}, %__MODULE__{socket: socket} = state) do
    {:stop, reason, state}
  end
end
