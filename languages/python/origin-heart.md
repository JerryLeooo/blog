# 也谈初心

## Flask 0.1 代码浅析

刚来公司的时候要求去看`Flask`的源代码，便Down了最新的来看。

<!--more-->
Flask项目文档一上来标题就是`What does Micro Mean`，但是在我看来，项目并非像我想象的那样`Micro`，源代码中最主要的`app.py`就有1800多行，更别提各种`helpers.py`和`ctx.py`。简而言之，这样的代码规模可能并不适合一个第一次阅读整个项目文档的程序员。后来听说Flask的最初版本不到700行，便找来这0.1版阅读，感觉思路比之前清晰很多。所以我想，在阅读代码之前，从最初版本开始，一个版本一个版本的推进，看看这个项目到底发生了哪些变化，似乎也是很好的一种学习手段。于是便在今天带来`Flask 0.1`版的代码分析，和各位一同探讨。

分析中略过了我认为不重要的东西，比如模板，flash之类的。

首先来看`Flask`这个类吧：

在这个类的最后，有这样的代码：

```
def __call__(self, environ, start_response):
    return self.wsgi_app(environ, start_response)
    
def wsgi_app(self, environ, start_response):
    with self.request_context(environ):
        rv = self.preprocess_request()
        if rv is None:
            rv = self.dispatch_request()
        response = self.make_response(rv)
        response = self.process_response(response)
        return response(environ, start_response)
```

`__call__`函数代表Flask类实例化之后是`可调用对象`。使用`Flask()`的时候，实质上调用的是`wsgi_app`这个函数。让我们来看看environ里面到底包含着什么吧。

我在`wsgi_app`这个函数里面加上了打印environ的语句，然后写了一个很简单的Flask应用 app.py ：
```
from flask import Flask
app = Flask(__name__)
app.run()
```

运行`python app.py`，访问`127.0.0.1：5000`，就可以在控制台看到下面的输出：

- ENVIRON：
```
wsgi.multiprocess False
SERVER_SOFTWARE Werkzeug/0.9.4
SCRIPT_NAME 
REQUEST_METHOD GET
PATH_INFO /
SERVER_PROTOCOL HTTP/1.1
QUERY_STRING 
werkzeug.server.shutdown <function shutdown_server at 0x1c44f50>
CONTENT_LENGTH 
HTTP_USER_AGENT Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/33.0.1750.152 Chrome/33.0.1750.152 Safari/537.36
HTTP_CONNECTION keep-alive
SERVER_NAME 127.0.0.1
REMOTE_PORT 37498
wsgi.url_scheme http
SERVER_PORT 5000
wsgi.input <socket._fileobject object at 0x1bf1f50>
HTTP_HOST 127.0.0.1:5000
wsgi.multithread False
HTTP_CACHE_CONTROL max-age=0
HTTP_ACCEPT text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
HTTP_RA_SID 7C41A302-20140506-070047-74d78d-f219cd
wsgi.version (1, 0)
wsgi.run_once False
HTTP_RA_VER 2.2.1
wsgi.errors <open file '<stderr>', mode 'w' at 0x7f8079b211e0>
REMOTE_ADDR 127.0.0.1
HTTP_ACCEPT_LANGUAGE zh-CN,zh;q=0.8
CONTENT_TYPE 
HTTP_ACCEPT_ENCODING gzip,deflate,sdch
```

- START_RESPONSE:
```
<function start_response at 0x1c62b18>
```

`wsgi_app`的一行`with self.request_context(environ)`涉及到一个函数和一个类：

```
def request_context(self, environ):
    return _RequestContext(self, environ)

```

```
class _RequestContext(object):
    def __init__(self, app, environ):
        self.app = app
        self.url_adapter = app.url_map.bind_to_environ(environ)
        self.request = app.request_class(environ)
        self.session = app.open_session(self.request)
        self.g = _RequestGlobals()
        self.flashes = None

    def __enter__(self):
        _request_ctx_stack.push(self)

    def __exit__(self, exc_type, exc_value, tb):
        if tb is None or not self.app.debug:
            _request_ctx_stack.pop()

```

先不关注细节（比如`app.url_map.bind_to_environ(environ)`和`app.request_class(environ)`），可以看到构建请求上下文在很多地方需要这个`environ`。暂且理解为使用这个环境信息构建了一个请求上下文吧。

继续，
```
if rv is None:
    rv = self.dispatch_request()
response = self.make_response(rv)
response = self.process_response(response)
return response(environ, start_response)
```
可以说是整个相应过程的一个抽象，让我们深入进去：

