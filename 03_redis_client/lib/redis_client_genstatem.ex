defmodule RedisClientGenStatem do
  @behaviour :gen_statem

  require Logger

  defstruct [:host, :port, :socket, :requests]

  @spec start_link(keyword()) :: :gen_statem.start_ret()
  def start_link(opts) when is_list(opts) do
    :gen_statem.start_link(__MODULE__, opts, [])
  end

  @spec command(pid(), [String.t()]) :: {:ok, term()} | {:error, term()}
  def command(pid, commands) when is_list(commands) do
    GenServer.call(pid, {:request, commands})
  end

  @impl true
  def callback_mode, do: :state_functions

  @impl true
  def init(opts) do
    data = %__MODULE__{
      host: Keyword.fetch!(opts, :host),
      port: Keyword.fetch!(opts, :port),
      requests: :queue.new()
    }

    actions = [{:next_event, :internal, :connect}]
    {:ok, :disconnected, data, actions}
  end

  ## Disconnected state

  def disconnected(:internal, :connect, data) do
    {:ok, socket} =
      :gen_tcp.connect(String.to_charlist(data.host), data.port, [:binary, active: true])

    data = %__MODULE__{data | socket: socket}
    {:next_state, :connected, data}
  end

  def disconnected({:call, from}, {:request, _commands}, _data) do
    actions = [{:reply, from, {:error, :disconnected}}]
    {:keep_state_and_data, actions}
  end

  ## Connected state

  def connected({:call, from}, {:request, commands}, data) do
    packed = RedisClient.Protocol.pack(commands)
    :ok = :gen_tcp.send(data.socket, packed)

    data = %{data | requests: :queue.in(from, data.requests)}
    {:keep_state, data}
  end

  def connected(:info, {:tcp, socket, payload}, %__MODULE__{socket: socket} = data) do
    # Big oversimplification here, because Redis or the OS will likely optimize and
    # pack data in a single packet. We can see this in action with a simple example:
    # getter = fn -> RedisClient.command(pid, ["GET", "mykey"]) end
    # [Task.async(getter), Task.async(getter)] |> Enum.map(&Task.await/1)

    {:ok, response, ""} = RedisClient.Protocol.parse(payload)

    {{:value, from}, queue} = :queue.out(data.requests)

    :gen_statem.reply(from, {:ok, response})

    data = %{data | requests: queue}
    {:keep_state, data}
  end

  def connected(:info, {:tcp_closed, socket}, %__MODULE__{socket: socket} = data) do
    disconnect(data, _reason = :closed)
  end

  def connected(:info, {:tcp_error, socket, reason}, %__MODULE__{socket: socket} = data) do
    disconnect(data, reason)
  end

  ## Helpers

  defp disconnect(data, reason) do
    Logger.error("Disconnected: #{inspect(reason)}")

    # This is BAD! Let's use a timeout here.
    Process.sleep(10_000)

    data = %__MODULE__{data | socket: nil}
    actions = [{:next_event, :internal, :connect}]
    {:next_state, :disconnected, data, actions}
  end
end
