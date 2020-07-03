defmodule RedisPool do
  use Supervisor

  @spec start_link(keyword()) :: {:ok, tuple()}
  def start_link(opts) do
    pool_name = Keyword.fetch!(opts, :name)
    connections = Keyword.get(opts, :connections, 5)
    connection_options = Keyword.get(opts, :connection_options, [])

    raise "we need to start the supervisor"
  end

  @spec command(atom(), Redix.command()) :: {:ok, term()} | {:error, term()}
  def command(pool_name, command) when is_list(command) do
    raise "not implemented yet"
  end
end
