defmodule Cache do
  use GenServer

  @name __MODULE__

  defstruct terms: %{}

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  @spec put(term(), term()) :: :ok
  def put(key, value) do
    GenServer.cast(@name, {:put, key, value})
  end

  @spec get(term()) :: term()
  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  @impl true
  def init(nil) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    terms = Map.put(state.terms, key, value)
    state = %__MODULE__{state | terms: term}
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, state) do
    value = Map.get(state.terms, key)
    {:reply, value, state}
  end
end
