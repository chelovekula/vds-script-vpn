# vds-script-vpn
(bash scripts)<br>
<br>
**Описание скриптов:**<br>
Скрипты автоматизации процесса настройки маршрутных файлов и OpenVPN-сертификатов для постройки одинарного туннеля.<br>
<br>
**Схема работы:**<br>
На vds организуется сервер openvpn, на шлюзе - клиент openvpn. На виртуальной машине в настройках сети указывается наш шлюз.<br>
На шлюзе настроен маршрут, по которому вм выходит в интернет и обратно.<br>
<br>
Пользователь --> OpenVPN-клиент --> OpenVPN-сервер --> Интернет<br>
возврат трафика:<br>
Пользователь <-- OpenVPN-клиент <-- OpenVPN-сервер <-- Интернет<br>
<br>
Более определённый пример:<br>
Виртуальная машина (клиент-банк, документооборт) с внутренним ip <--> Шлюз <--> VDS с внешним ip
<br><br>
Шлюз один. Виртуальных (или обычных) машин внутри сети может быть много. Для каждой машины нужен отдельный vds со своим внешним ip.
<br><br>
Все скрипты настроены на debian и доступом по root через ssh.<br>
<br>
**Содержимое скриптов:**<br>
0 - Подготовка vds-машины: загрузка скриптов, обновление ssh-конфига. Подразумевается наличие сгенерированного ssh-ключа authorized_keys (см. <a href="https://github.com/Krushon/vds-script-vpn/wiki">wiki</a>).<br>
1 - Обновление ОС. Выполняется проверка версии дистрибутива. Если версия 8, то обновляется до 9. Если 9, то просто обновляется.<br>
2 - Установка ПО: openvpn, asterisk, mc, net-tools, ntp, fail2ban.<br>
3 - Генерация сертификатов, подготовка файлов.<br>
script-delete - Удаление ПО и сертификатов.<br>
<br>
**Предлагаемый софт для установки:**<br>
openvpn - приложение для создания безопасного ip-туннеля через единый udp- или tcp-порт<br>
asterisk - телефонная станция и набор инструментальных средств для телефонии<br>
mc - MidnightCommander - полноэкранный текстовый файловый менеджер<br>
ntp - Network Time Protocol - сетевая служба времени и вспомогательные программы<br>
ntpdate - клиент для получения системного времени с серверов NTP<br>
net-tools - важные инструменты управления сетевой подсистемой ядра Linux<br>
fail2ban - отслеживает файлы журнала и временно или посотянно запрещает доступ нарушителям<br>
<br>
**Работа со скриптами:**
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

**Работа с сертификатами на шлюзе:**

4. Заходим на шлюз и копируем из VDS/etc/openvpn/user/ все файлы
```bash
scp -P порт_ssh -i ключ.key root@айпи:/etc/openvpn/user/компания.tar /root/компания
```
*Адрес туннеля по-умолчанию имеет адрес 10.**1**.tun.x для шлюза1. Для шлюза2 адрес нужно будет пока поменять вручную на 10.**2**.tun.x.*

5. Если планируется множественное использование сертификатов, то для упрощения обработки можно сделать скрипт на копирование.

5.1. Делаем алиас для ip vds. Прописываем в файле /etc/hosts ip vds и его понятное название. Например:
```bash
mcedit /etc/hosts
123.456.78.90      company1
```
Название для алиаса удобно взять такое же, как указывали в переменной $company при генерации сертификатов.

5.2. Делаем скрипт на копирование пользовательских скриптов с vds:
```bash
nano copy-vds-ca.sh
#!/bin/bash
mkdir "$1"
scp -P порт_ssh -i ключ.key root@"$1":/etc/openvpn/user/"$1".tar .
mv "$1".tar ~/"$1"
tar -xvf ~/"$1"/"$1".tar -C ~/"$1"
chmod 766 ~/"$1"/"$1"-up.sh
```
Скрипт при вызове "./copy-vds-ca.sh company1" создаст папку, скопирует и распакует архив с сертификатами.
Далее эти сертификаты копируем в папку /etc/openvpn/company1, файл @company1-user.conf переносим в /etc/openvpn.
