```shell
nc -l 8000
```

```elixir
iex> {:ok, pid} = Connection.start_link(host: "localhost", port: 8000)
```
