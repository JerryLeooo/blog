# 日志收集平台搭建指南

这个平台的搭建意义是使用邮件对日志进行收集，并通过Logstash和ElasticSearch对日志进行处理。(其中的IP地址以及域名已经失效，各位不必费神了。)

##涉及的软件及其版本
- `Exim` 4.76
- `Courier IMAP`  imapd.dist.in 20 2011-04-04
- `Logstash1` 1.4.0
- `ElasticSearch` 1.1.1

<!--more-->
##软件安装及设置

###DNS配置

####A记录
|Nmae|Destination IP Address|
|:--|:--|
|songsay.net|128.199.245.158|
|mail.songsay.net|128.199.245.158|

####MX记录

|Nmae|Priority|Value|
|:--|:--|
|mail1.songsay.net|10|mail.songsay.net|

注意，`MX记录`中优先级`小`的记录会被先查到。

###Exim4（Server）
- Exim4的安装不必多说，Debian系统自带，Ubuntu的话运行`sudo apt-get install exim4`即可。
- 使用`dpkg-reconfigure exim4-config`来进行可视化设置，当然最好是直接修改`/etc/exim4/update-exim4.conf.conf`也可以。选择可视化设置的话，需要注意两点：在第一步`邮件服务器类型`中，选择第一个带有`Internet`字样的选项；在最后一步选择`本地信件的投递方式`中，选择`家目录/Maildir`格式，这样是为了配合之后的`Courier-IMAP`，因为它默认就是这种`家目录/Maildir`格式。配置好的`/etc/exim4/update-exim4.conf.conf`应该是这个样子：
```
dc_eximconfig_configtype='internet'
dc_other_hostnames='mail.songsay.net;mail1.songsay.net;mail2.songsay.net;songsay.net'
dc_local_interfaces='128.199.245.158 ; 127.0.1.1 ; 127.0.0.1 ; ::1'
dc_readhost=''
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost=''
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname=''
dc_mailname_in_oh='true'
dc_localdelivery='maildir_home'
```
- 设置好之后使用`invoke-rc.d exim4 reload`重载设置，应该已经可以使用`mail`命令来查看信件了，值得注意的是`root`用户无法直接收到信件。应该是通过`adduser`命令建立用户来收信。如果硬要使用`root`用户收信的话，需要编辑`/etc/aliases`文件，添加一行`root: yourusername`。这样发送给`root`的信件都会由名叫`yourusername`的用户收到。

###Courier-IMAP（Server）
- Ubunut下运行`sudo apt-get install courier-imap courier-imap-ssl courier-authdaemon`安装。
- 无需其他配置，可使用`Thunderbird`之类的软件登录查看是否成功。

