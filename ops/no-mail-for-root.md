# No Mail For Root

##Exim4配置中的坑

利用Exim4搭建一个简单的邮件服务器，个人最好有一个域名和独立IP。这里我假定我的域名是**example.com**，VPS的IP是**123.123.123.123**。

<!--more-->
首先一步是DNS的配置，主要是配MX记录：

A记录：

| Name             | Destination IP Address |
|:-----------------|:---------------------- |
| songsay.com      | 123.123.123.123        |
| mail.example.com | 123.123.123.123        |

MX记录：

| Name              | Priority | Value            |
|:------------------|:---------|:-----------------|
| mail1.example.com |    10    | mail.example.com |	 

具体解释还请查看DNS方面的文档。

接下来就是配置Exim4了，使用```dpkg-reconfigure exim4-config```来配置即可，详情查看Exim4的文档。配置完成的`/etc/exim4/update-exim4.conf.conf`应该是这个样子：

```
dc_eximconfig_configtype='internet'
dc_other_hostnames='mail.example.com;mail1.example.com;example.com'
dc_local_interfaces='123.123.123 ; 127.0.1.1 ; 127.0.0.1 ; ::1'
dc_readhost=''
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost=''
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname=''
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
```

或许`dc_other_hostnames`和`dc_local_interfaces`看起来比较冗余，这都是我后期收不到信气急败坏之下把能加的都加上了。

下面就是大坑所在。配置好了之后我尝试给`root@mail1.example.com`发信，无论是使用Gmail还是Linux自带的sendmail，在VPS实用mail命令查看都是`No mail for root`，Gmail还收到了退信邮件。我反复检查配置，浪费了很多时间。

后来，经同事的提示，切换到另外的用户收信，比如`geek@example.com`后，就可以收到了。

查阅相关问题，不知是否关键词选的不对，搜到的结果很少，包括著名的[爆栈网](http://stackoverflow.com/)。[这里](http://www.dslreports.com/forum/remark,6817941)有个链接，凑合看看吧。root用户收不到信，应该是一个设计问题，如果硬要发给root信的话，需要为root添加一个alias。即编辑（如果没有就创建）`/etc/aliases`，添加一行`root: geek`。这样发送给root的邮件，都会由名叫geek的用户收到。

配置完Exim后，还需要安装`Courier-IMAP`让邮件服务器具有IMAP功能。具体就是使用`apt-get`来安装`courier-imap`，`courier-imap-ssl`，`courier-authdaemon`等。但是需要注意的是，Exim4如果在之前`dpkg-reconfigure exim4-config`中最后一部选择的邮件格式是`mbox`格式，就会和`Courier-IMAP`冲突，因为它默认是用`家目录/Maildir`的格式，所以需要去修改Exim4中的配置，使它也使用`家目录/Maildir`的格式。但是我修改并重启之后发现依旧解决不了问题。折腾了很久，直到在[这里](http://blog.edseek.com/~jasonb/articles/exim4_courier/exim4.html)找到了解决方法，即修改完配置之后，还需要运行`invoke-rc.d exim4 reload`。单纯重启并不会自动读取新的配置。

自此可以使用`ThunderBird`之类的邮件客户端使用相应的用户名和密码采用IMAP协议收取邮件了，感觉很棒。当然，要想保证安全的话必须启用一些加密信道，这个稍后补上。
