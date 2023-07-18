Slacker-PHP Development Environment
=====================================

Slacker 是一个为像我一样的懒虫准备的基于虚拟机的 PHP 开发环境 (Oracle VM VirtualBox - CentOS)。

环境如下：

> 待续...

----------

## 如何使用

```bash
   yum -y install wget screen
   wget https://github.com/movoin/slacker-devel/archive/master.zip
   tar xzf master.gz
   cd master
   chmod +x install.sh
   screen -S slacker
   # 使用默认配置安装
   ./install.sh
```

## 接下来

#还需要完善的
1.修复漏洞shell
2.本地yum搭建
3.本地代码更新shell更新到Tomcat
4.mysql数据库导入
5.定时删除日志脚本
6.mongodb创建固定size集合、建立复合索引、建立TTL索引
7.开启防火墙，开放指定端口


## 参考项目：

- https://github.com/lj2007331/lnmp
