defmodule ParallelEnum do
  @compile {:no_warn_undefined, Async}

  def each(_enum, _fun) do
    raise "not implemented yet"
  end

  def map(_enum, _fun) do
    raise "not implemented yet"
  end
end
