%{
  title: "Paradex: A full power search engine in Ecto with ParadeDB",
  description: "Just use Postgres Just use Postgres Just use Postgres",
  image: "https://moosie.us/assets/paradex/mosquito_nf_mark_xiii.jpg"
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

### If you read my [last blog post](https://moosie.us/parade_db_ecto) on this subject, I ought to explain what's changed.

<div style="text-align:center">
  <img src="./assets/paradex/hn_screenshot.png" alt="Quite interesting, except the fork aspect.">
  <figcaption  style="margin-bottom: 2rem;">source: <a href="https://news.ycombinator.com/item?id=41818495">HN</a></figcaption>
</div>

ParadeDB `0.11.0` dropped earlier this week with an [overhauled API](https://docs.paradedb.com/changelog/0.11.0). Prior to this version, ParadeDB's search queries embedded in the `FROM` expression like so:
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

This approach simplified ParadeDB's query planning. Its Duties began at `call_search_idx.search(` and ended with the closing `)`. The surrounding SQL query nominally wrapped the results returned from Tantivy. This approach was simple, but imposed several limitations:

* This syntax effectively placed an onus on database access layers to construct a de facto `SEARCH` clause.
  * This is why my prior work on ParadeDB had to start with a forking Ecto. I'm glad to announce this is no longer the case -- more on that momentarily.
* The `.search` function had to reinvent bits of SQL that already existed like with the `order_by_field` and `limit_rows` properties.
* While simple, the approach precluded lots of potential optimizations the database could perform.

Here's the overhauled syntax for comparison:
```sql
SELECT * FROM calls
WHERE
  calls.transcript @@@ 'mechanical OR "broke down" OR "tow truck"' AND 
  calls.id @@@ paradedb.range('call_length', int4range(5, NULL, '[)'))
ORDER BY calls.start_time DESC
LIMIT 15;
```

With this new API, ParadeDB's is much more involved with query planning and execution. The search expressions have all been moved to the `@@@` operator, and embed fluently within the `WHERE` clause.

* Database access layers already universally support composing `WHERE` clauses, so the only overhead for them now is supporting ParadeDB's query functions and the `@@@` operator (more on this in regards to Ecto later).
* Clauses like `ORDER BY` and `LIMIT` are now transparently pushed down to Tantivy when applicable.
* There's room for optimization on the scale of magnitudes. The new version's seen up to **300x faster queries** in certain cases.

Overall this is an extremeley weclome change, and I hope the reduced overhead encourages more database access layers to add support for ParadeDB.

## Introducing Paradex

As mentioned above, the ParadeDB makes use of Postgres' existing clauses (`WHERE`, `LIMIT`, `ORDER BY`, etc) which Ecto already composes today. Therefore we just need to define the bits of the query syntax Ecto doesn't have already. (todo: explain fragments)

I've published a package called [Paradex](https://hexdocs.pm/paradex/readme.html) that provides Ecto fragments for ParadeDB's search syntax. Altogether this makes for a really compelling search solution:

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

* I think the ParadeDB team is making the right choices in terms of technology, licensing (AGPL 3.0), and business growth.

* Right now ParadeDB still falls short of ElasticSearch in a few ways, but given their progress up to this point, I forsee the gap quickly narrowing.

* A few months ago, database luminaries Michael Stonebraker and Andrew Pavlo published one of the most [**out for blood**](https://db.cs.cmu.edu/papers/2024/whatgoesaround-sigmodrec2024.pdf) techincal papers I've ever read. It starts with a victory lap from Stonebraker having successfully forecasted the success of relational databases, and goes on to critique the current database landscape. (todo: maybe pick up here.)