```
def dispatch_request(self):
    try:
        endpoint, values = self.match_request()
        return self.view_functions[endpoint](**values)
    except HTTPException, e:
        handler = self.error_handlers.get(e.code)
        if handler is None:
            return e
        return handler(e)
    except Exception, e:
        handler = self.error_handlers.get(500)
        if self.debug or handler is None:
            raise
        return handler(e)

```
可以看到如果不出现异常的话，会调用`view_functions`里面的某个函数来返回的是一个对象，可能是`response_class`对象，可能是一个`字符串`，也有可能是`tuple`。

`make_response`接受这个对象作为参数，产生一个`response`，然后使用`process_reponse`产生最终的相应函数，并用这个相应函数接受`environ`和`start_reponse`来产生真正的相应报文。修改`flask.py`，会看到最终返回的是一个`<werkzeug.wsgi.ClosingIterator object at 0x2e8e850>`，也就是`werkzeug`来处理这个响应。这个稍后去看`werkzeug`的文档。

稍微退一步，看看`process_response`函数，

```
def process_response(self, response):
    session = _request_ctx_stack.top.session
    if session is not None:
        self.save_session(session, response)
    for handler in self.after_request_funcs:
        response = handler(response)
    return response
```

`process_response`处理了`session`，然后执行每个`after_request_func`。

会看到一行`session = _request_ctx_stack.top.session`，这里有必要将`Flask`的几个全局变量来介绍一下：
```
_request_ctx_stack = LocalStack()
current_app = LocalProxy(lambda: _request_ctx_stack.top.app)
request = LocalProxy(lambda: _request_ctx_stack.top.request)
session = LocalProxy(lambda: _request_ctx_stack.top.session)
g = LocalProxy(lambda: _request_ctx_stack.top.g)
```
我们可以将`_request_ctx_stack`理解为一个栈，其中的每个元素会带有各种信息的一个_RequestContext对象，信息有`app`，`request`，`session`，`g`等等。
这些就是`请求上下文`，理解请求上下文，可以先理解`应用上下文`：
>应用上下文存在的主要原因是，在过去，没有更好的方式来在请求上下文中附加一堆函数， 因为 Flask 设计的支柱之一是你可以在一个 Python 进程中拥有多个应用。
那么代码如何找到“正确的”应用？在过去，我们推荐显式地到处传递应用，但是这 导致没有用这种想法设计的库的问题，因为让库实现这种想法太不方便。
解决上述问题的常用方法是使用后面将会提到的 current_app 代理，它被限制在当前请求的应用引用。 既然无论如何在没有请求时创建一个这样的请求上下文是一个没有必要的昂贵操作，那么就引入了应用上下文。


至于多线程，我想是在WebServer或者werkzeug来解决的。

浅层的分析就到这

---------------

深入来看下面的函数：

```
def add_url_rule(self, rule, endpoint, **options):
    options['endpoint'] = endpoint
    options.setdefault('methods', ('GET',))
    self.url_map.add(Rule(rule, **options))   

def url_for(endpoint, **values):
    return _request_ctx_stack.top.url_adapter.build(endpoint, values)
    
def route(self, rule, **options):                                        
    def decorator(f):
        self.add_url_rule(rule, f.__name__, **options)
        self.view_functions[f.__name__] = f
        return f
    return decorator

```
拿这个`add_url_rule`和最新版的Flask对比，会发现`add_url_rule`函数变化很大，首先旧版没有`view_function`这个参数，而是使用了`endpoint`的名字作为`view_function`

`endpoint`是一个路径，而`rule`是一个规则，所以就存在一个从`endpoint`到`rule`再到`view_func`的过程。比较最新版Flask，会发现endpoint和rule的意义互换了。至于为什么要多一层，就看看[这个](http://stackoverflow.com/questions/19261833/what-is-an-endpoint-in-flask)吧。

这个例子解释得很好，而且顺带还把蓝图的作用解释了：即一个应用分为不同模块，就要用到蓝图

```

def open_session(self, request):
    key = self.secret_key
    if key is not None:
        return SecureCookie.load_cookie(request, self.session_cookie_name,
                                        secret_key=key)

def save_session(self, session, response):
    if session is not None:
        session.save_cookie(response, self.session_cookie_name)
            
def match_request(self):
    rv = _request_ctx_stack.top.url_adapter.match()
    request.endpoint, request.view_args = rv
    return rv

```
