#!/bin/bash
clear

#脚本变量
date=`date "+%Y%m%d"`
prefix="/usr/local"
CUR_DIR=$(pwd)
zlib_version="zlib-1.2.11"
openssl_version="openssl-1.1.1g"
openssh_version="openssh-8.3p1"
unsupported_system=`cat /etc/redhat-release | grep "release 3" | wc -l`




#检查用户
if [ $(id -u) != 0 ]; then
echo -e "当前登陆用户为普通用户，必须使用Root用户运行脚本，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi


cat /etc/redhat-release | grep 6
if [ $? -eq 0 ];then
	echo -e "Your System is Bleow Redhat or Centos6 " 
	echo ""	
elif [ $? -eq 1 ];then
	echo -e "your System is Redhat7 or Centos7 or above"
	echo ""
elif [ $? -eq No such file or directory ];then
	echo -e "your System Not Redhat or Centos"
	echo ""
else "your system is 未知"
fi

#检查系统
if [ "$unsupported_system" == "1" ];then
clear
echo -e "脚本仅支持操作系统4.x-7.x版本，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi





#升级OpenSSH
function openssh() {
#提示
# echo -e "\033[44;37m你选择的是升级OpenSSH 倒数10秒开始 \033[0m"
# sleep 5

#安装依赖包
yum -y install gcc wget make pam-devel  gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel   > /dev/null 2>&1
if [ $? -eq 0 ];then
echo -e "安装软件依赖包成功" "\033[32m Success\033[0m"
else
echo -e "安装软件依赖包失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi
echo ""


#解压源码包
cd $CUR_DIR
tar xzf $zlib_version.tar.gz
tar xzf $openssl_version.tar.gz
tar xzf $openssh_version.tar.gz
if [ -d $CUR_DIR/$zlib_version ] && [ -d $CUR_DIR/$openssl_version ] && [ -d $CUR_DIR/$openssh_version ];then
echo -e "解压软件源码包成功" "\033[32m Success\033[0m"
else
echo -e "解压软件源码包失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi
echo ""

rm -rf $prefix/zlib* > /dev/null 2>&1

#安装Zlib
cd $CUR_DIR/$zlib_version
./configure --prefix=$prefix/$zlib_version > /dev/null 2>&1
if [ $? -eq 0 ];then
make > /dev/null 2>&1
make install > /dev/null 2>&1
else
echo -e "编译安装压缩库失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi

if [ -e $prefix/$zlib_version/lib/libz.so ];then
echo "$prefix/$zlib_version/lib" >> /etc/ld.so.conf
ldconfig > /dev/null 2>&1
echo -e "编译安装压缩库成功" "\033[32m Success\033[0m"
else
echo -e "编译安装压缩库失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi
echo ""

#删除原版本OpenSSL
rm -rf $prefix/openssl*  > /dev/null 2>&1
rm -rf  /usr/bin/openssl*  > /dev/null 2>&1
rm -rf /usr/include/openssl*  /dev/null 2>&1

#安装OpenSSL
cd $CUR_DIR/$openssl_version
./config --prefix=/usr/local/ssl shared  > /dev/null 2>&1
if [ $? -eq 0 ];then
make > /dev/null 2>&1
make test > /dev/null 2>&1
make install > /dev/null 2>&1
else
echo -e "编译安装OpenSSL失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi

#删除/etc/ld.so.conf

# rm -rf /etc/ld.so.conf > /dev/null 2>&1
# echo -e "删除/etc/ld.so.conf 成功 继续往下操作" "\033[32m Success\033[0m"
echo ""
echo "/usr/local/ssl/lib" >> /etc/ld.so.conf  > /dev/null 2>&1
echo -e "增加文件 /etc/ld.so.conf 成功 继续往下操作" "\033[32m Success\033[0m"
/sbin/ldconfig  > /dev/null 2>&1
echo ""

if [ -e $prefix/ssl/bin/openssl ];then
echo "$prefix/ssl/lib" >> /etc/ld.so.conf
ldconfig > /dev/null 2>&1
echo -e "编译安装OpenSSL成功" "\033[32m Success\033[0m"
fi
echo ""

ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl

#查看安装后的版本

echo -e "查看安装后的版本"

openssl version 
echo ""

echo -e "升级OpenSSL 成功" "\033[32m Success\033[0m"
echo ""

#删除/etc/ssh*

rm -rf /etc/ssh/*  > /dev/null 2>&1
rm -rf $prefix/ssh*  > /dev/null 2>&1


#安装OpenSSH

cd $CUR_DIR/$openssh_version
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=$prefix/ssl --with-zlib=$prefix/$zlib_version --with-pam --with-md5-passwords --with-openssl-includes=$prefix/ssl/include  > /dev/null 2>&1
if [ $? -eq 0 ];then
make > /dev/null 2>&1
make install > /dev/null 2>&1
else
echo -e "编译安装OpenSSH失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
echo ""
sleep 5
exit
fi

if [ -e /usr/sbin/sshd ];then
echo -e "编译安装OpenSSH成功" "\033[32m Success\033[0m"
fi
echo ""

#配置OpenSSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#UseDNS no/UseDNS no/' /etc/ssh/sshd_config

#启动OpenSSH
cp -rf $CUR_DIR/$openssh_version/contrib/redhat/sshd.init /etc/init.d/sshd
cp -rf $CUR_DIR/$openssh_version/contrib/redhat/sshd.pam /etc/pam.d/sshd
chmod +x /etc/init.d/sshd
chkconfig --add sshd
chkconfig sshd on
chmod 600 /etc/ssh/*key

service sshd start # > /dev/null 2>&1

ps aux | grep -w "/usr/sbin/sshd" | grep -v grep > /dev/null 2>&1
if [ $? -eq 0 ];then
echo -e "启动OpenSSH服务成功" "\033[32m Success\033[0m"
echo ""
ssh -V
else
echo -e "启动OpenSSH服务失败，五秒后自动退出脚本" "\033[31m Failure\033[0m"
sleep 5
exit
fi
echo ""

}







#脚本菜单
echo "==============================================================="
echo -e "\033[35m   脚本菜单\033[0m"
echo ""
echo -e "\033[36m1: 升级OpenSSH\033[0m"
echo ""
echo -e "\033[36m2: 退出脚本\033[0m"
echo ""
echo "==============================================================="
read -p  "请输入对应数字后按回车开始执行脚本: " select
echo "==============================================================="


if [ "$select" == "1" ];then
clear
openssh
fi

if [ "$select" == "2" ];then
echo ""
exit
fi


