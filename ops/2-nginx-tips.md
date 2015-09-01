- 将类似于 `*.example1.com` 重定向到 `*.example2.com` :
 
```
if ( $host ~* (\b(?!www\b)\w+)\.\w+\.\w+ ) {
    return 301 http://$1.zaih.com$request_uri;
}
```
参考：[Nginx 二级子域名完美方案](http://wangyan.org/blog/nginx-subdomain.html)

<!--more-->
- 设置网站文件根目录，避免写一大堆的alias：

```
location / {
    try_files $uri @app;
}

location @app {
    proxy_pass http://10.0.61.10:80;
}
```

当然要首先配置 `root` 这个变量，这样请求来临的时候，会先去查找对应的文件，找不到就回去走代理。

-----

最后是写脚本遇到的Python中的pytz：

[Python: How to get a value of datetime.today() that is “timezone aware”?](http://stackoverflow.com/questions/4530069/python-how-to-get-a-value-of-datetime-today-that-is-timezone-aware)

[pytz - World Timezone Definitions for Python](http://pytz.sourceforge.net/)
