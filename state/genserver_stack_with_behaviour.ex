defmodule Stack do
  @behaviour HandrolledGenServer

  ## Public API

  def start do
    HandrolledGenServer.start(__MODULE__, _initial_state = [])
  end

  def push(pid, element) do
    HandrolledGenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
    HandrolledGenServer.call(pid, :pop)
  end

  ## Callbacks

  @impl true
  def handle_cast({:push, element}, state) do
    [element | state]
  end

  @impl true
  def handle_call(:pop, [element | rest]) do
    {element, rest}
  end
end
