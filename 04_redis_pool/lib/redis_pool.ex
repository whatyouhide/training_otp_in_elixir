defmodule RedisPool do
  use Supervisor

  @spec start_link(keyword()) :: {:ok, tuple()}
  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    connections = Keyword.get(opts, :connections, 5)
    connection_options = Keyword.get(opts, :connection_options, [])

    Supervisor.start_link(__MODULE__, {name, connections, connection_options}, name: name)
  end

  @spec connection(atom()) :: atom()
  def connection(name) do
    connections = :persistent_term.get({name, :connections})
    random_index = Enum.random(1..connections)
    connection_name(name, random_index)
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
