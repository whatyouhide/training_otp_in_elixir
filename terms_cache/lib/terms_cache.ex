defmodule TermsCache do
  use GenServer

  @name __MODULE__
  @evict_interval 5_000

  defstruct terms: %{}

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
  end

  @spec get(term()) :: term()
  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  @impl true
  def init(nil) do
    Process.send_after(self(), :evict, @evict_interval)
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_cast({:put, key, value, expires_at}, state) do
    terms = Map.put(state.terms, key, {value, expires_at})
    state = %__MODULE__{state | terms: terms}
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case Map.fetch(state.terms, key) do
      {:ok, {value, _expires_at}} -> {:reply, value, state}
      :error -> {:reply, nil, state}
    end
  end

  @impl true
  def handle_info(:evict, state) do
    now = System.system_time(:millisecond)

    terms =
      for {key, {value, expires_at}} <- state.terms,
          expires_at != :infinity and expires_at >= now,
          into: %{},
          do: {key, {value, expires_at}}

    Process.send_after(self(), :evict, @evict_interval)

    state = %__MODULE__{state | terms: terms}
    {:noreply, state}
  end
end
