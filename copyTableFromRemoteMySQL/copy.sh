#!/bin/bash
ip=`cat copy.properties | grep ip | awk -F'=' '{ print $2 }' | sed s/[[:space:]]//g`
echo "远端服务器ip为：$ip"
userName=`cat copy.properties | grep userName | awk -F'=' '{ print $2 }' | sed s/[[:space:]]//g`
echo "远端服务器MySQL用户名为：$userName"
password=`cat copy.properties | grep password | awk -F'=' '{ print $2 }' | sed s/[[:space:]]//g`
echo "远端服务器MySQL登陆密码为：$password"
databaseName=`cat copy.properties | grep databaseName | awk -F'=' '{ print $2 }' | sed s/[[:space:]]//g`
echo "要复制的表所在的数据库为：$databaseName"
path=`cat copy.properties | grep path | awk -F'=' '{ print $2 }' | sed s/[[:space:]]//g`
echo "导出的sql文件存储路径为：$path"
echo "输入要复制的表名（为空时表示复制整个数据库$databaseName）:"
read tableName
if [ ! -n "$tableName" ]; then
    fileName=$databaseName; #tableName为空，复制整个数据库
else
    fileName=$tableName;
fi
echo "从远端服务器导出${fileName}.sql开始。。。"
echo "mysqldump --column-statistics=0 -h $ip -u $userName -p$password $databaseName $tableName > ${path}/${fileName}.sql"
mysqldump --column-statistics=0 -h $ip -u $userName -p$password $databaseName $tableName > ${path}/${fileName}.sql
echo "${fileName}.sql成功导出"
echo "输入yes确认将${fileName}.sql导入本地数据库："
read exitFlag
if [ ! "$exitFlag" = "yes" ]; then
    exit 1
fi
echo "开始将${fileName}.sql导入本地MySQL数据库。。。"
echo "mysql -hlocalhost -uroot -p123456 $databaseName < ${path}/${fileName}.sql"
mysql -hlocalhost -uroot -p123456 $databaseName < ${path}/${fileName}.sql 
echo "${fileName}.sql成功导入"
echo "复制完成"
