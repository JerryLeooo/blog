title: 第一次使用Django进行开发的经历
date:  2014-01-23 21:42:57
categories:
- Notes
tags:
- Django
- Python
- Web Development

------

　　学习Python和Django已经有一段时间了，我一直比较喜欢 **learn by example** 的学习方式，所以希望能找点别人写的例子看看。经过搜索，发现了[这个不错的网站](http://pythontip.sinaapp.com/)。在这个网站上，有个[挑战Python](http://pythontip.sinaapp.com/)的页面做得非常不错，很少有这种可以用Python提交代码的中文OJ。玩了一会OJ，发现就有一点不是很好：如果不贡献题目的话，可以浏览别人的提交，却是无法进行搜索的。这样就有两个**弊端**：1，某个题我做出来了，但是感觉自己代码写得很笨，没法学习别人怎么写；2.某个题我一直没有思路，想寻找点启发，也是不行。其实我觉得站长同学或许可以学习以下[南阳理工ACM](acm.nyist.net)的做法，即某题AC之后就可以查看其他人在这题提交的代码。当然我觉得最好的方法还是大家能多多向站长同学贡献题目，目前题目确实有些偏少，而这又是个很好的项目。

<!--more-->
　　由于学了Django，迫切想写个东西练手，便有了个 idea ：抓取所有的提交数据，建立自己的数据库，从自己的页面上进行搜索。思路很简单，开始干。

　　抓取数据的情况和上次写那个用PHP从学校教务抓取教室占用信息很类似，都是发送请求得到HTML页面，然后对HTML页面进行解析。由于学了Python，当然要用这种新语言试试。经过分析，发现情况比上次简单许多：上次需要用户登录，并模拟浏览器保留Cookie，而这个网站浏览的时候不要求是登录用户，所以只需简单发送GET请求即可。本来这个抓取数据的功能写到一个脚本里面即可，不用作为网站的一部分，但是由于我不是很喜欢写SQL，而Django里面的模型可以生成SQL，就将获取数据的操作写到了一个视图里面。一切看起来很简单，直到我遇到了一个齐天大坑 ------ 中文字符编码。

　　上次用PHP也是遇到了这样的大坑，好在当时需要的数据只是楼号教室号之类的东西，都是数字，就蒙混过关了。这次需要存取title，没法蒙混了。抓取数据的getdata页面一直在报“Incorrect string value: '\xE6\x8E\x92\xE5\xBA\x8F' for column 'title' at row 1”的警告。由于用了urllib2和BeautifulSoup来抓取并解析数据，所以一开始以为是这两个库的错误。仔细分析过后，才认定MySQL的错误。我Google了很久，试了各种方法，比如修改数据库的 charset ，使用Python中的 decode 和 encode ，都无济于事。甚至将这个问题在[stackoverflow](http://stackoverflow.com/questions/21286034/incorrect-string-value-xe6-x8e-x92-xe5-xba-x8f-for-column-title-at-row-1/21286376?noredirect=1#21286376)进行提问。有个8k多reputation的认为我这个问题提的不好，投了一个不赞成票 。。。或者美国人不知道这个问题多么蛋痛吧。

　　数据抓取不来，工作无法开展。好在第二天无意中试了试删掉数据库，重新syncdb才终于没有了这个错误 ------ 原来在更改MyDQL的 charset 后，最好是重新建立数据库，而当时我以为照网上alter一下 charset 就可以，不用重新建立数据库。过了这一关，剩下的工作就轻松很多了，即建立查询界面。还是比较喜欢用Bootstrap，搜到有个[Bootstrap Django Toolkit](https://github.com/dyve/django-bootstrap-toolkit)的项目，貌似可以在Django中集成Bootstrap。由于自己写模板也不是很困难，所以就没有尝试这个 toolkit。这次依然使用[LayoutIt](http://www.layoutit.com/cn/)来生成界面。

　　这次还第一次使用了正则表达式。因为用户提交的源代码都放在像[http://pythontip.sinaapp.com/coding/code_display/15870](http://pythontip.sinaapp.com/coding/code_display/15870)这样的地址上，所以必须得到最后那个提交号（15870），而在数据解析中得到的是像 code15870 这样的字符串，需要用正则表达式将15870提取出来。好在这个还不是很复杂，很快就写完了，至此所有技术问题都解决完毕。

　　源码已经上传[Github](https://github.com/whilgeek/PythonChallengeSearch)。
