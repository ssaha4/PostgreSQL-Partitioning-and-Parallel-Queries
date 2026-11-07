# PostgreSQL Partitioning and Parallel Queries

PostgreSQL and Python implementations for partitioning movie ratings, querying partitions, and implementing range-based sort and join. The repository also documents a separate Spark SQL project on spatial analysis of NYC taxi trips.

| Project | What it covers |
| --- | --- |
| [Movie ratings schema](sql/schema.sql) and [SQL analytics](sql/analytics-and-recommendations.sql) | A relational schema for movies, users, ratings, tags, and genres. SQL queries compute genre and rating statistics and recommend unseen movies using a weighted score based on movie-rating similarity. |
| [Horizontal partitioning](movie-ratings-partitioning/Interface.py) | Bulk-load ratings, create range and round-robin partitions, and route new ratings to the base table and the appropriate partition. |
| [Partition-aware queries](partition-queries/Interface.py) | Evaluate inclusive rating ranges and exact rating lookups against both partition layouts. |
| [Parallel sort and join](parallel-sort-join/Assignment3_Interface.py) | Divide numeric keys into five ranges and use Python worker threads to prepare PostgreSQL tables for sorting and joining. |
| [Spark SQL spatial analysis](spark-spatial/README.md) | Project notes on point-in-rectangle queries, distance queries and joins, and taxi pickup hotspot analysis. |

## Partitioning and querying movie ratings

**Range partitioning** groups rows by rating value. With five partitions covering ratings from 0 to 5, the intervals start with `[0, 1]` and continue with `(1, 2]`, `(2, 3]`, and so on. For a lookup such as `rating BETWEEN 1.5 AND 3.5`, the query reads the partition metadata and only scans tables whose intervals can overlap the filter.

**Round-robin partitioning** distributes consecutive rows across partition tables in rotation. This spreads rows across tables independently of rating. A rating-based lookup therefore scans every round-robin partition. The query implementation writes the partition name alongside each matching row so readers can see where it was found. The included [sample output](partition-queries/Sample%20Output.txt) shows the result format.

The [standalone partitioning interface](movie-ratings-partitioning/Interface.py) and the [partition query harness](partition-queries/Assignment1.py) use different table names. Use the harness in `partition-queries/` when running the point and range queries because it builds the corresponding metadata tables.

## Parallel sort and equi-join

- **Sort.** Read the minimum and maximum sort key, split the key domain into five ranges, and use a worker per range to materialize rows using SQL `ORDER BY`. The coordinator waits for workers and inserts the resulting rows into the output table in range order. Use `ORDER BY` when reading the output because PostgreSQL does not guarantee table scan order.
- **Join.** Compute common key bounds across both input tables and give them identical partition boundaries. Equal keys then fall into matching ranges, so the coordinator only joins corresponding partition pairs. For example, every row with movie ID 42 lands in the same key range on both sides. Workers prepare the partitions, and the coordinator executes the partition-local SQL joins and drops the intermediate tables.

Both experiments use one PostgreSQL instance and share a connection across the Python workers. The threaded interface illustrates how to decompose the work, and the shared connection limits concurrent database execution. Equal-width ranges can also be imbalanced when keys cluster. The archived implementation rounds range widths, which can exclude upper-end keys for some input ranges. Use explicit result checks against a direct SQL sort or join when experimenting with new inputs.

## Running the PostgreSQL examples

The archived Python scripts target Python 2.7 and use `psycopg2`. The SQL examples can be inspected independently. For the SQL scripts, create an empty database, run `sql/schema.sql`, load compatible movie and ratings data, and run `sql/analytics-and-recommendations.sql` with a valid numeric user ID supplied as the `psql` variable `v1`.

The included Python testers expect a disposable local database and may delete tables. Review their local connection settings before running them. Use the working directory of each tester and supply these inputs.

| Tester | Expected input |
| --- | --- |
| `partition-queries/tester-1.py` | `test_data.txt` with `user_id::movie_id::rating::timestamp` rows |
| `parallel-sort-join/tester.py` | `ratings.dat` in the same ratings format and `movies.dat` with `movie_id_title_genres` rows, where underscores separate the three fields |

The original top-level scripts are also available for existing links. The Spark work is documented separately because the archive contains a report for it.

The code should not be used for academic dishonesty or submitted as coursework.
