#!/bin/sh

date >> date.txt 
echo -n "Enter virtual machine Name and press [Enter]"
read name   
echo $name
dir="/vmfs/volumes/577a8d2e-d3ade73a-5f81-e8de27049741/$name" #Директория в которой лежит искомая виртуальная машина
curdate="`date \+\%Y_\%m_\%d`"          #Дата бэкапа
dest="/vmfs/volumes/Store6/"            #Путь к сетевому хранилищу - сервер 10.10.1.6 

ssh -T 10.10.1.12 << EOF                #  Соединение по ключу с гипервизором ESXi
#vim-cmd vmsvc/getallvms > WM_list.txt         # Запись в файл списка всей инфы по виртуальных машин на хосте ESXi
vim-cmd vmsvc/getallvms | grep $name | cut -d " " -f 1 > WM_list.txt
vim-cmd vmsvc/get.tasklist `cat WM_list.txt` > task.txt
cat task.txt >> WM_list.txt

exit                                          # Закрываем ssh
EOF

pattern="(ManagedObjectReference) []"
rm WM_list.txt                                # Удаление старого файла WM_list.txt
scp root@10.10.1.12:/WM_list.txt .            # Закачка файла со списком
id=`cat WM_list.txt | head -n 1`              # нахождение id нужной виртуали
echo "id=$id"
task=`cat WM_list.txt | sed 1d`
echo "task=$task"
ssh -T 10.10.1.12 << EOF                        #  Соединение по ключу с гипервизором ESXi
cd $dir
find . -name '*vmdk' | cut -c 3-  > /file_list.txt
find . \( -name "*vmx" -or -name "*vmx~*" \) -type f | cut -c 3- >> /file_list.txt
#vim-cmd vmsvc/snapshot.create $id Spapshot_$name
echo /file_list.txt
sleep 5s
echo "$dir, $id"
task="`vim-cmd vmsvc/get.tasklist $id`"
echo "a1=$task, b1=$pattern"
#cd /vmfs/volumes/577a8d2e-d3ade73a-5f81-e8de27049741/
#mkdir -p $curdate
#tar -czf Win7.$curdate.gz Win7/
#chmod 0777 Win7.*.gz
#mv Win7.*.gz /vmfs/volumes/Store6
#vim-cmd vmsvc/power.on $id
exit
EOF
date >> date.txt
