# 深入理解Python的finally

　　最近在找一些实习工作，不可避免的要参加面试。由于投得都是外地公司，所以基本都是以电话面试的形式。面试过程中，有一道很有意思的题目，和大家分享一下。

<!--more-->
　　题目是这样的，Python代码

	try:
		raise Exception
	except:
		return True
	else:
		return True
	finally:
		return False
		
的返回结果是什么？

　　我听完题目，不假思索地说，是True，并且还补充到，是except中返回的True。面试官未置可否，只是让我好好读读Python异常处理这一章。

　　作为一个对C语言很熟悉的程序员，我得出这样的结果很正常。因为在C中，函数一旦`return`，就意味着这个函数的栈空间被释放掉，并返回到调用者。但从面试官的语气来看，此事在Python中并非如此。

　　看异常处理这一章并没有看出什么门道，我于是自己运行了以下下面的这段代码：
	

	def f():	
		try:
			raise Exception
		except:
			print 'return True'
			return True
		else:
			print 'return True'
			return True
		finally:
			print 'return False'
			return False

	def main():
		re = f()
		print re
		print type(re)

	if __name__ == '__main__':
		main()

结果为
	
	return True
	return False
	False
	<type 'bool'>	

　　看来f()在抛出异常并后，执行了`except`中的`return`，但是并没有返回到调用者，而是“`坚持`”将`finally`中的代码执行完毕。至此，我算是真正理解了`finally`的真正含义，就是即使已经`return`，仍要执行`finally`中的代码。

　　后来，在stackoverflow.com上发现有人问了[很相似的问题](http://stackoverflow.com/questions/11164144/weird-try-except-else-finally-behavior-with-return-statements)，底下有的回答很精彩，更一步加深了我的印象，大家不妨一看。
