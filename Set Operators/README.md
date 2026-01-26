## Set Operators
Set operators are operators that combine rows from two query result 
sets (or multisets). Some of the operators remove duplicates from the 
result, and hence return a set, whereas others don't and hence return
a multiset.

T-SQL supports the following operators: 
	- UNION
	- UNION ALL
	- INTERSECT
	- EXCEPT

The general form of a query with a set operator is as  follows :
```
	Input Query1
	<set_operator>
	Input Query2
	[ORDER BY ...];
```

The SQL standard supports two "flavors" of each operator DISTINCT(the 
default) and ALL. The DISTINCT flavor eliminates duplicates and returns
a set. ALL doesn't attempt to remove duplicates and therefore returns a
multiset. All three operators in T-SQL support an implicit distinct version,
but only the UNION operator supports the ALL version. In terms of syntax, 
T-SQL doesn't allow you to specify the DISTINCT clause explicitly. Instead,
it's implied when you don't specify ALL. We'll provide alternatives to the 
missing INTERSECT ALL and EXCEPT ALL operators in the "The INTERSECT ALL".

### Summary
We covered the operators UNION,UNION ALL,EXCEPT,and INTERSECT. We understood
that SQL standard also supports operators called INTERSECT ALL and EXCEPT ALL
,and how to achieve the same in T-SQL. Lastly, we covered precedence among
set opertors, and also techniques to circumvent unsupported logical-query
processing phases by using table expressions.