###ElasticSearch（Client）
- [http://www.elasticsearch.org/overview/elasticsearch/](http://www.elasticsearch.org/overview/elasticsearch/)下载安装。无需过多配置

###Logstash（Client）
- 在[http://logstash.net/](http://logstash.net/)下载最新版本。
- Logstash配置文件：

```
input {
  imap {
    port => 143
    host => "mail.songsay.net"
    user => "whilgeek"
    password => "AJFJlfkajf"
    codec => "plain"
    content_type => "text/plain"
    secure => false
    check_interval => 5
  }    
  stdin {}
}

filter {
  grok {
    match => ["message", "%{ALL}%{LEVELNAME:levelname}%{ALL}%{PATHNAME:pathname}%{ALL}%{LINENO:lineno}%{ALL}%{MODULE:module}%{ALL}%{FUNCNAME:funcname}%{ALL}%{TIME:time}%{ALL}%{METHOD:method}%{ALL}%{UKEY:ukey}%{ALL}%{COOKIE:cookie}%{ALL}%{HTTP_REFERER:http_referer}%{ALL}%{USER_AGENT:useragent}%{ALL}%{X_FORWARD_FOR:x_forward_for}%{ALL}%{REQUEST_FORM:request_form}%{ALL:traceback}"]
    patterns_dir => "./extra"
  }
}

output {
  elasticsearch {
    host => localhost
    embedded => true
  }
}

```
其中，`input`字段代表日志来源，`imap`即为通过IMAP协议获取邮件。`output`为输出，这里输出到`Elasticsearch`来做进一步处理。`filter`是对日志的过滤，`grok`是采用正则表达式来提取字段，请根据自己的日志格式进行正则表达式的编写。提取模式使用了自己定制的模式，所以会看到`patterns_dir => "./extra"`，即建立一个`extra`（名字无所谓）文件夹，并在里面放一个文件，内容如下即可：

```
LEVELNAME (?<=LEVELNAME:)(.*)\s*(?=PATHNAME:)
PATHNAME (?<=PATHNAME:)(.*)\s*(?=LINENO:)
LINENO (?<=LINENO:)(.*)\s*(?=MODULE:)
MODULE (?<=MODULE:)(.*)\s*(?=FUNCNAME:)
FUNCNAME (?<=FUNCNAME:)(.*)\s*(?=TIME:)
TIME (?<=TIME:)(.*)\s*(?=METHOD:)
METHOD (?<=METHOD:)(.*)\s*(?=UKEY:)
UKEY (?<=UKEY:)(.*)\s*(?=HTTP_COOKIE:)
COOKIE (?<=HTTP_COOKIE:)(.*)\s*(?=HTTP_REFERER:)
HTTP_REFERER (?<=HTTP_REFERER:)(.*)\s*(?=HTTP_USER_AGENT:)
USER_AGENT (?<=HTTP_USER_AGENT:)(.*)\s*(?=X_FORWARD_FOR:)
X_FORWARD_FOR (?<=X_FORWARD_FOR:)(.*)\s*(?=REQUEST_FORM:)
REQUEST_FORM (?<=REQUEST_FORM:)(.*)\s*(?=Traceback)
ALL [\s\S]*

```

`Logstash`已经内置了`Kibana`，要使用的话，需要打开两个进程`./logstash -f f.conf`和`./logstash -f f.conf web`，然后打开[`http://127.0.0.1:9292/index.html#/dashboard/file/logstash.json`](http://127.0.0.1:9292/index.html#/dashboard/file/logstash.json)可以看到日志分析界面。

IMAP要走加密的操作，按照[http://blog.edseek.com/~jasonb/articles/exim4_courier/index.html](http://blog.edseek.com/~jasonb/articles/exim4_courier/index.html)这个文档的`Configuring TLS and Authentication`和4.4走即可，主要步骤如下：

- 在Server端执行`bash /usr/share/doc/exim4-base/examples/exim-gencert`生成新的exim.key，如果原来有的话删掉即可。
- 修改`/etc/exim4/exim4.conf.template`，找到`MAIN_TLS_ENABLE`，将其设置为`yes`
- 安装一个TLS测试工具：swaks `apt-get install swaks libnet-ssleay-perl`
- 然后执行：

```
swaks -a -tls -q HELO -s localhost -au yourusername -ap '<>'
```

会看到以下输出

```

=== Trying localhost:25...
=== Connected to localhost.
<-  220 evie ESMTP Exim 4.50 Tue, 02 May 2006 17:56:25 -0400
 -> EHLO evie
<-  250-evie Hello localhost [127.0.0.1]
<-  250-SIZE 52428800
<-  250-PIPELINING
<-  250-STARTTLS
<-  250 HELP
 -> STARTTLS
<-  220 TLS go ahead
=== TLS started w/ cipher DHE-RSA-AES256-SHA
 ~> EHLO evie
<~  250-evie Hello localhost [127.0.0.1]
<~  250-SIZE 52428800
<~  250-PIPELINING
<~  250 HELP
 ~> QUIT
<~  221 evie closing connection
```

- 安装sasl：`apt-get install sasl2-bin`
- 修改`/etc/default/saslauthd`，将`START`的值改为`yes`
- 启动sals：`invoke-rc.d saslauthd start`
- 修改`/etc/exim4/exim4.conf.template`，将以下行前面的注释去掉：

```
    
# Authenticate against local passwords using sasl2-bin
# Requires exim_uid to be a member of sasl group, see README.SMTP-AUTH
 plain_saslauthd_server:
   driver = plaintext
   public_name = PLAIN
   server_condition = ${if saslauthd{{$2}{$3}}{1}{0}}
   server_set_id = $2
   server_prompts = :
   .ifndef AUTH_SERVER_ALLOW_NOTLS_PASSWORDS
   server_advertise_condition = ${if eq{$tls_cipher}{}{}{*}}
   .endif
```

- `adduser Debian-exim sasl` 然后重启Exim4：`invoke-rc.d exim4 restart` 
- 再次验证一下：

```
swaks -a -tls -q AUTH -s localhost -au yourusername
Password: passwd #这个地方的密码是明文！
```

会显示

```
=== Trying localhost:25...
=== Connected to localhost.
<-  220 evie ESMTP Exim 4.50 Fri, 05 May 2006 18:10:18 -0400
 -> EHLO evie
<-  250-evie Hello localhost [127.0.0.1]
<-  250-SIZE 52428800
<-  250-PIPELINING
<-  250-STARTTLS
<-  250 HELP
 -> STARTTLS
<-  220 TLS go ahead
=== TLS started w/ cipher DHE-RSA-AES256-SHA
 ~> EHLO evie
<~  250-evie Hello localhost [127.0.0.1]
<~  250-SIZE 52428800
<~  250-PIPELINING
<~  250-AUTH PLAIN
<~  250 HELP
 ~> AUTH PLAIN AGphc28uygBOaGVxMHc=
<~  235 Authentication succeeded
 ~> QUIT
<~  221 evie closing connection
```

- 在`/etc/exim4/passwd.client`中添加用户：

```
### CONFDIR/passwd.client
#
# Format:
#targetmailserver.example:login:password
#
# default entry:
### *:bar:foo

example.com:jasonb:passwd
```

- 运行以下命令，看到对应的输出即可：
    
```
# echo "test" | mail -s "test" jasonb@edseek.com
# tail -f /var/log/exim4/mainlog
2006-05-05 18:45:56 1Fc93b-0003e4-QG <= root@nebula.internal.foo U=root P=local S=313
2006-05-05 18:45:57 1Fc93b-0003e4-QG => jasonb@edseek.com R=smarthost T=remote_smtp_smarthost
  H=example.com [207.36.208.156] X=TLS-1.0:RSA_AES_256_CBC_SHA:32
2006-05-05 18:45:57 1Fc93b-0003e4-QG Completed
```

- 生成一个IMAP证书，运行`mkimapdcert`即可，如果原来有文件，删掉。
- 像下面这样修改`/etc/courier/imapd-ssl`：
    
```

# Ok, the following settings are new to imapd-ssl:
#
#  Whether or not to start IMAP over SSL on simap port:

IMAPDSSLSTART=NO

##NAME: IMAPDSTARTTLS:0
#
#  Whether or not to implement IMAP STARTTLS extension instead:

IMAPDSTARTTLS=YES

##NAME: IMAP_TLS_REQUIRED:1
#
# Set IMAP_TLS_REQUIRED to 1 if you REQUIRE STARTTLS for everyone.
# (this option advertises the LOGINDISABLED IMAP capability, until STARTTLS
# is issued).

IMAP_TLS_REQUIRED=1
```

- OK啦！
