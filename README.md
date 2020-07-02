# OTP in Elixir

Upcoming training.

## Requirements

  * Elixir 1.10
  * Erlang/OTP 21 or later
  * [Docker](https://www.docker.com/get-started)
  * [Docker Compose](https://docs.docker.com/compose/install/)

## How to use this repository

This repo contains the source code for the [*OTP in Elixir*
training](http://www.elixirkyiv.club).

During the training, we'll live-code a lot of the source code available here,
but attendees will also be handed the full implementations for their reference.

During the training, we'll explore the following projects:

  * `01_concurrency_foundations` - covers solid foundations of concurrency in
    the BEAM. Spawning processes, sending and receiving messages, monitors,
    state loops.

  * `02_terms_cache` - covers a few ways of writing a *terms cache*, which is a
    process that can hold a key-value store of terms which are fast to store and
    retrieve. Starts with a single GenServer process, then adds TTL and cache
    eviction, and finally moves up to using an ETS table.

  * `03_redis_client` - covers a barebones Redis client that can connect to
    Redis and execute commands. Starts with a *blocking* client which can handle
    one request at a time and then moves to a non-blocking client. These are
    implemented as GenServers: the last step here is rewriting them as state
    machines by using `gen_statem`.

## Branches

The `main` branch contains the code we'll work on. It's mostly skeletons of
modules. The code that is in there is boilerplate or helpers that will save us
time during the training.

Should you want to peek at the "finished" code, the `complete` branch contains
the complete code. What we come up with during the training might slightly
differ from what's in the `complete` branch depending on how we go about
implementing stuff.
