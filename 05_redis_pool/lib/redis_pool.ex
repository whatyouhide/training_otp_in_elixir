defmodule RedisPool do
  use Supervisor

  @spec start_link(keyword()) :: {:ok, tuple()}
  def start_link(opts) do
    pool_name = Keyword.fetch!(opts, :name)
    connections = Keyword.get(opts, :connections, 5)
    connection_options = Keyword.get(opts, :connection_options, [])

    Supervisor.start_link(__MODULE__, {pool_name, connections, connection_options},
      name: pool_name
    )
  end

  @spec command(atom(), Redix.command()) :: {:ok, term()} | {:error, term()}
  def command(pool_name, command) when is_list(command) do
    connections = :persistent_term.get({pool_name, :connections})
    random_index = Enum.random(1..connections)
    Redix.command(connection_name(pool_name, random_index), command)
  end

  @impl true
  def init({name, connections, connection_options}) do
    :persistent_term.put({name, :connections}, connections)
    children = build_child_specs(name, connections, connection_options)
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp build_child_specs(name, connections, connection_options) do
    for index <- 1..connections do
      options = Keyword.put(connection_options, :name, connection_name(name, index))
      child_spec = {Redix, options}
      Supervisor.child_spec(child_spec, id: {Redix, index})
    end
  end

  defp connection_name(name, index) do
    Module.concat(name, :"Conn#{index}")
  end
end
