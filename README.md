## OpenGauss 与 Postgresql 的基准测试对比

### 1 服务器配置

本次测试使用华为云服务器，配置为

* 2vCPUs | 4GiB | kc1.large.2
* 系统：openEuler 20.03 64bit with ARM
* CPU：Huawei Kunpeng 920 2.6GHz

### 2 软件配置

#### opengauss 安装过程

使用的 opengauss 版本是 5.0.1。

1. 创建openGauss数据库的安装用户omm及其属组dbgrp，创建安装目录。

   ```bash
   groupadd -g 1000 dbgrp
   useradd -g dbgrp -u 1000 -d /home/omm omm
   mkdir -p /opt/software/openGauss/
   ```

2. 安装依赖包

   ```bash
   yum install -y libaio-devel ncurses-devel pam-devel libffi-devel libtool libtool-devel libtool-ltdl openssl-devel bison golang flex dkms-2.6.1-5.oe1.noarch python3-devel patch --nogpgcheck
   ```

3. 使用vi打开logind.conf文件。

   ```bash
   vi  /etc/systemd/logind.conf
   ```


   按下i字母键进入命令插入模式，修改RemoveIPC的值为no 并去掉前面的 # 号，之后保存并退出。

4. 重新加载配置参数。

   ```bash
   systemctl daemon-reload
   systemctl restart systemd-logind
   ```

5. 修改 /opt/software 路径的用户属组及权限。

   ```bash
   chown omm:dbgrp -R /opt/software
   chmod 755 -R /opt/software
   ```

6. 切换到omm用户并进入 opengauss 文件夹

   ```bash
   su - omm
   cd /opt/software/openGauss/
   ```

7. 下载并解压 opengauss 安装包。

   ```bash
   wget https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.1/arm/openGauss-5.0.1-openEuler-64bit.tar.bz2
   tar -jxf openGauss-5.0.1-openEuler-64bit.tar.bz2 -C /opt/software/openGauss
   ```

8. 进入安装脚本目录并运行 install.sh

   ```bash
   cd /opt/software/openGauss/simpleInstall
   sh install.sh -w GaussDB@123 -p 26000
   ```

9. 修改omm用户的环境变量

   ```bash
   vi ~/.bashrc
   ```

   按下i字母键进入命令插入模式，在ulimit -n 1000000这行前面插入# 号，把这行注释掉，之后保存并退出。

   ```bash
   source ~/.bashrc
   ```

#### postgresql 安装过程

使用的 postgresql 版本是 12.4。

1. 安装依赖包

   ```bash
   yum install -y perl-ExtUtils-Embed readline-devel zlib-devel pam-devel libxml2-devel libxslt-devel openldap-devel python-devel gcc-c++ openssl-devel cmake
   ```

2. 类似安装 OpenGauss 的过程，在 `/opt/software` 目录下新建目录 `pgsql` ，并从官网下载压缩包并解压

   ```bash
   wget https://ftp.postgresql.org/pub/source/v12.4/postgresql-12.4.tar.gz
   tar -xvf postgresql-12.4.tar.gz
   ```

3. 进入解压后的文件夹，编译源码，安装

   ```bash
   cd postgresql-12.4
   ./configure --prefix=/opt/software/pgsql/postgresql
   make && make install
   ```

4. 创建 postgres 用户操作 postgresql

   ```bash
   groupadd postgres
   useradd -g postgres postgres
   mkdir /opt/software/pgsql/postgresql/data
   chown postgres:postgres /opt/software/pgsql/postgresql/data
   ```

5. 将 postgresql 放入环境变量

   ```bash
   vim .bash_profile
   ```

   加入

   ```bash
   export PGHOME=/opt/software/pgsql/postgresql
   export PGDATA=/opt/software/pgsql/postgresql/data
   PATH=$PATH:$HOME/bin:$PGHOME/bin
   ```

   ```bash
   source .bash_profile 
   ```

#### BenchmarkSQL 安装过程

主要参考了 [使用BenchmarkSQL压测openGauss 数据库测试 - 墨天轮](https://www.modb.pro/db/561933) ，跳过了配置白名单和修改并配置建表脚本两步。

同时服务器无法使用 yum 安装 ant，参考[Linux - 安装 Ant - 西瓜_皮 - 博客园](https://www.cnblogs.com/wwho/p/14331761.html) 手动安装了 ant。

### 3 测试过程

#### 3.1 使用 sql 命令测试

详细命令见 report.pdf

#### 3.2 使用 BenchmarkSQL 测试

配置文件 props.pg 如下：

```java
db=postgres
driver=org.postgresql.Driver
conn=jdbc:postgresql://localhost:5432/postgres
user=benchmarksql
password=PWbmsql

warehouses=10
loadWorkers=4

terminals=50
//To run specified transactions per terminal- runMins must equal zero
runTxnsPerTerminal=0
//To run for specified minutes- runTxnsPerTerminal must equal zero
runMins=5
//Number of total transactions per minute
limitTxnsPerMin=0

//Set to true to run in 4.x compatible mode. Set to false to use the
//entire configured database evenly.
terminalWarehouseFixed=true

//The following five values must add up to 100
//The default percentages of 45, 43, 4, 4 & 4 match the TPC-C spec
newOrderWeight=45
paymentWeight=43
orderStatusWeight=4
deliveryWeight=4
stockLevelWeight=4

// Directory name to create for collecting detailed result data.
// Comment this out to suppress.
resultDirectory=my_result_%tY-%tm-%td_%tH%tM%tS
osCollectorScript=./misc/os_collector_linux.py
osCollectorInterval=1
//osCollectorSSHAddr=user@dbhost
osCollectorDevices=net_eth0 blk_sda
```

在测试完 opengauss 之后，需要将 `benchmarksql-5.0/lib/postgres` 目录下的 `postgresql.jar` 移开目录或者修改后缀名，并将 `postgresql-9.3-1102.jdbc41.jar` 放入目录中。

opengauss 详细测试结果：[result of opengauss](https://github.com/sgweo8ys/CS213project3/tree/master/my_result_opengauss)

postgresql 详细测试结果：[result of postgresql](https://github.com/sgweo8ys/CS213project3/tree/master/my_result_postgresql)

#### 3.3 硬件使用情况

测试详情见 report.pdf

### 4 总结

经过比较，可以得出结论：

1. 少量数据下，postgresql 的各种命令运行速度显著快于 opengauss。
2. 大量数据下，绝大部分命令 postgresql 运行速度远远快于 opengauss。但是在建立索引之后的查询下 opengauss 略快于 postgresql 。
3. 在 TPC-C 测试中，postgresql 在高并发操作下处理事务效率远快于 opengauss，但是 opengauss 处理效率更加稳定。
4. 运行查询命令时，postgresql 的 CPU 占用率较 opengauss 更低，更能节约硬件资源。

总的来说，postgresql 相较 opengauss 在性能上仍有较大优势，opengauss 在 TPC-C 测试中表现更加稳定，postgresql 的硬件占用率更低，读带宽更高，写带宽更低。