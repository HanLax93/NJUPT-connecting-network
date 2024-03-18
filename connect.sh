#!/bin/bash

logger() {
    title=$1
    content=$2
    if [[ $title == "e" ]]; then
      echo "[ERROR]" $content
    else
      echo "[INFO]" $content
    fi
}

connect() {
    echo "Please enter username:"
    read -r username
    echo "Please enter password: (password doesn't display)"
    read -rs password
    logger i "Loading"
    # userip=$(ip addr show | grep eth2.2 | grep inet | awk '{print $2}' | awk -F'[/]' '{print $1}')
    userip=$(curl -s 192.168.168.168 | grep ss5 | grep -oP "ss5=\"\K[^\"]+")
    sp='njupt'
    target="https://p.njupt.edu.cn:802/eportal/portal/login?callback=dr1003&login_method=1&user_account=%2C0%2C${username}%40njupt&user_password=${password}&wlan_user_ip="${userip}"&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=9030&lang=zh"

    # curl -s --connect-timeout 3 $target > /dev/null
    msg=$(curl -s --connect-timeout 3 $target | grep -o '"msg":"[^"]*"' | sed 's/"msg":"\(.*\)"/\1/')

    res=$(curl -s --connect-timeout 2 6.6.6.6 > /dev/null)
    if [[ $? != 0 ]]; then
        logger i "Connect succeed"
    else
        logger e "Connect failed: "$msg
    fi
}

logout() {
  res=$(curl -s "http://p.njupt.edu.cn:801/eportal/?c=ACSetting&a=Logout")
  if [[ $res =~ "succeed" ]]; then
    logger i "Logout succeed"
  else
    logger e "Logout failed"
  fi
}

main() {
    if [[ "$1" == "out" ]]; then
      echo -n "Confirm logout? (y/n)"
      read -r confirm
      if [[ $confirm == "y" ]]; then
        logout
      fi
      return 7
    fi

    logger i "Script starts"

    res=$(curl -s --connect-timeout 2 6.6.6.6 > /dev/null)
    if [[ $? != 0 ]]
    then
        logger e "It seems to be connected ALREADY"
    else
        logger i "Try to authenricate"
        connect
    fi
}

main $1
