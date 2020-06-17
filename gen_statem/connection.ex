defmodule Connection do
  @behaviour :gen_statem

  require Logger

  defstruct [:host, :port, :socket]

  def start_link(opts) do
    :gen_statem.start_link(__MODULE__, opts, [])
  end

  @impl true
  def callback_mode, do: :state_functions

  @impl true
  def init(opts) do
    data = %__MODULE__{
      host: Keyword.fetch!(opts, :host),
      port: Keyword.fetch!(opts, :port)
    }

    actions = [{:next_event, :internal, :connect}]
    {:ok, :disconnected, data, actions}
  end

  def disconnected(:internal, :connect, data) do
    case :gen_tcp.connect(to_charlist(data.host), data.port, [:binary, active: true]) do
      {:ok, socket} ->
        data = %__MODULE__{data | socket: socket}
        {:next_state, :connected, data}

      {:error, reason} ->
        Logger.error("Disconnected from #{data.host}:#{data.port}: #{inspect(reason)}")
        # This is BAD! Let's use a timeout here.
        Process.sleep(10_000)
        actions = [{:next_event, :internal, :connect}]
        {:keep_state_and_data, actions}
    end
  end

  def connected(:info, {:tcp_closed, socket}, %__MODULE__{socket: socket} = data) do
    data = %__MODULE__{data | socket: nil}
    actions = [{:next_event, :internal, :connect}]
    {:next_state, :disconnected, data, actions}
  end
end
