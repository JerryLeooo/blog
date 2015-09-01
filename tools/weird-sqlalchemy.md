# 使用 SQLAlchemy 遇到的奇怪问题

在新公司开始负责新的小项目开发了，为了加快开发进度，采用了比较熟悉的前公司的技术栈，包括 Flask 和 SQLAlchemy。<!--more-->其中 Flask 由于和现有项目的 Mako Template 集成得不甚理想故而舍弃，只保留了 SQLAlchemy。在使用过程中，出现了一个比较奇怪的问题，就是在视图里面更新某个值后刷新页面，出现新值旧值交替出现的情况。由于之前用的数据库都是 PostgreSQL，未曾遇到此类问题，所以一时无从下手。还一度怀疑是自己的代码有问题，和别人商量了许久也没什么结果。

直到昨天，搜到了 Stackoverflow 上的两篇回答：[如何避免SQLAlchemy中的缓存](http://stackoverflow.com/questions/12108913/how-to-avoid-caching-in-sqlalchemy>)，[如何disable SQLAlchemy中的缓存](http://stackoverflow.com/questions/10210080/how-to-disable-sqlalchemy-caching)，都是 SQLAlchemy 作者亲自回答的。简单来问题说是和 MySQL 中的事务隔离机制有关，具体这方面的文档还需要读一下。

这其实是个小问题，但我的感想就是：如果在开发中遇到一个难题，知道如何用英语去描述它的话，有可能会很简单地就被解决掉。而且问题都不用去完全用英语描述，只需要提出关键词即可，比如这个问题的关键词就是 `MySQL`、`SQLAlchemy`、`cache`。使用关键词 Google 一下，问题的答案应该就在第一页。

嗯，收获就是用好搜索引擎。
