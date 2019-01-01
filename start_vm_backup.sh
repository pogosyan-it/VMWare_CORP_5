#!/bin/sh

dir="/home/it/scripts"
echo "Время начало бэкапа: $(date)" > $dir/date.txt
scp  $dir/WM_Name.txt 10.10.1.5:/scripts/WM_Name.txt # копируем файл с названием виртуальной машины подлежащей бэкапу на ESXi

ssh -T 10.10.1.5 << EOF                #  Соединение по ключу с гипервизором ESXi
sh /scripts/check_snapshot.sh          # Запускаем скрипт бэкапа виртуальных машин 
sh /scripts/result_report.sh           # Запускаем скрипт  получения отчета о сделанных бэкапах
exit                                   # Закрываем ssh
EOF
cd $dir
echo "Время завершения бэкапа: $(date)" >> date.txt
scp root@10.10.1.5:/scripts/res.txt .
cat res.txt >> date.txt
rm res.txt
mail -s "VM Bacup CORP" it@int.dmcorp.ru < date.txt
