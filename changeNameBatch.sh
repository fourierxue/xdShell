echo "请输入要文件夹路径，该文件夹下的所有文件将被批量修改文件名："
read directory
echo "请输入文件名前缀："
read prefix
echo "请输入连接符，默认使用_，最终文件名为【前缀_数字】："
read join
if [ ! -n "$join" ]; then
    join=_
fi
cd $directory
c=1
for file in `ls`
do
    echo $file
    echo “filename: ${file%.*}”
    echo “extension: ${file##*.}”
    mv $file $prefix$join$c.${file##*.}
    ((c++))
done
ls
