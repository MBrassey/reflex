#!/usr/bin/env bash
#  ______ _______ _______        _______ _     _
# |_____/ |______ |______ |      |______  \___/ 
# |    \_ |______ |       |_____ |______ _/   \_
version=1.0.0

#Variables
args=("$@")
url=""
string=""
number_1=""
number_2=""
key=""
any=""
anyyn=""
phones=""
phonesyn=""
notified=""
delay="10s"
detect=""

#Colors
reset="$(tput sgr0)"
lineColor="$reset"
black="$(tput bold; tput setaf 0)"
blue="$(tput bold; tput setaf 4)"
cyan="$(tput bold; tput setaf 6)"
green="$(tput bold; tput setaf 2)"
purple="$(tput bold; tput setaf 5)"
red="$(tput bold; tput setaf 1)"
white="$(tput bold; tput setaf 7)"
yellow="$(tput bold; tput setaf 3)"
header="${cyan}╭─────────────────────────╼[${reset}${blue}reflex${reset}${cyan}]${reset}"
footer="${cyan}╰──────────────────╼[${reset}${blue}reflex${reset}${cyan}]${reset}"

license="
${cyan}reflex v${version}${reset}${purple}
Copyright (C) 2017  Matthew A. Brassey

        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.${reset}
"
about="
 ${cyan}reflex v${version}${reset}${purple} is a menu driven tool for monitoring changes on a web page. 
 It uses curl and grep to confirm a phrase is present on the page you supply.
 If the phrase you specify is not present, or has changed, you will be notified.
 You will be given the option to notify 2 phone numbers via SMS. You will need a textbelt.com 
 ID im order to send the texts. Reflex will stop once the notification(s) have been sent. 
 You will have the option to run reflex in the background and logoff.${reset} 
"

help="
${blue}Usage:${reset}${cyan} ./reflex.sh${reset}${purple} [--help|--version|--license|--about]${reset}

${blue}[options]${reset}
${purple}
        --help          Display this message.
        --version       Show version.
        --license       Show lisense information.
        --about         Learn how reflex works.
${reset}
${blue}[Run in backgroud]${reset}
${cyan}        While reflex is running, do:${reset}${purple}
        CTRL+Z
        disown h
        bg 1${reset} 
"
#Functions
function url {
     clear
     echo "$header"
     echo "${cyan}|${reset}"
     printf "${cyan}|${reset}    Enter the ${cyan}URL${reset} you would like to monitor (q to quit) : "
                read -r url
                if [ "$url" = "q" ]; then
                echo "${cyan}|    Bye-Bye${reset}"
                exit
                fi
    echo "${cyan}|${reset}"
    echo "$footer"
}

function string {
     clear
     echo "$header"
     echo "${cyan}|${reset}"
     printf "${cyan}|${reset}    Enter the ${cyan}string${reset} you would like to monitor for changes to (q to quit) : "
                read -r string
                if [ "$string" = "q" ]; then
                echo "${cyan}|    Bye-Bye${reset}"
                exit
                fi
    echo "${cyan}|${reset}"
    echo "$footer"
}

function phones {
     clear
     echo "$header"
     echo "${cyan}|${reset}"
     printf "${cyan}|${reset}    Is there a second phone you would like reflex to notify? (y or n) : "
                read -r phones
     case "$phones" in
          [yY][eE][sS]|[yY])
              phonesyn="1"
              ;;
          *)
              phonesyn="0"
              ;;
     esac 
     echo "${cyan}|${reset}"
     echo "$footer"
}

function number1 {
    clear
    echo "$header"
    echo "${cyan}|${reset}"
    printf "${cyan}|${reset}    Enter the ${cyan}phone number${reset} to notify via sms (q to quit) : "
                read -r number_1
                if [ "$number_1" = "q" ]; then
                echo "${cyan}|    Bye-Bye${reset}"
                echo "${cyan}|${reset}"
                echo "$footer"
                exit
                fi
}

