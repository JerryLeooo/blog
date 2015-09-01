title: Flask + Gunicorn 部署一例
date: 2014-09-09 19:58:07
categories: Notes
layout: post
tags:
- Flask
- Gunicorn
- Nginx
- Supervisor
- 部署
- Web Development

------

众所周知`Python`和`PHP`的部署难度不是一个量级，这里贴出我的一个基于`Flask`的个人项目的各种配置，也算做个笔记。系统是`Ubuntu 14.04`。

<!--more-->
## Nginx配置

```
upstream pagetalks {
  server unix:/tmp/gunicorn.sock fail_timeout=0;
}

server{
  listen 80;
  server_name pagetalks.net;

  root /home/pagetalks/pagetalks;
  access_log /home/pagetalks/logs/access.log;
  error_log /home/pagetalks/logs/error.log;

  location /static {
    alias /home/pagetalks/pagetalks/static;
    autoindex on;
    expires max;
  }

  location / {
    proxy_set_header X-Forworded_For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    if (!-f $request_filename){
      proxy_pass http://pagetalks;
      break;
    }
  }
}

```

## Gunicorn启动脚本

个人感觉`Gunicorn`比用`uWSGI`简单一些。

```
#! /bin/bash

gunicorn app:app \
--chdir /home/pagetalks/pagetalks \
--bind unix:/tmp/gunicorn.sock \
-w 3 -k gevent \
--access-logfile /home/pagetalks/logs/gunicorn_access.log \
--error-logfile /home/pagetalks/logs/gunicorn_error.log

```

所对应的目录树：

```
.
├── gunicorn_start
├── pagetalks
│   ├── app.py
│   ├── models
│   │   ├── ...
│   ├── templates
│   │   ├── ...
│   └── views
│       ├── ...
└── requirements.txt

```

其中的`app.py`中的`app`一定要是一个`WSGI Callable Object`，具体可参见`Gunicorn`文档。

## Supervisor配置

使用`Supervisor`的目的在于在`Gunicorn`挂了的情况下可以自动将其重启。

```
[program:pagetalks]
user=root
command=bash /home/pagetalks/gunicorn_start
autorestart=true
stdout_logfile=/home/pagetalks/logs/gunicorn_supervisor.log
```

在配置`Supervisor`的时候遇到了一个大坑，就是在`Gunicorn`的启动脚本里面加上了`-D`参数，也就是使`Gunicorn`运行在daemon模式。对于`Supervisor`来说，运行在daemon模式的程序由于没有反馈，会被认为没有启动成功，从而不断将其启动，最终就会报错。所以使用`Supervisor`启动的那个程序一定不要运行在daemon模式。

最后欢迎大家使用我的[Digital Ocean Referal](https://www.digitalocean.com/?refcode=c2a681ff8310)，以使这个小小的个人项目多活一段时间。
