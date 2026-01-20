## Table Expressions

Table expressions can help you simplify code, improve its maintainability,
and encapsulate querying logic. When you need to use table expressions and
are not planning to reuse their definitions, use derived tables or CTEs.

CTEs have a couple of advantages over derived tables;
	- They are easer to maintain because you do not nest them like you do 
	  derived tables.
	- Also, you can refer to multiple instances of the same CTE, which you
	  cannot do with derived tables.

When you need to define reusable table expressions, use views or inline TVFs.
When you do not need to support input parameters, use views; otherwise, use
inline TVFs.

Use the APPLY operator when you want to apply a correlated table expression
to each row from a source table and unify all result sets into one result
table.