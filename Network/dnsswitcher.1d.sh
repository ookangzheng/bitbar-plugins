#!/usr/bin/env bash
#
# DNS Switcher
# The list of DNS options should be defined on this file
#
# <bitbar.title>DNS Switcher</bitbar.title>
# <bitbar.version>v1.5</bitbar.version>
# <bitbar.author>ookangzheng</bitbar.author>
# <bitbar.author.github>ookangzheng</bitbar.author.github>
# <bitbar.desc>Switch DNS to your defined DNS options.</bitbar.desc>
# <bitbar.image>http://oi66.tinypic.com/2yplm4h.jpg</bitbar.image>
# <bitbar.abouturl>https://github.com/ookangzheng/bitbar-plugins/edit/master/Network/dnsswitcher.1d.sh</bitbar.abouturl>


# Configuration
# set your network service
network_service="Wi-FI"

# add or remove list of DNS options below, don't forget to make it enabled. see below
# shellcheck disable=2034
localhost="127.0.0.1
           ::1"

localhost+blahdns="127.0.0.1
                   ::1
                   45.63.124.65
                   
                   2001:19f0:7002:1249:5400:1ff:fe70:15a6"
                   
localhost+NTUT="127.0.0.1
                ::1
                
                140.124.13.2
                140.124.13.1"

NTUT="140.124.13.2
      140.124.13.1"

blahdns="45.63.124.65

         2001:19f0:7002:1249:5400:1ff:fe70:15a6"

google="8.8.8.8
        8.8.4.4

        2001:4860:4860::8888
        2001:4860:4860::8844"

# shellcheck disable=2034
cleanbrowsing="185.228.168.9

               2a0d:2a00:1::2"

cloudflare="1.0.0.1
            1.1.1.1
            
            2606:4700:4700::1001"
   
quad9="9.9.9.9

       2620:fe::fe"

# shellcheck disable=2034
default="empty"

enabled_dns_address=(google level3 opendns norton default)
########################


selected_dns="Unknown"
current_dns_output="$(networksetup -getdnsservers $network_service)"

if [[ $current_dns_output == There* ]] # For e.g. "There aren't any DNS Servers set on Wi-Fi."
then
    selected_dns="default"
else
    IFS=', ' read -r -a current_dns_address <<< "$current_dns_output"

    for dns_name in "${enabled_dns_address[@]}"
    do
        for current_dns in "${current_dns_address[@]}"
        do
        dns_option="$(eval echo \$"${dns_name}" | xargs)"
            if [[ $dns_option == *"$current_dns"* ]]
            then
                selected_dns="$dns_name"
            fi
        done
    done
fi


### Bitbar Menu
if [[ $selected_dns == "Unknown" ]]
then
    echo "Unrecognized DNS"
else
    echo "$selected_dns"
fi

echo "---"

tmp_dir="/tmp"
for dns_name in "${enabled_dns_address[@]}"
do
  switcher="$tmp_dir/bitbar_dns_switcher_${dns_name}"
  cat <<EOF > "$switcher"
dns_address='$(eval "echo \${${dns_name[*]}}")'
networksetup -setdnsservers $network_service \$(echo \$dns_address)
EOF
  chmod 700 "$switcher"
  echo "$dns_name | bash=$switcher | terminal=false | refresh=true"
done
