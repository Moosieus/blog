# `:gen_statem` in context

## Other resources and articles

### Official Erlang docs
- [gen_statem design principles](https://www.erlang.org/doc/design_principles/statem)
- [gen_statem module documentation](https://www.erlang.org/doc/man/gen_statem)

### Existing articles
- [State Machine in Elixir using Erlang’s gen_statem Behaviour](https://meraj-gearhead.ca/state-machine-in-elixir-using-erlangs-genstatem-behaviour) by Meraj Molla
- [State Timeouts with gen_statem](https://dockyard.com/blog/2020/01/31/state-timeouts-with-gen_statem) by Scott Hamilton
- [Persistent connections with gen_statem](https://andrealeopardi.com/posts/connection-managers-with-gen-statem/) by Andrea Leopardi (best tutorial)
- [Time-Out: Elixir State Machines versus Servers](https://potatosalad.io/2017/10/13/time-out-elixir-state-machines-versus-servers) by Andrew Bennett (best explanation of timeouts)
- [Implementing finite state machines with Erlang and gen_statem](https://www.davekuhlman.org/gen_statem-fsm-rules-implementation.html) by Dave Kuhlman

### Talks
https://www.youtube.com/results?search_query=gen_statem

## Foundations of `:gen_statem`
Elixir has processes. Each has its own isolated memory, and they communicate (or rather coordinate) by message passing.

`GenServer` is a behaviour of a server applied to a process. It's designed to be highly available:
- `GenServer`'s handle all messages they receive (none are left unanswered).
- Messages are handled in the order received (as opposed to *maybe-out-of-order*).

`:gen_statem` is an abstraction of a state machine atop `GenServer`. By specifying:
- The possible states a `GenServer` can be in
- What messages it can handle in what states
- How those messages transition our `GenServer` from one state to the next

We gain the following amenities:
- Postpone handling messages until your `GenServer` is in a state to handle them.
- Comprehensive and easy to use timeouts
- State enter calls which always perform some task when its state is entered
- Colocated callback functions for each state
- Easy to use internal messaging and handling

## When's it appropriate to use?
The official [`:gen_statem` behaviour docs](https://www.erlang.org/doc/design_principles/statem#when-to-use-gen_statem) provide guidance here, but I'd like to provide more concrete examples.

`:gen_statem` is ideal for organizing the possible states **your `GenServer` process can be in**, but not the possible states your **data can be in**.

The typical examples used to illustrate state machines (say a door that may be `:open` or `:closed`) aren't appropriate for `:gen_statem`. It'd be highly unusual to model a door as a process when a map would suffice:
```elixir
%{
  id: 1337,
  name: "Front Door",
  position: :closed # or :open
  handle: :locked # or :unlocked
  deadbolt: :locked, # or :unlocked
}
```

**In most cases, you should stick to modeling your domain logic as vanilla modules of [plain old data](https://en.wikipedia.org/wiki/Passive_data_structure) structures with pure functions and pattern matching.** Those modules should then be consumed by `GenServer`'s which are simpler and more flexible than `:gen_statem`'s. 

That withstanding, `:gen_statem` really shines in use-cases such as managing persistent connections, webserver sessions, and assembling packets. These use-cases all have a limited amount of states and all involve dealing with [data in motion](https://en.wikipedia.org/wiki/Data_in_transit).

## Tutorials
I consider Andrea Leopardi's [Persistent connections with gen_statem](https://andrealeopardi.com/posts/connection-managers-with-gen-statem/) the best tutorial as persistent connections are an ideal case for `:gen_statem`.

Andrew Bennett's [Time-Out: Elixir State Machines versus Servers](https://potatosalad.io/2017/10/13/time-out-elixir-state-machines-versus-servers) does an summarizing `:gen_statem`'s timeout mechanisms where the official docs struggle to be concise.

The [official design principles](https://www.erlang.org/doc/design_principles/statem) are otherwise comprehensive as are the [module docs](https://www.erlang.org/doc/man/gen_statem).

## Pitfalls

### Steep learning curve
The `:gen_statem` docs are very comprehensive but don't have a gentle learning curve.

### Several callback modes
`:gen_statem` has two possible callback modes, `:state_functions` and `:handle_event_function`, along with the `:state_enter` modifier:
- `def callback_mode(), do: :state_functions`
- `def callback_mode(), do: [:state_functions, :state_enter]`
- `def callback_mode(), do: :handle_event_function`
- `def callback_mode(), do: [:handle_event_function, :state_enter]`

Pretty much every tutorial uses a different permutation making hard to follow examples. I consider `:state_functions` preferable for its declarative syntax and explicitness compared to `:handle_event_function`, which groups everything under one callback.

`:state_enter` functions are useful when entering a state *always necessitates some work* but shouldn't be used by default. They can be difficult to follow and refactor when you have too many.

### Implicit syntax
Initially it can be difficult to follow `:gen_statem`'s syntax, specifically:
- The state-callback naming conventions.
- The returns, e.g `:next_state`, `:keep_state`, :`keep_state_and_data`, `:repeat_state`, and so on.
- The variety of possible [transition actions](https://www.erlang.org/doc/man/gen_statem#type-action).

The docs outline all of these, but it requires lots of jumping back and forth and a careful eye to translate.

### Lack of termination reports
By default Elixir won't log termination reports for modules using `:gen_statem`, but you can patch them in with [this translator from nostrum](https://github.com/Kraigie/nostrum/blob/master/lib/nostrum/state_machine_translator.ex). Add it with:
```elixir
Logger.add_translator({StateMachineTranslator, :translate})
```

A similar effect can be had by [setting `:handle_sasl_reports` to true](https://hexdocs.pm/logger/1.16.0/Logger.html#module-boot-configuration), but this logs lots of extra unecessary information that obfuscates your logs.

## How often is `:gen_statem` used?
The following are searches for invocations of `:gen_statem` and `GenServer` (at time of writing) across Elixir and Erlang repos on github (excluding forks and archives):
- [`GenServer` usage in Elixir](https://github.com/search?q=language%3AElixir++content%3A%22use+GenServer%22+NOT+is%3Afork+NOT+is%3Aarchived&type=code): ~21,000
- [`:gen_statem` usage in Elixir](https://github.com/search?q=language%3AElixir++content%3A%22%40behaviour+%3Agen_statem%22+NOT+is%3Afork+NOT+is%3Aarchived&type=code): 121
- [`gen_server` usage in Erlang](https://github.com/search?q=language%3AErlang%20%20content%3A%22-behaviour(gen_server)%22%20NOT%20is%3Afork%20NOT%20is%3Aarchived&type=code): ~16,000
- [`gen_statem` usage in Erlang](https://github.com/search?q=language%3AErlang++content%3A%22-behaviour%28gen_statem%29.%22+NOT+is%3Afork+NOT+is%3Aarchived&type=code): 624

For completeness one might also consider `:gen_statem`'s predecessor `:gen_fsm`:
- [`:gen_fsm` usage in Elixir](https://github.com/search?q=language%3AElixir++content%3A%22%40behaviour+%3Agen_fsm%22+NOT+is%3Afork+NOT+is%3Aarchived&type=code): 46
- [`gen_fsm` usage in Erlang](https://github.com/search?q=language%3AErlang++content%3A%22-behaviour%28gen_fsm%29.%22+NOT+is%3Afork+NOT+is%3Aarchived&type=code): 896

Calculating the ratios, we net some interesting results:
- ~173:1 `GenServer`'s to `:gen_statem`'s for Elixir.
- ~50:1 `GenServer`'s to `:gen_statem`'s for both languages.
- ~26:1 `gen_server`'s to `gen_statem`'s for Erlang.
- ~22:1 `GenServer`'s to `:gen_statem`/`:gen_fsm`'s for both languages.

As an interesting tidbit, [Joe Armstrong's 2003 PHD thesis](https://erlang.org/download/armstrong_thesis_2003.pdf) also breaks down some projects by behaviour. It's a comparatively small telecom adjacent sampling, landing at 122+56 `gen_server`'s to 1+10 `gen_fsm`'s, making a ratio of ~16:1.

Overall I'd say these results track with `:gen_statem` being useful for managing connections, and perhaps lacking first-class support in Elixir.

## Where is `:gen_statem` being used in Elixir?
The following is a sampling of a few popular open source libs and their respective modules that use `:gen_statem`:

#### [Blue Heron](https://github.com/search?q=repo%3Ablue-heron%2Fblue_heron%20%22%40behaviour%20%3Agen_statem%22&type=code) - a library for interfacing with low energy bluetooth devices.
- `BlueHeron.ATT.Client`
- `BlueHeron.HCI.Transport`
- `BlueHeron.Peripheral`

#### [elixir-ecto/db_connection](https://github.com/elixir-ecto/db_connection/blob/fa5f705fa5d272ed28b64ee0954e4275c0260d36/lib/db_connection/connection.ex#L22) - a db connection behaviour and pool for ecto.
- `DBConnection.Connection`

#### [Finch](https://github.com/sneako/finch/blob/109c3d27cec30811861ecc26f545e56c575aafab/lib/finch/http2/pool.ex#L4) - popular HTTP client built on Mint and Nimblepool.
- `Finch.HTTP2.Pool`

#### [Livebook](https://github.com/livebook-dev/livebook/blob/f9b4d3703e69c4f496f5fd49d8610d6c5c9ed6c3/lib/livebook/teams/connection.ex#L4) - Web app for collaborative Elixir notebooks.
- `Livebook.Teams.Connection`

#### [elixir-mongo/mongodb](https://github.com/elixir-mongo/mongodb/blob/96e213f7338a9c3952f5b85769c03c80616604bc/lib/mongo/session.ex#L32) - a MongoDB driver for Elixir.
- `Mongo.Session`

#### [Nostrum](https://github.com/search?q=repo%3AKraigie%2Fnostrum++%22%40behaviour+%3Agen_statem%22&type=code) - A library for interfacing with Discord's API with an emphasis on scaling.
- `Nostrum.Shard.Session`
- `Nostrum.Api.Ratelimiter`

#### [Postgrex](https://github.com/search?q=repo%3Aelixir-ecto%2Fpostgrex%20%3Agen_statem&type=code) - PostgreSQL driver for Elixir.
- `Postgrex.SimpleConnection`
- `Postgrex.ReplicationConnection`

#### [Supavisor](https://github.com/search?q=repo%3Asupabase%2Fsupavisor%20%22%40behaviour%20%3Agen_statem%22&type=code) - Cloud-native, multi-tenant Postgres connection pooler.
- `Supavisor.ClientHandler`
- `Supavisor.DbHandler`

#### [Xandra](https://github.com/search?q=repo%3Awhatyouhide%2Fxandra%20%22%40behaviour%20%3Agen_statem%22&type=code) - Fast, simple, and robust Cassandra/ScyllaDB driver for Elixir. 
- `Xandra.Connection`
- `Xandra.Cluster.Pool`
