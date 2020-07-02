defmodule ETSTermsCache do
  use GenServer

  @name __MODULE__
  @ets __MODULE__
  @evict_interval 5_000

  # State
  defstruct []

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link([] = _opts) do
    raise "not implemented yet"
  end

  @spec put(term(), term(), non_neg_integer()) :: :ok
  def put(key, value, ttl \\ :infinity) do
    raise "not implemented yet"
  end

  @spec get(term()) :: term()
  def get(key) do
    raise "not implemented yet"
  end
end
