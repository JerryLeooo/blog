# 让我们来愉快地爆栈吧！

##关于Python垃圾收集的一些小探讨

让Python来实现内存泄漏并不是一件看上去那么简单的事情。起初我以为这样的代码足以“爆栈”：

<!--more-->
```
class Class(object):
    def __init__(self, name):
        self.name = name

while True:
    A = Class('Object A')
    B = Class('Object B')
    A.b = B
    B.a = A
    A = None
    B = None

```

但通过`top`或者`htop`看，发现内存并没有很明显的变化。后来了解到这是Python在2.0之后做了优化，这样的代码会及时进行垃圾收集。

后来我想，`__del__`方法不是用来减少引用计数的吗？所以重定义`__del__`或许实现内存泄漏。重新写过的Class类如下：

```
class Class(object):
    def __init__(self, name):
        self.name = name
    def __del__(self):
        pass
```

再次运行`while`循环，果然出现了内存占用直线上升。

另一个爆栈的方法就是关掉`gc`，在代码前面加上
```
import gc
gc.disable()
```
同样可以实现爆栈的效果。

然后看《The Python Standard Library by Example》里面关于gc模块的例子，关于重定义`__del__`会改变垃圾收集器行为，书是这么解释的：

> Because more than one object in the cycle has a finalizer method, the order in which the objects need to be finalized and then garbage collected cannot be determined. The garbage collector plays it safe and keeps the objects

关于这种循环引用，上面例子中的instance相对来说比较少，在《The Python Standard Library by Example》里面，讲`gc`的时候，使用了包含三个对象的一个对象链，当这个链条中的某个对象被回收了之后，这个循环引用对象链就会被破坏，然后其中的所有对象都会被回收。

水文一篇，聊当读书笔记，以后更新。
