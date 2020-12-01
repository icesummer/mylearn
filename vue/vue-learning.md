vue+bootstrap

可视化布局：



```sh
#[可视化布局] https://www.bootcss.com/p/layoutit/
# [ice.work](https://ice.work/)
```



CSS预处理器：用一种专门的编程语言，进行Web页面样式设计，再通过编译器转化为CSS文件使用；

SaaS: 基于Rubby

Less：基于Nodejs



打包工具：

webpack



脚手架工具

vue-cli





网络通信：axios

页面跳转：vue-router

状态管理：vuex

vue-ui：   ICE





UI框架：

- ANT-design
- Element-UI ，iview，ice： 饿了么
- Bootstrap，Twitter推出
- AmazeUI：HTML5跨屏前端框架



Javascript构建工具

- webpack



Vue

官网

```sh
https://cn.vuejs.org/v2/guide/
```

## vue安装部署

方式1.   > 直接引入`<script>`方式

方式2.   > 命令行工具CLI



用vue构建大型应用时推荐NPM安装，npm能够很好的和webpack或browserfly模块打包器配合

```
npm install vue
```



## 基本指令

```javascript
var app = new Vue({
    el: '#app',
    data: {
        message: 'Hello Vue!',
        seen: true,
        isActive: true,
        dataArr: ["aaa","bbb","ccc"],
        txtList: [],
        mytext:'wowhishi'
    },
    methods: {
        show:function() {
            this.seen=!this.seen,
                this.isActive=!this.isActive
        },
        add:function(){
            if(this.mytext){
                this.txtList.push(this.mytext)
                console.info("size:",this.txtList.length)
            }
        },
        del:function(){
            if(this.txtList.length>0){
                this.txtList.pop(this.mytext)
                console.info("size:",this.txtList.length)
            }
        }
    }
})
```

### {{}} 显示文本

```vue
<div class="col-9">{{message}}</div>
```

### v-html  显示为html标签内容

> * 动态渲染html是很危险的，不建议使用动态的v-html
>
> v-html要防止XSS,CSRF攻击（
>
>    			1. 前端过滤
>             			2. 后台转义(`< 和 >转义为--> &lt; 和 &gt;`)
>                   			3. 给cookie加属性http
>
> * 

```javascript
<div v-html="myhtml"/>

new vue({
    data:{
		message: 'Hello Vue!',
        myhtml:"<li>as</li><li>bs</li>";
    }
...
```





### v-bind:xx 绑定指令 (略写:xx)

```vue
<div class="col-4">
    <span v-bind:title="message">
        鼠标悬停几秒钟查看此处动态绑定的提示信息！
    </span>
</div>

<p v-bind:class="isActive?'active':'active1'">是否使用了active的class样式C</p>
<!--v-bind:xxx 动态绑定,冒号后跟html普通属性,v-bind可以省略：-->
<p :class="isActive?'active':'active1'">是否使用了active的class样式C</p>
methods: {
    show:function() {
        this.isActive=!this.isActive
    }
}
```

### v-show显示指令

```vue
<p v-show="seen">现在你看到我了A</p>
```

### v-if 判断指令

```vue
<p v-if="seen">现在你看到我了</p> 
<!--此时同v-show区别是：v-show=false时是隐藏，v-show=false时移除该标签-->
<!--  seen需定义： -->
 data: {
        seen: true,
```

### template与v-if

> 两者搭配简化代码 * > 当多个标签被v-if控制显示隐藏时

```vue
<div>
    <template v-if="isHas">
    	<div>A</div>
		<div>B</div>
    	<div>C</div>
    </template>
    
</div>

data:{idHas:true}
```



### v-on:click=绑定事件(@click:)

```@click=""-----略写----v-on:click=""```

```vue
<span v-bind:title="message" class="span-text-1">
    <button @click="show()">显示隐藏</button>
    <!--@绑定事件，还可用v-on:event表示-->
    <button v-on:click="show">显示隐藏</button>
</span>
<p v-show="seen">现在你看到我了A</p>
<p v-if="seen">现在你看到我了</p> 


<!--event事件参数-->
<!--调用方法时不写小括号(),methods中定义的function能拿到当前标签事件event-->
<!--调用方法时带了小括号(),传递本标签事件需要用内置的$enent-->
<input type="text" v-on:input="inputChange" width="80%"/>
<input type="text" v-on:input="inputChange($event)" width="80%"/>
methods:{
	inputChange:function(evn){
        this.myinputtxt = evn.target.value;
    },
}

```

### 事件修饰符

```vue
<!-- 阻止单击事件继续传播 阻止事件冒泡 -->
<a v-on:click.stop="doThis"></a>

<!-- 提交事件不再重载页面 -->
<form v-on:submit.prevent="onSubmit"></form>

<!-- 修饰符可以串联 -->
<a v-on:click.stop.prevent="doThat"></a>

<!-- 只有修饰符 -->
<form v-on:submit.prevent></form>

<!-- 添加事件监听器时使用事件捕获模式 -->
<!-- 即内部元素触发的事件先在此处理，然后才交由内部元素进行处理 -->
<div v-on:click.capture="doThis">...</div>

<!-- 只当在 event.target 是当前元素自身时触发处理函数 -->
<!-- 即事件不是从内部元素触发的 -->
<div v-on:click.self="doThat">...</div>
```





### for-each

```vue
<li v-for="(item,index) in dataArr" > 
    <!--item表示元素，index表示位置可略-->
    {{item}}----{{index}}
</li>
```

