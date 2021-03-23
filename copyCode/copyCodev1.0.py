import os
import re
import chardet
print('''
 __   __            _____
 \ \ / /           |  __ \\
  \ V /_   _  ___  | |  | | ___  _ __   __ _
   > <| | | |/ _ \ | |  | |/ _ \| '_ \ / _` |
  / . \ |_| |  __/ | |__| | (_) | | | | (_| |
 /_/ \_\__,_|\___| |_____/ \___/|_| |_|\__, |
                                        __/ |
                                       |___/
''')


def copyOneFile(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            # ftext = f.read()
            flist = f.readlines()
            f.close()
            # print(ftext)
    except UnicodeDecodeError:
        print(file_path + "编码格式不是utf-8")
        with open(file_path, 'rb') as exception_file:
            data = exception_file.read()
            result = chardet.detect(data)
            print(file_path + "编码格式信息为：")
            print(result)
            exception_file.close()
            with open(file_path, "r", encoding=result['encoding']) as exception_file_r:
                flist = exception_file_r.readlines()
                exception_file_r.close()
    with open(target_path, "a", encoding="utf-8") as target_file:
        # target_file.write(ftext)
        # target_file.write("\r\n")
        for line in flist:
            if not re.match("\*", line.strip()) and not re.match("/\*", line.strip()) and line.strip() != "" and not re.match("//", line.strip()):
                new_line = re.sub(r"//.*\n", r"\n", line)  # 去除单行行尾注释
                target_file.write(new_line)
        target_file.close()


stack = []
exclude_paths = ['.git', '.idea', 'Minio', 'nacos', 'target', 'test', 'sys-service-app', 'sys-service-admin']
exclude_files = []
code_suffix = []


def copyByStack(directory):
    code_file_num = 0
    stack.append(directory)
    while stack:
        current_path = stack.pop()
        if os.path.isdir(current_path):
            paths = os.listdir(current_path)
            print(current_path + "是目录：")
            print(paths)
            for path in paths:
                if path not in exclude_paths:
                    stack.append(current_path + "\\" + path)
        elif os.path.isfile(current_path):
            current_path_array = current_path.split(".")
            array = current_path.split("\\")
            if current_path_array[-1] in code_suffix:
                print(current_path + "是代码文件")
                if array[-1] not in exclude_files:
                    copyOneFile(current_path)
                    code_file_num = code_file_num + 1
            else:
                print(current_path + "是非代码文件")
        else:
            pass
    print("总共" + str(code_file_num) + "个代码文件")


# 删除html注释
def deleteHtmlComment(file_name):
    with open(file_name, "r", encoding="utf-8") as f:
        ftext = f.read()
        f.close()
        print(len(ftext))
        # print(ftext)
    with open(file_name, "w", encoding="utf-8") as target_file:
        new_text = re.sub("<!--(.|[\r\n])*?-->", "", ftext)
        target_file.write(new_text)
        target_file.close()
        print(len(new_text))


file_path = input("请输入项目代码所在路径(例如C:\code\cmii\\backend)：")
target_path = input("请输入最终代码存放文件路径(例如C:\code\python\copySheet\\target.txt，该文件要存在且为空):")
suffix_str = input("请输入代码文件的后缀名，多个后缀名使用英文逗号分隔(例如：vue,js,css,html,scss,jsx):")
code_suffix = suffix_str.strip(',').split(',')
for i in range(len(code_suffix)):
    code_suffix[i] = code_suffix[i].strip(' ')


copyByStack(file_path)
deleteHtmlComment(target_path)
