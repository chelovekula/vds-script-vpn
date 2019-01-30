# script
bash scripts<br>
Скрипты автоматизации выдачи OpenVPN-сертификатов<br>
<br>
**Схема работы:**<br>
На vds организуется сервер openvpn, на шлюзе - клиент openvpn. На виртуальной машине в настройках сети указывается наш шлюз.<br>
На шлюзе настроен маршрут, по которому вм выходит в интернет и обратно.<br>
<br>
Пользователь --> OpenVPN-клиент --> OpenVPN-сервер --> Интернет<br>
возврат трафика:<br>
Пользователь <-- OpenVPN-клиент <-- OpenVPN-сервер <-- Интернет<br>
<br>
Подразумевается, что используется vds с предустановленным debian и доступом по root через ssh.<br>
<br>
**Описания скриптов:**<br>
0 - Подготовка vds-машины: загрузка скриптов, обновление ssh-конфига. Подразумевается наличие сгенерированного ssh-ключа authorized_keys.<br>
1 - Обновление ОС. Выполняется проверка версии дистрибутива. Если версия 8, то обновляется до 9. Если 9, то просто обновляется.<br>
2 - Установка ПО: openvpn, asterisk, mc, net-tools, ntp.<br>
3 - Генерация сертификатов, подготовка файлов.<br>
script-delete - Удаление ПО и сертификатов.<br>
<br>
**Работа скриптов:**
1. На vds загружаем скрипт 0_script-prepare.sh и ключ authorized_keys через терминал.
```bash
$ scp 0_script-prepare.sh authorized_keys root@айпи:~
```
2. Подключаемся к vds по ssh, устанавливаем права на запуск скрипта, запускаем скрипт.
```bash
ssh root@айпи
chmod +x 0_script-prepare.sh
./0_script-prepare.sh
```
Обновится файл sshd_config для подключения к vds по ssh с ключом. Скачаются скрипты установки ПО и генерации сертификатов с github.

Можно перезагрузиться.

3. Подлючаемся обратно и запускаем скрипты по очереди.
```bash
ssh root@айпи -i ключ.key
./1_script-upgrade.sh
./2_script-install.sh
./3_script-cert.sh
```
Вся система будет обновлена, установится ПО, сгенерируются сертификаты.<br>
*При генерации сертификатов необходимо будет указать название компании, емэйл и номер туннеля*<br>
При генерации сертификатов скрипт сам нажимает в нужных местах Enter и вводит 'y'.

4. Заходим на шлюз и копируем из VDS/etc/openvpn/user/ все файлы
```bash
scp -i ключ.key root@айпи:/etc/openvpn/user/компания.tar /root/компания
```
*Адрес туннеля по-умолчанию имеет адрес 10.**1**.tun.x для шлюза1. Для шлюза2 адрес нужно будет пока поменять вручную на 10.**2**.tun.x.*
