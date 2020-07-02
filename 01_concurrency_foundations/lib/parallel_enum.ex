defmodule ParallelEnum do
  @compile {:no_warn_undefined, Async}

  def each(enum, fun) do
    Enum.each(enum, fn element ->
      spawn(fn ->
        fun.(element)
      end)
    end)
  end

  # After having made Async stuff
  def map(enum, fun) do
    enum
    |> Enum.map(fn element ->
      Async.execute_async(fn -> fun.(element) end)
    end)
    |> Enum.map(fn async_process ->
      Async.await_result(async_process)
    end)
  end
end
