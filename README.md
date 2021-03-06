# Dkits
DCS World异步restful API框架。<br>
交流及问题答疑群: 947778468<br>
点击链接加入群聊【Dkits Code Oncall】：https://jq.qq.com/?_wv=1027&k=4qBfeUo7<br>

### 当前Dkits仍不可用 请等待至版本大改结束

### 关于Dkits
  DCS World处理lua脚本的方式大家应该都有了解, 实际上动态鸽这种每一帧都需要等到lua处理结束的做法导致同学们开发三方脚本技术难度提高, 并且语句中不能有任何低时效性或者阻塞代码, 因为它们最终会导致你的游戏帧率下降, 如果运行在服务器上那简直就是一场灾难, 因为考虑到实际上大部分任务作者或者工程师同学们的第一语言都不是lua的前提下, 兔兔服在去年提出第三方语言介入的异步解决方案, 在去年我们发布了RFC v1版本, 根据当时运行结果来看, 我们可以实现更多复杂的功能, 并且再也不需要担心阻塞问题, lua与第三方语言采取异步通讯的方式, 也就是说至少目前我认为<strong>通过Restful API与其他语言通讯的方式来控制DCS是目前最好的方案。</strong>

### 致歉
  这是一件很抱歉各位同学的事情, 在RFC v1开发结束后我并没有很好的去备份我的代码, 笔记本当时也重装了系统, 后来一段时间的弃坑DCS后阿里云的服务器被销毁导致当时所有的程序全部丢失, 所以这份代码是我根据之前的框架原理重写的一份, 但是代码量很大, 加上我因工作繁忙的原因没有太多的时间投入在这上面, 所以我只把大概的实现原理写了上去, 如果同学对这份代码感兴趣的话, 欢迎一起协作完成Dkits框架。

### 如何使用?
  1.由于动态鸽的luasocket库有一些小问题, 它会导致只有socket可以使用, 而诸如http, ltn12, url这样模块无法使用, 所以我将它修复后附加在了仓库中, 你需要将本仓库中的luasocket目录替换到你游戏根目录的luasocket目录。<br>
  2.剩下的事情非常简单, 将仓库中的Scripts目录扔到你游戏的数据存储目录即可, 该目录的路径看起来像这样:<br>
  C:\Users\用户名\Saved Games\DCS<br>
  3.使用其他语言编写一个Web API接口, 大致原理可以参考下testapi.py这个示例程序, 在游戏中新建服务器, 在游戏中起飞, 该事件将被推送到你的接口当中(但是目前我只写了起飞事件的)。

### 开发进度 与 项目结束时间
实际上如各位同学所见, 这个项目的难点不在于Lua, 而在于各位同学的第三方集成难度, Dkits很快就会初具雏形, 虽然我工作繁忙, 但我将提供每周至少一次的Dkits大更新, 同时也希望各位同学可以将第三方集成的代码开源共享, 以便后来的同学可以快速展开开发进度, <strong>相信大家可以打造一个国内不错的DCS world插件及功能扩展环境。</strong>
