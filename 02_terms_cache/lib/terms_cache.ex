defmodule TermsCache do
  use GenServer

  @name __MODULE__
  @evict_interval 5_000

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link([] = _opts) do
    raise "not implemented yet"
  end

  @spec put(term(), term(), non_neg_integer()) :: :ok
  def put(_key, _value, _ttl \\ :infinity) do
    raise "not implemented yet"
  end

  @spec get(term()) :: term()
  def get(_key) do
    raise "not implemented yet"
  end
end
