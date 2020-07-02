defmodule Stack do
  @behaviour HandrolledGenServer

  require Logger

  ## Public API

  def start_link(initial_stack) do
    HandrolledGenServer.start_link(__MODULE__, initial_stack)
  end

  def push(pid, elem) do
    HandrolledGenServer.cast(pid, {:push, elem})
  end

  def pop(pid) do
    HandrolledGenServer.call(pid, :pop)
  end

  @impl true
  def init(stack) do
    stack
  end

  @impl true
  def handle_cast({:push, elem}, stack) do
    [elem | stack]
  end

  @impl true
  def handle_call(:pop, [elem | stack]) do
    {elem, stack}
  end

  @impl true
  def handle_info(message, stack) do
    _ = Logger.error("Received unknown message: #{inspect(message)}")
    stack
  end
end
