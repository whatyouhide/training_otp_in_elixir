defmodule RollingAverage do
  use GenServer

  defstruct [:list, :max_size]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def add_element(pid, element) do
    GenServer.cast(pid, {:add_element, element})
  end

  def average(pid) do
    GenServer.call(pid, :average)
  end

  ## Callbacks

  @impl true
  def init(opts) do
    max_size = Keyword.fetch!(opts, :max_size)
    {:ok, %__MODULE__{list: [], max_size: max_size}}
  end

  @impl true
  def handle_cast({:add_element, element}, state) do
    new_list =
      if length(state.list) < max_size do
        [element | state.list]
      else
        [element | Enum.drop(state.list, -1)]
      end

    {:noreply, new_list}
  end

  @impl true
  def handle_call(:average, state) do
    Enum.sum(state.list) / length(state.list)
  end
end
