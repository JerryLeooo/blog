# 使用sendgrid的邮件服务器设置

直接上代码：

```
dc_eximconfig_configtype='smarthost'
dc_other_hostnames=''
dc_local_interfaces='127.0.0.1 ; ::1'
dc_readhost='example.com'
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost='smtp.sendgrid.net::587'
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname='true'
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
```
<!--more-->
然后在 `passwd.client` 中参照官方文档写上 `sendgrid` 的用户名和密码

注意，在使用 `example.com` 发送邮件的时候，需要配置 `txt记录` ，将这台机器的IP添加到 `spf` 里面。
