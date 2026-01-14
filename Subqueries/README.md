# Subqueries
We covered subqueries discussing the types:
 - Self-contained subqueries, which are independent of their outer queries
 - Correlated subqueries, which are dependent on their outer queries

In regards to the results of subqueries we focused on:
 - Scalar, returns single values
 - Multivalued Subqueries, retuns multiple values

We also covered on returning previous and next values, using running aggregates,
and dealing with misbehaving subqueries.

**Note**: Always think about the three-valued logic and the importance of prefixing
a column in subqueries with the source table alias.