%{
  title: "ParadeDB's new update is great for database access layers",
  description: "Also announcing Paradex for Ecto",
  image: "https://moosie.us/assets/paradex/mosquito_nf_mark_xiii.jpg"
}
---
<div style="display:flex;justify-content:center;">
  <img src="./assets/paradex/mosquito_nf_mark_xiii.jpg" alt="Mosquito PR MK XVI" style="margin-bottom: 2rem;">
  <!-- source: https://www.iwm.org.uk/collections/item/object/205211733 -->
</div>

## Introducing ParadeDB for the uninitiated

[ParadeDB](https://www.paradedb.com/) is an alternative to ElasticSearch built on Postgres. More technically, it's a trio of extensions that fulfill the same purpose:

* [pg_search](https://github.com/paradedb/paradedb/tree/dev/pg_search) which embeds a BM25 full text search engine ([Tantivy](https://github.com/quickwit-oss/tantivy)), and extends SQL to allow for composing search queries.
* [pg_analytics](https://github.com/paradedb/pg_analytics) which embeds [DuckDB](https://duckdb.org/), allowing Postgres to query datalakes on S3 in formats like Parquet.
* [pgvector](https://github.com/pgvector/pgvector), a standalone extension which implements vector data storage and similarity search.

**It's all Postgres extensions! MWAHAHAHAHA**

## Last week's update

ParadeDB `0.11.0` [dropped last week](https://docs.paradedb.com/changelog/0.11.0) with lots of improvements, including an overhauled API. The syntax is far more viable for database access layers (DBALs) to accomodate.

In my [prior attempt](https://moosie.us/parade_db_ecto) to support ParadeDB in Elixir, I had to completely fork [Ecto](https://github.com/elixir-ecto/ecto) to support search query composition. This is because previous versions of ParadeDB embedded search queries entirely in the `FROM` expression like so:
```sql
SELECT * FROM calls_search_idx.search(
  query => paradedb.boolean(
    must => ARRAY[
      paradedb.parse(field => 'transcript', value => 'mechanical OR "broke down" OR "tow truck"'),
      paradedb.range(field => 'call_length', range => int4range(5, NULL, '[)'))
    ]
  ),
  order_by_field => 'start_time',
  order_by_direction => 'desc',
  limit_rows => 15
);
```

Search queries had a very visible start with `call_search_idx.search(` and ending at `)`. This simplified parsing and planning but posed several downsides:

* The search query added a de facto `SEARCH` clause to PSQL, similar-to-but-distinct-from `WHERE`. DBALs were effectively responsible for providing composition for that `SEARCH` clause in addition to `WHERE` -- In fact, *I had to fork Ecto to quite literally implement a `search:` clause.*
* The `.search` function reimplemented bits of SQL with properties like `order_by_field` and `limit_rows`, which required special handling regardless of approach.
* While simple, this approach also precluded lots of potential optimizations the database could perform.

`0.11.0` resolves a lot of these issues with the overhauled syntax. In fact, the `.search()` syntax has been entirely removed. Here's a workalike query for comparison:
```sql
SELECT * FROM calls
WHERE
  calls.transcript @@@ 'mechanical OR "broke down" OR "tow truck"' AND 
  calls.id @@@ paradedb.range('call_length', int4range(5, NULL, '[)'))
ORDER BY calls.start_time DESC
LIMIT 15;
```

With this new API, ParadeDB's is much more involved with query planning and execution. The search expressions have all been moved to the `@@@` operator and embed fluently in the `WHERE` clause.

* Database access layers already compose `WHERE` clauses *(I hope)*, so the only overhead now is including ParadeDB's query functions and the `@@@` operator. *That's it! :D*
* Clauses like `ORDER BY` and `LIMIT` are now transparently pushed down to Tantivy when applicable.
* There's room for performance gains on orders of magnitudes. The new version's seen **up to 300x faster queries** in certain cases.

## Introducing Paradex

I've published a package called [Paradex](https://hexdocs.pm/paradex/readme.html) that provides [Ecto fragments](https://hexdocs.pm/ecto/Ecto.Query.html#module-fragments) for ParadeDB's search syntax. Altogether I think this makes for a really compelling search solution:

* There's no need to synchronize or Extract Transform & Load (ETL) data from Postgres to external services like ElasticSearch or Apache Solr.
* You can compose search queries like you would any other Ecto query, and leverage Ecto's query caching.
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

Overall I'm quite happy with the results! ParadeDB's operationally much more simple than ElasticSearch, and when combined with Ecto, a much more cohesive solution at that.

## Looking Forward

`0.11.0` has really opened up a grimoire of possibilities for ParadeDB, and I'm excited to see the project close the gaps in capabilities with ElasticSearch, especially with analytical queries.

I hope ORMs and DBAL contributors in other languages will look into supporting ParadeDB, especially now that the amount of work necessary has been significantly reduced. Heck, my entire implementation's [a single file](https://github.com/Moosieus/paradex/tree/main/lib) of trivial macros.

On a final note, I really think Postgres is the best database for most software service businesses operating today. Technical decision makers would do well to evaluate Postgres' capabilities before introducing multiple disparate storage technologies:

* If you need a key-value store, look at [hstore](https://www.postgresql.org/docs/current/hstore.html). Ruby on Rails 8 [won't even ship with Redis](https://fly.io/ruby-dispatch/the-plan-for-rails-8/#less-moving-parts-in-production) b/c databases on NVME SSDs are fast enough.
* If you need to store JSOn documents, check out Postgres [JSON Types](https://www.postgresql.org/docs/current/datatype-json.html) and the new `JSON_TABLE` feature in [Postgres 17](https://www.postgresql.org/about/news/postgresql-17-released-2936/).
* If you need a columnar database for lakehouse analytics, consider ParadeDB and [pg_analytics](https://github.com/paradedb/pg_analytics).
* If you need a search engine, *see the above article!*
* If you need a vector store and similarity search, [pgvector](https://github.com/pgvector/pgvector) has you covered.
* For graph data, I don't have as great an answer until [Property Graph Queries](http://peter.eisentraut.org/blog/2023/04/04/sql-2023-is-finished-here-is-whats-new#property-graph-queries) drop in Postgres.

## Further Reading

A few months ago, database luminaries Michael Stonebraker and Andrew Pavlo published [What Goes Around Comes Around... And Around...](https://db.cs.cmu.edu/papers/2024/whatgoesaround-sigmodrec2024.pdf) They don't pull any punches, so if you're a fan of Hadoop or MongoDB, probably don't read this.
