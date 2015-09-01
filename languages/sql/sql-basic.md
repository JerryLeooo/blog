# 《SQL必知必会》读书笔记

## 不同的SQL JOIN

- __INNER JOIN__: Returns all rows when there is at least one match in BOTH tables
- __LEFT JOIN__: Return all rows from the left table, and the matched rows from the right table
- __RIGHT JOIN__: Return all rows from the right table, and the matched rows from the left table
- __FULL JOIN__: Return all rows when there is a match in ONE of the tables

<!--more-->

[PostgreSQL文档上的例子](http://www.postgresql.org/docs/9.1/static/queries-table-expressions.html)，将这几种JOIN类型用例子很清楚地解释了。平时__INNER JOIN__最为常见。


平时较少使用__ALTER__，在这里做个总结：

```
ALERT ... ADD ... # 添加一列
ALERT ... DROP ... # 删除一列
```

## SQL中索引的作用

索引改善了检索操作的性能，但降低了数据插入，修改和删除的性能。在知性这些操作时，DBMS必须动态地更新索引。

## SQL中的触发器相当于钩子

如将某字段全部转换为大写
