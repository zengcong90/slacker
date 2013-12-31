PHP 编译参数详解
================

`--prefix=/usr/local/php`
指定 php 安装目录

`--with-apxs2=/usr/local/apache/bin/apxs`
整合 apache, apxs功能是使用 mod_so 中的 LoadModule 指令，加载指定模块到 apache，要求 apache 要打开SO模块

`--with-config-file-path=/usr/local/php/etc`
指定 php.ini 位置

`--with-config-file-scan-dir=/etc/php.d`
指定 Additional .ini 文件扫描位置

`--with-MySQL=/usr/local/mysql`
mysql安装目录，对mysql的支持

`--with-mysqli=/usr/local/mysql/bin/mysql_config`
mysqli 扩展技术不仅可以调用 MySQL 的存储过程、处理 MySQL 事务，而且还可以使访问数据库工作变得更加稳定。

`--enable-safe-mode`
打开安全模式

`--enable-ftp`
打开ftp的支持

`--enable-zip`
打开对 zip 的支持

`--with-bz2`
打开对 bz2 文件的支持

`--with-jpeg-dir`
打开对 jpeg 图片的支持

`--with-png-dir`
打开对 png 图片的支持

`--with-freetype-dir`
打开对 freetype 字体库的支持

`--without-iconv`
关闭 iconv 函数，种字符集间的转换

`--with-libXML-dir`
打开libxml2库的支持

`--with-XMLrpc`
打开xml-rpc的c语言

`--with-zlib-dir`
打开zlib库的支持

`--with-gd`
打开gd库的支持

`--enable-gd-native-ttf`
支持TrueType字符串函数库

`--with-curl`
打开curl浏览工具的支持

`--with-curlwrappers`
运用curl工具打开url流

`--with-ttf`
打开freetype1.*的支持，可以不加了

`--with-xsl`
打开XSLT 文件支持，扩展了 libXML2 库 ，需要 libxslt 软件

`--with-gettext`
打开gnu 的gettext 支持，编码库用到

`--with-pear`
打开pear命令的支持，PHP扩展用的

`--enable-calendar`
打开日历扩展功能

`--enable-mbstring`
多字节，字符串的支持

`--enable-bcmath`
打开图片大小调整,用到 zabbix 监控的时候用到了这个模块

`--enable-sockets`
打开 sockets 支持

`--enable-exif`
图片的元数据支持

`--enable-magic-quotes`
魔术引用的支持

`--disable-rpath`
关闭额外的运行库文件

`--disable-debug`
关闭调试模式

`--with-mime-magic=/usr/share/file/magic.mime`
魔术头文件位置

`--enable-fpm`
打上PHP-fpm 补丁后才有这个参数，CGI方式安装的启动程序

`--enable-fastCGI`
支持fastcgi方式启动PHP

`--enable-force-CGI-redirect`
重定向方式启动PHP

`--with-ncurses`
支持ncurses 屏幕绘制以及基于文本终端的图形互动功能的动态库

`--enable-pcntl`
freeTDS 需要用到的，可能是链接 mssql 才用到

`--with-mcrypt`
算法

`--with-mhash`
算法

`--with-gmp`
应该是支持一种规范

`--enable-inline-optimization`
优化线程

`--with-openssl`
openssl的支持，加密传输时用到的

`--enable-dbase`
建立DBA 作为共享模块

`--with-pcre-dir=/usr/local/bin/pcre-config`
perl的正则库案安装位置

`--disable-dmalloc`

`--with-gdbm`
dba的gdbm支持

`--enable-sigchild`

`--enable-sysvsem`

`--enable-sysvshm`

`--enable-zend-multibyte`
支持 zend 的多字节

`--enable-mbregex`

`--enable-wddx`

`--enable-shmop`

`--enable-soap`
