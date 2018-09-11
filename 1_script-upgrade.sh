#!/bin/bash
# Проверяем версию дистрибутива debian.
SECONDS=0
printf "\033c"
ver=`cat /etc/*-release | grep VERSION_ID`
#  Если версия 8, то обновляем до 9.
if [ $ver = 'VERSION_ID="8"' ]
  then
    echo "OS version is 8. Upgrading to 9..."
    sed -i '1,20s/jessie/stretch/' /etc/apt/sources.list
    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y
    apt autoremove -y
#  Если версия 9, то просто обновляем всё.
elif [ $ver = 'VERSION_ID="9"' ]
  then
    echo "Updating system..."
    apt-get update
    apt-get upgrade -y
    apt autoremove -y
# Если версия не 8 и не 9, то скрипт завершается и надо руками поправить.
  else
    echo "Что-то пошло не так. Требуется вмешательство."
    exit 0
fi
echo
echo "***** Script \033[33;1m 1\033[0m of \033[33;1m 3\033[0m COMPLETED in $SECONDS seconds *****"
echo