function number2 {
    clear
    echo "$header"
    echo "${cyan}|${reset}"
    printf "${cyan}|${reset}    Enter the ${cyan}second phone number${reset} to notify via sms (q to quit) : "
                read -r number_2
                if [ "$number_2" = "q" ]; then
                echo "${cyan}|    Bye-Bye${reset}"
                echo "${cyan}|${reset}"
                echo "$footer"
                exit
                fi
}

function key {
    clear
    echo "$header"
    echo "${cyan}|${reset}"
    printf "${cyan}|${reset}     Enter your ${cyan}textbelt.com api key${reset} (q to quit) : "
                read -r key
                if [ "$key" = "q" ]; then
                echo "${cyan}|    Bye-Bye${reset}"
                echo "${cyan}|${reset}"
                echo "$footer"
                exit
                fi
}

function monitor {
        echo "${cyan}|${reset}"
        echo "$footer"
        echo ""
            while [ "$detect" = "" ]
            do
                 reading="$(curl -vs "$url" 2>&1 | grep "$string")"  
                 if [ "$reading" = "" ]; then
#                     sendsms1
                      sent=$(date +"%T")
                      echo "${green}✔ ${reset} ${cyan}[${reset}${blue}$number_1${reset}${cyan}]${reset}"
                         if [ "$phonesyn" = "1" ]; then
#                             sendsms2
                              echo "${green}✔ ${reset} ${cyan}[${reset}${blue}$number_2${reset}${cyan}]${reset}"
                         fi                 
                     notified="1"
                 fi
                 if [ "$notified" = "1" ]; then
                     echo "${green}✔ ${reset} ${cyan}[${reset}${green} Complete ${reset}${cyan}]╼[ ${reset}${purple}Change detected @ ${reset}${green}$sent${reset}${cyan} ]${reset}"
                     echo ""
                     exit
                 fi
                 sleep $delay
            done
}

function sendsms1 {
curl -X POST https://textbelt.com/text \
       --data-urlencode phone=$number_1 \
       --data-urlencode message="reflex detected change on $string." \
       -d key=$key
}

function sendsms2 {
curl -X POST https://textbelt.com/text \
       --data-urlencode phone=$number_2 \
       --data-urlencode message="reflex detected change on $string." \
       -d key=$key
}

function message {
     clear
     echo "$header"
     echo "${cyan}|${reset}"
     echo "${cyan}|${reset}${purple}    Notifying:${reset}" 
     echo "${cyan}|${reset}    ${cyan}╼[${reset}${blue}$number_1${reset}${cyan}]${reset}"
     echo "${cyan}|${reset}    ${cyan}╼[${reset}${blue}$number_2${reset}${cyan}]${reset}"
     echo "${cyan}|${reset}"
     echo "${cyan}|${reset}${purple}    Monitoring for changes in:${reset}"
     echo "${cyan}|${reset}    ${cyan}╼[${reset}${blue}$string${reset}${cyan}]${reset}"
     echo "${cyan}|${reset}"
     echo "${cyan}|${reset}${purple}    URL:${reset}"
     echo "${cyan}|${reset}    ${cyan}╼[${reset}${blue}$url${reset}${cyan}]${reset}"
}

#Code
for ((arg=0;arg<"${#args[@]}";arg++)); do
        [ "${args[$arg]}" == "--version" ] && echo "${version}" && exit
        [ "${args[$arg]}" == "--help" ] && echo "${help}" && exit
        [ "${args[$arg]}" == "--license" ] && echo "${license}" && exit
        [ "${args[$arg]}" == "--about" ] && echo "${about}" && exit 
        #[ "${args[$arg]}" == "--" ] && echo ${args[$arg]}
done

url
string
number1
phones
    if [ "$phonesyn" = "1" ]; then
    number2
    fi
key
message
monitor
     echo "${cyan}|${reset}"
     echo "$footer"
exit
