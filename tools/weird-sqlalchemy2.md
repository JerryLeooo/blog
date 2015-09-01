# SQLAlchemy – MySQL has gone away

解决了前一篇文章的问题之后，又再次遇到了 MySQL has gone away 的问题，<!--more-->[这篇文章](https://mofanim.wordpress.com/2013/01/02/sqlalchemy-mysql-has-gone-away/)讲的很透彻。简单来说，就是长时间不连接MySQL，MySQL就会将这个连接关掉。在 Flask 中的解决方案就是：

```
from yourapplication.database import db_session

@app.teardown_appcontext
def shutdown_session(exception=None):
    db_session.remove()
```

来手动将 session 移除。但是在古老的 Quixote 中，并没有这样的装饰器，因此需要自己实现一个 MiddleWare。

MiddleWare 需要实现 WSGI 协议，最终的代码如下：

```
from models.base import session

class wsgi_app(object):

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        r = self.app(environ, start_response)
        self.after_request()
        return r

    def after_request(self):
        session.remove()
```

关于 WSGI 的参考：

[WSGI.org](https://wsgi.readthedocs.org/en/latest/)
[WSGI接口](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/001386832689740b04430a98f614b6da89da2157ea3efe2000)