### **v-model 双向绑定指令**  

* 所在标签的value与vue的data数据相互绑定：即value变化则data数据变化，反之亦然；

```vue
<input type="text" v-model="mytext" width="80%"/>
<span class="span-text-1">
    <button v-on:click="add()"> add </button>
</span>
<span  class="span-text-1">
    <button v-on:click="del()"> remove last </button>
</span>

<div class="col-4">
    <li v-for="item,index in txtList" v-bind:index="index">
        {{item}}  
        <button @click="del(index)">remove</button>
    </li>
</div>

<!--实现add追加输入text到li标签-->
 methods: {
    data: {
        message: 'Hello Vue!',
        txtList: [],
        mytext:'wowhishi'
     },
    add:function(){
        if(this.mytext){
            this.txtList.push(this.mytext)
            console.info("size:",this.txtList.length)
            this.mytext=""
        }
    },
    del:function(index){
        if(this.txtList.length>0){
            if(index>=0){//删指定index位置的
                this.txtList.splice(index,1);
            }else{// 删最后一个
                this.txtList.pop(this.mytext)
            }
        }
        console.info("size:",this.txtList.length,index)
    }
},
```

### class与style绑定

```vue
<style>
    .classa{xxx:f}
    .classb{cc}
</style>
<div :class="classobj"> // 该div就应用上classobj定义的classa,classb类
</div>
​```略
data: {
	classobj:{
		classa:true,
		classb:true
	},
	classsarr:["classa","classb"]
}

<!--如果需要动态增删class -->
<!--使用对象需要Vue.set先定义好增加的bianliang-->
Vue.set(v.classobj.classc,true);
然后method方法才可操作新的变量v.classobj.classc
<!--使用数组直接在method操纵即可-->
func:
v.classarr.push("ccc");
```

```vue
style:
<div :style="stylearr"> // 该div就应用上stylearr定义的样式
</div>
​```略
data: {
	styleobj:{
		"backgroundColor":"red"
	},
	stylearr:[{"backgroundColor":"red"}]
}
// 动态操作
v.stylearr.push({"fontSize":"40px"})
```



### 指令总结：

1. 指令：是待v-前缀的特殊属性
   * v-bind:prop   ->> 动态绑定属性		**v-bind:title="message" 缩写为 :title="message"**
   * v-if=“bool”    ->> 动态删除/创建
   * v-show=“bool”  ->> 动态隐藏/显示
   * v-on:[click等]=  ->> 绑定事件		**v-on:click=?? 可缩写为--> @click=??**
   * v-for="item,index in data"    ->> 遍历
   * v-model="mydata" ->>双向绑定(标签的value与data的双向绑定)



### 模板语法

- 组件的复用；组件传值  **props: ["propname"]**

```vue
<body>
       
        <div class="container" id="app" v-cloak >
            <div>
                <ul>
                    <myli v-for=" na in users" :name1="na" ></myli>
                </ul>
            </div>
            
        </div>
    </body>
    <script src="dist/index.js"></script>
    <script type="text/javascript">
        Vue.component("myli",{
            model: { // 组件上的 v-model
                prop: 'checked',
                event: 'change'
              },
            props: ['name1'], // 组件传值
            template: "<li style='color:red'>{{name1}}</li>"
        })
        var app = new Vue({
            el: '#app',
            data() {
                return {
                    users: ["张三","李四","张五","赵六"]
                }
            }
        });
    </script>
</html>
```



### computed

* 计算属性 -- 提高性能
* 与method不同的时method是调用的方法的结果，computed取的是缓存下来数据，

```vue
<li v-for="n in evenNumbers" :key="n">{{ n }}</li>

data: {
  numbers: [ 1, 2, 3, 4, 5 ]
},
methods: {
 <!-- evenNumbers: function () {
    return this.numbers.filter(function (number) {
      return number % 2 === 0
    })
  }, -->
computed: {
  evenNumbers: function () {
    return this.numbers.filter(function (number) {
      return number % 2 === 0
    })
  }
}
```



### watch

### mounted





### 内容分发与自定义组件

* 使用slot插槽机制，实现动态化的标签变

  **this.$emit('myEvent')**

## Axios通信

Axios是一个开源的可以用在浏览器端和NodeJs的异步通信框架，实现Ajax的异步通信功能

官网 `https://github.com/axios/axios`



## vue-cli

> 命令行工具：vue提供的官方的cli

### 安装vue-cli

```sh
npm uninstall -g vue-cli# 卸载2版本
npm install -g @vue/cli # 安装3版本

#下载依赖
npm install
```



```sh
# vscode的vue插件：
https://www.cnblogs.com/luckybaby519/p/13904457.html
```



VSCode

```sh
https://code.visualstudio.com/ # 官网
```

ctrl+shift+p打开 搜language安装中文扩展

> Activity Bar活动栏(左侧导航)

1. explore 文件浏览
2. search 查找
3. Source Control
4. Dubeg调试
5. **Extensions** 扩展

> EditGroup(编辑区)



> Pannel(编辑区)

1. Problems
2. 输出
3. DeBugConsole 调试控制台
4. TERMINAL(命令终端)

```
VSCode里安装Vetur可以将“.vue”文件中的语法进行高亮显示，Vetur不仅支持Vue中的template模板以外，还支持大多数主流的前端开发脚本和插件，比如Sass、TypeScript、Jade和Less等等。
```

```sh
#快捷键：
ctrl+shift+p打开命令面板
ctrl+p 打开最近文件
```

> vscode扩展

```sh

```

