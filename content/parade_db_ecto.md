%{
  title: "Putting a full power search engine in Ecto",
  description: "My diatribe about adding support for ParadeDB to Ecto",
  order_priority: 1
}
---
## Existing options for search
I'd like to start by briefly outlining the existing approaches to text search and their use-cases.

### Names and short strings
The first class of text search methods emphasize searching names and short strings. These include:
* **The `LIKE` and `ILIKE`** - Crude but sufficient operators for sub-string matching.
* **Levenstein Distance** - Measures the distance between words based on the number of character edits.
* **Soundex** - Made for matching similar sounding English names ([patented 1918](https://en.wikipedia.org/wiki/Soundex)).
* **Metaphone**  and **Double Metaphone** - Improved derivatives of Soundex.
* **Trigrams / `pg_tgrm`** - Measures the similarity of words based on 3-character segments.

These methods are ideal for searching names and short strings where misspellings, partial matches, and phonetic similarity are concerned. They aren't suitable for searcing longer passages.

### Postgres Full Text Search
Postgres' [Full Text Search](https://www.postgresql.org/docs/current/textsearch.html) is best characterized by its convenience-to-capability ratio. It accomodates basic document retrieval without the need to ETL your data to another service, but languishes in terms of capability and quality of results ranking.

### Search Engines
These are dedicated applications characterized by the following:
* Implement [BM25](https://en.wikipedia.org/wiki/Okapi_BM25) text search and ranking, the gold standard for ranking search results.
* Support a variety of data types that can be sorted and quickly queried.
* Make it easy to perform complex queries without incurring high performance overheads.
* Offer fast analytical features like facets, aggregates, and statistics.
* Use data structures expressly tailored for retrieving search results quickly.
* Providing autocomplete and spell checking for queries against indexed data.
* Offer some sort of horizontal scaling or sharding.

Incumbents in the search engine space are all based on the venerable [Apache Lucene](https://lucene.apache.org/) and run on the JVM:
* [Elasticsearch](https://www.elastic.co/elasticsearch)
* [OpenSearch](https://opensearch.org/) (fork of Elastic)
* [Apache Solr](https://solr.apache.org/)

A new wave of search engines are rising to prominence built [Tantivy](https://github.com/quickwit-oss/tantivy), which is written in Rust:
* [Meilisearch](https://www.meilisearch.com/) (simpler alternative to Elastic)
* [Quickwit](https://quickwit.io/) (focused on logs w/ object storage backing)

An increasingly prominent offer in search engines is "hybrid search", which combines BM25 results with semantic search results.

### The development cost of search engines
A major drawback of search engines is that they operate independently of your database:
* Your application must reflect any creation, update, or deletion in your database to your search engine.
* Small and large updates to search engines often necessitate different code paths. Small updates call incremental procedures whereas large updates often necessitate rebuilding and hot-swapping entire indexes.
* Dissonance often occurs when either system provides some query functionality you need to utilize in the same context.
* Your must manage deploying and hosting any search engine, in addition to your existing infrastructure.

*A fair amount of marketing and engineering effort goes into*

# Have your cake and eat it too
[ParadeDB](https://www.paradedb.com/) is a set of extensions that augments Postgres with pretty amazing search and analytical capabilities. In particular the `pg_search` extension embeds Tantivy directly into Postgres! This allows users to transparently derive search indexes from tables, and query them in PSQL, all with ACID guarantees!

This approach obviates a great deal of work with little compromise to functionality:
* Developers are no longer burdened with the need to sync or ETL data from the database to an external search engine.
* Search results are rows which compose fluently with SQL (`SELECT`, `JOIN`s, etc)
* It’s possible to scale search workloads with logical replications of Postgres.

# Bringing ParadeDB to Ecto
A few weeks ago, I began exploring what it’d take to support ParadeDB in Ecto. My primary goal was to figure out what it'd take, and what the developer experience would feel like. It's taken a fair amount of work, but I'm actually quite pleased with the quality of results!

```elixir
from(
  c in Call,
  search: boolean(%{
    must: parse(c, "transcript:ambulance"),
    should: [
      parse(c, "transcript:(ALS BLS)"),
      phrase(c.transcript, ["routine", "response"])
    ]
  }),
  preload: [:talk_group]
)
```

# Implementation Details
I’m continuing to build out support for ParadeDB in these forks of ecto and ecto_sql.

The necessary changes were beyond the scope of fragment, so I had to tentatively settle for forking and modifying ecto and ecto_sql directly.

# Help Wanted