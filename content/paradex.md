%{
  title: "Paradex: A full power search engine in Ecto with ParadeDB",
  description: "Just use Postgres Just use Postgres Just use Postgres",
  image: "https://moosie.us/assets/paradex/mosquito_nf_mark_xiii.jpg.jpg"
}
---
<div style="display:flex;justify-content:center;">
  <img src="./assets/paradex/mosquito_nf_mark_xiii.jpg" alt="Mosquito PR MK XVI" style="margin-bottom: 2rem;">
  <!-- source: https://www.iwm.org.uk/collections/item/object/205211733 -->
</div>

## Introducing ParadeDB for the uninitiated

[ParadeDB](https://www.paradedb.com/) is an alternative to ElasticSearch built on Postgres. More technically, it's a trio of extensions that fulfill the same purpose:

* pg_search which embeds a BM25 full text search engine ([Tantivy](https://github.com/quickwit-oss/tantivy)), and extends SQL to allow for composing search queries.
* pg_analytics which embeds [DuckDB](https://duckdb.org/), allowing Postgres to query datalakes on S3 in formats like Parquet.
* [pgvector](https://github.com/pgvector/pgvector), a standalone extension which implements vector similarity search.

**It's all Postgres extensions! MWAHAHAHAHA**

### If you read my last blog post, I ought to explain what changed.

ParadeDB `0.11.0` dropped earlier this week with an [overhauled API](https://docs.paradedb.com/changelog/0.11.0) that's possible to support in Ecto with fragments. The change actually moves considerable complexity from database access layers (like Ecto) to ParadeDB's internals, while yielding improved query performance.

## Introducing Paradex

I've published a package called [Paradex](https://hexdocs.pm/paradex/readme.html) that provides Ecto fragments to for ParadeDB's search syntax. Altogether this makes for a really compelling search solution:

* There's no need to synchronize or Extract Transform & Load (ETL) data from Postgres to external services like ElasticSearch or Apache Solr.
* You can compose search queries like we would any other Ecto query, and leverage Ecto's query caching.
* The results of your search queries map to the Ecto schemas and associations you've already defined in your project. There's no need to marshall or re-query things from json.
* Changes to your search index can be handled in your existing migration workflow.

Here's an example from Paradex's test suite, along with a snippet of the query results:
```elixir
import Ecto.Query
import Paradex

alias ParadexApp.Call
alias ParadexApp.Repo

search = ~s'mechanical OR "broke down" OR "tow truck"'
min_length = 5
page_size = 15

from(
  c in Call,
  select: %{score: score(c.id), id: c.id, text: c.transcript, time: c.start_time},
  where: c.transcript ~> ^search,
  where: c.id ~> int4range("call_length", ^min_length, nil, "[)"),
  order_by: [desc: c.start_time],
  limit: ^page_size
)
|> Repo.all()
```

```elixir
[
  %{
    id: 23579,
    time: ~N[2024-10-11 10:42:48],
    text: "I'm 10-5 at Medical Center Drive in Great Seneca. There is an accident. They haven't blocked any of the roads yet, but they might have to block it once the tow truck is here. I'll just stick around.",
    score: 9.265514373779297
  },
  # times are far apart, so likely separate cases.
  %{
    id: 23104,
    time: ~N[2024-10-11 09:25:43],
    text: "Please, could you send the coordinator or someone? Are you broke down right before Watkins, ma'am?",
    score: 10.1517333984375
  },
  #...
]
```

Hybrid search is also possible with pgvector, which I've included a guide for [here](https://hexdocs.pm/paradex/hybrid_search.html).

## Conclusion

Overall I'm quite happy with the results! I think ParadeDB really offers an operationally simple alternative to ElasticSearch, and I'm impressed with what they've come to offer in just a year of operation. When combined with Ecto's capabilities, it makes for an especially cohesive search solution.
