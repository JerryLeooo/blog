# 《The Linux Command Line》读书笔记

- [__AWS添加卷到实例的方法__](http://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-add-volume-to-instance.html)

- __硬链接__ 不同的文件名，相同的i节点，同一份文件内容。

- __输出重定向__

>因为标准错误和文件描述符2一样，我们用这种 表示法来重定向标准错误：

```
ls -l /bin/usr 2> ls-error.txt
```
<!--more-->
- __重定向标准输出和错误到同一个文件__

>可能有这种情况，我们希望捕捉一个命令的所有输出到一个文件。为了完成这个，我们 必须同时重定向标准输出和标准错误。有两种方法来完成任务。第一个，传统的方法， 在旧版本 shell 中也有效：

```
ls -l /bin/usr > ls-output.txt 2>&1
```

>使用这种方法，我们完成两个重定向。首先重定向标准输出到文件 ls-output.txt，然后 重定向文件描述符2（标准错误）到文件描述符1（标准输出）使用表示法2>&1。

> 现在的 bash 版本提供了第二种方法，更精简合理的方法来执行这种联合的重定向。

```
ls -l /bin/usr &> ls-output.txt
```

- __setuid, setgid, sticky bit__

|名字|作用|
|:--|:--|
|setuid|当应用到一个可执行文件时，它把有效用户 ID 从真正的用户（实际运行程序的用户）设置成程序所有者的 ID。例如 Ubuntu 下的 /etc/passwd （FreeBSD 的同一文件权限与之不同）|
|setgid|把有效用户组 ID 从真正的 用户组 ID 更改为文件所有者的组 ID。如果设置了一个目录的 setgid 位，则目录中新创建的文件 具有这个目录用户组的所有权，而不是文件创建者所属用户组的所有权。对于共享目录来说， 当一个普通用户组中的成员，需要访问共享目录中的所有文件，而不管文件所有者的主用户组时， 那么设置 setgid 位很有用处。|
|sticky bit|在 Linux 中，会忽略文件的 sticky 位，但是如果一个目录设置了 sticky 位， 那么它能阻止用户删除或重命名文件，除非用户是这个目录的所有者，或者是文件所有者，或是 超级用户。|

- 启动一个程序，让它立即在后台 运行，我们在程序命令之后，加上”&”字符。
- [.bashrc还是.bash_profile](http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html)

- __find 可以添加逻辑操作符__
```
find ~ \( -type f -not -perm 0600 \) -or \( -type d -not -perm 0700 \)
```

- __使用exec执行命令__

```
find ~ -type f -name 'foo*' -exec ls -l '{}' ';'
find ~ -type f -name 'foo*' -exec ls -l '{}' +
```

- __xargs__

下面的ls只用执行一次，加快了速度

xargs 命令会执行一个有趣的函数。它从标准输入接受输入，并把输入转换为一个特定命令的 参数列表。对于我们的例子，我们可以这样使用它：
```
find ~ -type f -name 'foo\*' -print | xargs ls -l

-rwxr-xr-x 1 me     me 224 2007-10-29 18:44 /home/me/bin/foo
-rw-r--r-- 1 me     me 0 2008-09-19 12:53 /home/me/foo.txt
```

- __生成固定长度的随机数__

```
echo ${RANDOM:0:3}
```

##TODO

探究两个Linux命令：

- `curl`
- `split`

