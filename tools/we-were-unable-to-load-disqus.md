# 关于Pelican上Disqus无法工作问题的解决

将 Github Pages 博客程序从`Octopress`切换到`Pelican`后，`Disqus`的评论功能一直就不正常。在本该出现评论的地方，会报“We were unable to load Disqus.”。官方对于这个问题的[解释](https://help.disqus.com/customer/portal/articles/472007-i-m-receiving-the-message-%22we-were-unable-to-load-disqus-%22)也看不出什么所以然来。昨天经过一番努力，终于解决，记录一下。

<!--more-->
如果只解决问题的话，你只需要做以下两件事：

1. 将`pelicanconf.py`中的`DISQUS_SITENAME`设置正确;

2. 将`pelicanconf.py`中的`RELATIVE_URLS`设置成`False`。

这样还是不行的话，再将SITEURL设置一下，就绝对没有问题了。

-----

这个问题困扰了我很久，最后没有办法只好将问题报告给了Disqus官方。Disqus的Email回复的很明确：
>Hi Whilgeek,

>Thanks for reaching out to us. 

>Disqus requires a unique absolute URL to create a new thread, so it appears that the invalid and relative URL being used as the disqus_url variable is preventing Disqus from being able to successfully create a thread on that page.

>You can see this variable highlighted below. For this page, the disqus_url should be “http://whilgeek.github.io/posts/2014/04/how-to-rebase-a-pull-request/”, however it is as appears here: 
https://www.dropbox.com/s/6j8xr51rb6lqeiw/Screenshot%202014-06-30%2013.53.04.png

>Try amending the disqus_url variables to correct absolute URLs, and the threads should load correctly:
https://help.disqus.com/customer/portal/articles/735170-how-can-i-update-discussion-urls-

>Best, 
-Ryan

就是说，Disqus需要一个唯一的绝对路径来创建线程，而在Pelican创建的配置文件当中，却是默认以相对路径来表示每个页面的URL的，所以才会出现Disqus无法加载的问题。所以，如果你的Disqus也在报“We were unable to load Disqus.”，不妨打开生成的HTML文件，查找`disqus_url`关键字，看是否是一个相对路径，如果是的话，参照上面的解决方案即可。

不过这样设置的话，发现会出现本地无法预览的问题，不过这个对于我来说并不是太要紧的问题。

另外，发现`Pelican`在使用`Fabric`作为部署工具，由于最近正在接触，所以倍感亲切。

UPDATE: 2015-06-15 现在已经将博客迁移到Hexo上了，并且再次出现了这样的问题，其实有更简单的解决方法，就是打开Chrome浏览器的调试窗口，看报错信息，以发现哪里的问题。
