# Process primitives

## Spawning

```elixir
iex> spawn(fn -> IO.puts("From another process") end)

iex> self()
iex> spawn(fn -> IO.puts("From another process: #{inspect(self())}") end)
```

## Sending messages

```elixir
iex> flush()

iex> send(self(), "Hello!")
iex> flush()

iex> pid = spawn(fn -> IO.puts("Hello from another process") end)
iex> send(pid, "Hello!")
```

## Receiving messages

```elixir
iex> receive do
...>   message -> IO.puts("Received message: #{inspect(message)}")
...> end

iex> pid = spawn(fn ->
...>   receive do
...>     message -> IO.puts("Received message: #{inspect(message)}")
...>   end
...> end)
iex> send(pid, {:a_number, 1})
```

## Parallel enum (each)

```elixir
iex> ParallelEnum.each(1..10, fn elem -> IO.inspect(elem) end)

iex> ParallelEnum.each(1..10, fn elem -> IO.puts("From #{inspect(self())}: #{inspect(elem)}") end)

iex> ParallelEnum.each(1..10, fn elem ->
...>   Process.sleep(Enum.random(1..50))
...>   IO.inspect(elem)
...> end)
```

## Async

Without timeout:

```elixir
iex> async_calculator = Async.execute_async(fn ->
...>   Process.sleep(30_000)
...>   42
...> end)
iex> Async.await_result(async_calculator)
```

With timeout:

```elixir
iex> async_calculator = Async.execute_async(fn ->
...>   Process.sleep(30_000)
...>   42
...> end)
iex> Async.await_result(async_calculator, 5_000)

iex> Async.await_result(async_calculator, 20_000)
```

## Async with crashing task (monitor)

```elixir
iex> async_calculator = Async.execute_async(fn ->
...>   42 / 0
...> end)
iex> Async.await_result(async_calculator, 5_000)
```
