Slacker-PHP Development Environment
=====================================

Slacker 是一个为像我一样的懒虫准备的 LNMP PHP 开发环境 (CentOS)。

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
   ./slacker.sh
```

## 如何管理服务

Nginx:
```bash
   service nginx {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}
```

MySQL:
```bash
   service mysql {start|stop|restart|reload|force-reload|status}
```

PHP:
```bash
   service php-fpm {start|stop|force-quit|restart|reload|status}
```

Memcached:
```bash
   service memcached {start|stop|status|restart|reload|force-reload}
```

## 接下来

> 待续...


## 参考项目：

- https://github.com/lj2007331/lnmp
