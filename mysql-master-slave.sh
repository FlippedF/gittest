#!/bin.bash
#!/bin/bash
#MySQL安装一键脚本（yum安装）
#作者：vidar
#版本：v1
#时间：2019年6月15日
function menu()
{
    cat << EOF
----------------------------------------
|***********主从复制一键脚本***********|
----------------------------------------
`1、echo -e "mariadb-master"`
`2、echo -e "mariadb-slave"`
`3、echo -e "返回主菜单"`
`4、echo -e "输入其它，即可退出"`
EOF
read -p "请输入对应的数字：" num
case $num in
    1)
      echo "mariadb-master配置"
      mariadb-master
      ;;
    2)
      echo "mariadb-slave配置"
      mariadb-slave
      ;;
    3)
      clear
      menu
      ;;
    *)
      exit 0
esac
}

function mariadb-master(){
service  firewalld  stop
chkconfig  firewalld  off
setenforce  0
getenforce
sed  -i  's/^SELINUX=enforcing/SELINUX=permissive/'  /etc/selinux/config
yum  install  -y  mariadb  mariadb-server
service  mariadb restart
chkconfig  mariadb  on
sed -i '1aserver_id=13'  /etc/my.cnf
sed -i '2alog-bin=mysql-bin'  /etc/my.cnf
sed -i '3askip-name-resolv'  /etc/my.cnf
service  mariadb restart
mysql -uroot  -e "grant  all on *.*  to  admin@'%'  identified  by '01';flush privileges;"
mysql -uroot  -e "grant  replication slave on *.*  to  rep@'%'  identified  by '01';flush privileges;"
mysql -uroot  -e "select user,host,password from  mysql.user;"
mysql  -uroot  -e  "change master to master_host='192.168.11.12',master_user='rep',master_password='01',master_port=3306,master_log_file='mysql-bin.000001',master_log_pos=245;"
sleep  30s
mysql  -uadmin  -p01 -h  -e  "start slave;show  slave  status\G"
}

function mariadb-slave(){
service  firewalld  stop
chkconfig  firewalld  off
setenforce  0
getenforce
sed  -i  's/^SELINUX=enforcing/SELINUX=permissive/'  /etc/selinux/config
yum  install  -y  mariadb  mariadb-server
service  mariadb restart
chkconfig  mariadb  on
sed -i '1aserver_id=13'  /etc/my.cnf
sed -i '2alog-bin=mysql-bin'  /etc/my.cnf
sed -i '3askip-name-resolv'  /etc/my.cnf
service  mariadb restart
mysql -uroot  -e "grant  all on *.*  to  root@'%'  identified  by '01';flush privileges;"
mysql -uroot  -e "grant  all on *.*  to  admin@'%'  identified  by '01';flush privileges;"
mysql -uroot  -e "grant  replication slave on *.*  to  rep@'%'  identified  by '01';flush privileges;"
mysql -uroot  -e "select user,host,password from  mysql.user;"
mysql  -uroot  -e  "change master to \
	master_host='192.168.11.12',\
	master_user='rep',\
	master_password='01',\
	master_port=3306,\
	master_log_file='mysql-bin.000001',\
	master_log_pos=245;start slave;"
sleep  30s
mysql  -uroot  -e  "show  slave  status\G"

}