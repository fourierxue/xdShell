cd C:/Users/86188/Pictures/background
c=0
for file in `ls`
do 
    fileList[$c]="$file"
    ((c++))
done
total=${#fileList[*]}
echo 壁纸总数为：$total
#echo 第一张为： ${fileList[0]}
#echo 最后一张为：${fileList[102]}
while ((c >= 0))
do
#    echo ${fileList[$c]}
    ((c--))
done
settingFile=C:/Users/86188/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json
#awk '/"backgroundImage"/{print NR}' $settingFile
randomIndex=$[$RANDOM%$total]
#echo 随机下标为：$randomIndex
path=C:\\\\\\\\Users\\\\\\\\86188\\\\\\\\Pictures\\\\\\\\background\\\\\\\\
prefix='"backgroundImage": "'
postfix='",'
result=$prefix$path${fileList[$randomIndex]}$postfix
echo $result
#echo $settingFile
sed -i "s/^.*\"backgroundImage\":.*$/$result/" $settingFile
