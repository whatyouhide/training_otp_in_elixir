defmodule SharedState do
  ## Public API

  @spec start(term()) :: pid()
  def start(_initial_state) do
    raise "not implemented yet"
  end

  @spec get(pid()) :: term()
  def get(_pid) do
    raise "not implemented yet"
  end

  @spec update(pid(), (term() -> term())) :: :ok
  def update(_pid, update_fun) when is_function(update_fun, 1) do
    raise "not implemented yet"
  end

  ## Process loop
end
