# license：



* JAVA控制软件版权和试用(限制时间、限制次数、限制功能)的技术方案

license里就是一些注册信息，键值对组成的字符串

> 对称加密：

DES，AES，加密解密都用一个秘钥，速度快

> 非对称机密

RSA，可以私钥加密公钥解密，也可以公钥机密私钥解密，速度慢

注意：
RSA加密明文最大长度117字节，解密要求密文最大长度为128字节，所以在加密和解密的过程中需要分块进行。
RSA加密对明文的长度是有限制的，如果加密数据过大会抛出异常：



**常见加密算法**

**DES** 

**AES**

**RSA**

@[RSA](https://blog.csdn.net/zhangdaiscott/article/details/74344925)







# 谈谈java程序代码保护及license设计

理论上讲，不存在牢不可破的漏洞，只是时间和成本问题。通常我们认为的不可破解，说的是破解需要难以接受的时间和成本。

 对于java程序来说，class文件很容易被反编译，所以理论上而言，对java程序做license限制，无法真正起到保护软件被盗窃的作用。

 但是，如果增加被反编译的成本，或者增加被反编译后能读懂源码的成本，也能从一定程度上起到保护软件被盗用的目的。 

针对不同的应用程序，可以使用不同的方法。 

### **1. Android应用程序** 

由于Android应用程序时需要下载才能被安装的，所以用户很容易可以得到程序包，且可以进行反编译。 所以只能通过增加被反编译后读懂源码的成本来达到保护程序被盗用的目的，通常的做法是**进行代码混淆**。 

### **2. Web应用程序** 

（1）自己部署 Web应用程序通常部署在服务器端，用户能直接获取到程序源码的风险相对较小，所以就可以避免被反编译。 

（2）交付给用户部署 如果想限制软件系统的功能或者使用时间，可以通过license授权的方式实现。但是，license加密和解密验证都必须在服务器端。

 ########### **理论上没有任何意义**，只要web程序提供给用户，同样可以被反编译绕开license验证过程。

########### ########### 如果一定要做license限制，**一定要对license解密代码进行混淆处理**。############  

### **3. 关于RSA加密** 

公钥加密数据长度最大只能为117位，私钥加密用于数字签名，公钥验证。 

通常，不直接使用RSA加密，特别是加密内容很大的时候。 

使用RSA公钥加密AES秘钥，再通过AES加密数据。 

### 【参考】

 https://www.guardsquare.com/en http://www.cnblogs.com/cr330326/p/5534915.html        ProGuard代码混淆技术详解

 http://blog.csdn.net/ljd2038/article/details/51308768    ProGuard详解

http://oma1989.iteye.com/blog/1539712   Java给软件添加License 

http://infinite.iteye.com/blog/238064   利用license机制来保护Java软件产品的安全 

http://jasongreen.iteye.com/blog/60692    也论java加壳 

http://jboss-javassist.github.io/javassist/   Javassist 

http://www.cnblogs.com/duanxz/archive/2012/12/28/2837197.html  java中使用公钥加密私钥解密原理实现license控制 

http://ju.outofmemory.cn/entry/98116   使用License3j实现简单的License验证