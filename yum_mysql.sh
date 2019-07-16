#!/bin/bash
#MySQL安装一键脚本（yum安装）
#作者：vidar
#版本：v0.1
#时间：2019年7月11日

#判断系统是否为centos系统
is_centos(){
cat /etc/redhat-release >/dev/null 
if [ $? -eq 0 ];then
	echo "系统是centos"
else
	echo "系统不是centos，即将退出脚本"
	exit
fi
}

#判断MySQL是否安装
is_inmysql(){
rpm -qa|grep mysql >/dev/null
if [ $? -eq 0 ];then
	echo "MySQL已安装"
	echo "是否卸载MySQL[y/n]"
	read un
	if [ $un -eq y ];then
		yum remove mysql
	else
		echo "退出安装！"
		exit
	fi

else 
	echo "MySQL未安装"
fi
}

#安装MySQL源
yum_mysql(){
yum -y install wget
cd
mkdir yum_install
cd yum_install
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum localinstall mysql80-community-release-el7-3.noarch.rpm

 }
 
#选择安装版本
choice_version(){
yum install yum-utils
echo '输入你想安装的版本（1为8.0版本，2为5.7版本，3为5.6版本，4为5.5版本）'
echo '你输入的数字为:'
read aNum
case $aNum in
    1)  echo '你选择了安装MySQL8.0'
		yum install -y  mysql-community-server
    ;;
    2)  echo '你选择了安装MySQL5.7'
		yum-config-manager --disable mysql80-community
		yum-config-manager --enable mysql57-community
		yum install -y  mysql-community-server
    ;;
    3)  echo '你选择了安装MySQL5.6'
		yum-config-manager --disable mysql80-community
		yum-config-manager --enable mysql56-community
		yum install -y  mysql-community-server
    ;;
	4)  echo '你选择了安装MySQL5.5'
		yum-config-manager --disable mysql80-community
		yum-config-manager --enable mysql55-community
		yum install -y  mysql-community-server
    ;;
    *)  echo '选择错误'
		exit
    ;;
esac
}

#管理MySQL服务
mysql_manager(){
	systemctl start mysqld.service
	systemctl status mysqld.service
	systemctl enable mysqld
	ss -natl |grep 3306
	[ $? -eq 0 ]&& echo "MySQL服务已启动..." || echo "MySQL服务未启动" exit
}




is_centos
is_inmysql
yum_mysql
choice_version
mysql_manager


