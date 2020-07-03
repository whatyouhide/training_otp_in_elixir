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

  * `04_supervision_playground` - an almost-empty app that we'll use to play
    around with supervisors and supervision trees.

  * `05_redis_pool` - a small implementation of a pool built on top of
    [Redix](https://github.com/whatyouhide/redix), Elixir's Redis client. We'll
    use this to illustrate a supervisor used in a real-world scenario plus some
    nifty concepts like `:persistent_term`.

  * `06_phoenix_observer` - a boilerplate Phoenix app that we'll only use to run
    `:observer` and visually look at a complex supervision tree.

Then, there is some content that fits outside of our schedule and is provided as
additional resources to attendees:

  * `handrolled_genserver` - contains a hand-rolled and
    significantly-but-not-unbelievably simplified version of how the `GenServer`
    behaviour is implemented under the hood (in Erlang/OTP). Also contains a
    "stack" process (that you can push to and pop from) implemented on top of
    the hand-rolled GenServer-like behaviour.

  * `handrolled_supervisor` - similar to the GenServer idea, contains a *very*
    simplified version of a supervisor that can start a list of children and
    restart them (mimicking a `:one_for_one` strategy).

## Branches

The `main` branch contains the code we'll work on. It's mostly skeletons of
modules. The code that is in there is boilerplate or helpers that will save us
time during the training.

Should you want to peek at the "finished" code, the `complete` branch contains
the complete code. What we come up with during the training might slightly
differ from what's in the `complete` branch depending on how we go about
implementing stuff.

## Resources

  * Documentation for [`Task`](https://hexdocs.pm/elixir/Task.html), which we
    reimplemented parts of
  * Documentation for [`GenServer`](https://hexdocs.pm/elixir/GenServer.html),
    which is full of nice tips and things to learn
  * Documentation for [`ets`](http://erlang.org/doc/man/ets.html), equally dense
    of interesting stuff to read
  * [Erlang efficiency guide on
    processes](http://erlang.org/doc/efficiency_guide/processes.html#creating-an-erlang-process)
  * Two of my blog posts about connection processes in OTP:
    * <https://andrealeopardi.com/posts/handling-tcp-connections-in-elixir>
    * <https://andrealeopardi.com/posts/connection-managers-with-gen_statem>
  * Insightful post from Fred Hebert about what supervisors and restarts are
    meant for: [*It's about the
    guarantees*](https://ferd.ca/it-s-about-the-guarantees.html)
  * One of the best books to learn in depth about OTP and its design patterns:
    [*Designing for Scalability with
    Erlang/OTP](https://www.oreilly.com/library/view/designing-for-scalability/9781449361556/)
