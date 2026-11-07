# NYC Taxi Trip Spatial Analysis with Spark SQL

The project used Apache Spark and Scala to query spatial records and analyze taxi pickup concentrations. The original environment used Spark 2.4.5, Scala 2.11, Java 8, and sbt. This page summarizes the archived project report. The Scala source and taxi dataset were absent from the archive.

## Spatial predicates and queries

| Operation | How it works |
| --- | --- |
| Range query | Apply `ST_Contains` to select points inside a specified rectangle. |
| Range join | Match points to rectangles by applying the containment predicate to both inputs. |
| Distance query | Apply `ST_Within` to select points within a threshold distance of a reference point. |
| Distance join | Apply `ST_Within` to pairs of points from two inputs and retain pairs that satisfy the threshold. |

`ST_Within` compares the Euclidean distance between two coordinate pairs with the supplied threshold. For example, the points `(0, 0)` and `(3, 4)` are five coordinate units apart, so a threshold of five includes the pair. The calculation works in the input coordinate system. Longitude and latitude used directly yield distances in coordinate units.

## Hotspot analysis

**Hot-zone analysis** counts pickup points inside geographic rectangles and ranks the areas by their counts. **Hot-cell analysis** examines spatial and temporal neighborhoods to identify cells with statistically significant concentrations of activity.

I implemented the `ST_Within` predicate and the distance query and distance join in the first phase. I also tested the hotspot analysis in the second phase.
