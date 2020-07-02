defmodule ETSTermsCache do
  use GenServer

  @name __MODULE__
  @ets __MODULE__
  @evict_interval 5_000

  defstruct []

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  @spec put(term(), term(), non_neg_integer()) :: :ok
  def put(key, value, ttl \\ :infinity) do
    if ttl == :infinity do
      GenServer.cast(@name, {:put, key, value, :infinity})
    else
      expires_at = System.system_time(:millisecond) + ttl
      GenServer.cast(@name, {:put, key, value, expires_at})
    end

    Process.sleep(100)
  end

  @spec get(term()) :: term()
  def get(key) do
    case :ets.lookup(@ets, key) do
      [{^key, value, _expires_at}] -> value
      [] -> nil
    end
  end

  @impl true
  def init(nil) do
    _ets = :ets.new(@ets, [:protected, :named_table, read_concurrency: true])
    Process.send_after(self(), :evict, @evict_interval)
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_cast({:put, key, value, expires_at}, state) do
    true = :ets.insert(@ets, {key, value, expires_at})
    {:noreply, state}
  end

  @impl true
  def handle_info(:evict, state) do
    now = System.system_time(:millisecond)

    # Generated in IEx with:
    # :ets.fun2ms(fn {key, val, expires_at} when expires_at < now -> true end)
    match_spec = [
      {{:_, :_, :"$1"}, [{:andalso, {:"/=", :"$1", :infinity}, {:<, :"$1", {:const, now}}}],
       [true]}
    ]

    _deleted_count = :ets.select_delete(@ets, match_spec)

    Process.send_after(self(), :evict, @evict_interval)

    {:noreply, state}
  end
end
