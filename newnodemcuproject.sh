#!/bin/bash

#Author: Guilherme Mello Oliveira
#Date: May-26-2016

#Description:
# This is a simple wrapper script to create any board project with
# Plattformio, that can be integrated with Vim editor
# Some Vim Plugins are required, install them with your favorite Plugin Manager:
#
# Arduino-Syntax-file : https://github.com/vim-scripts/Arduino-syntax-file
# YouCompleteMe : https://github.com/vim-scripts/Arduino-syntax-file
# YouCompleteMe Configuration example: https://gist.github.com/ajford/f551b2b6fd4d6b6e1ef2
# Syntastic: https://github.com/scrooloose/syntastic 
#

project_name="DefaultProject"
project_dir="$HOME"
project_file="default.c"
board="uno"

optstring=b:n:d:f:h

template="
//Project Name: $project_name
//Owner: $USER
//UID : $UID
\n//Write Here The Project Description
\n\nvoid setup(){\n\n\n
}\n
\n\nvoid loop(){\n\n\n
}\n
"

while getopts $optstring opt; do
    case $opt in
        b) board=$OPTARG
            ;;
        n) project_name=$OPTARG
           ;;

        d) project_dir=$OPTARG
            if [ -d ${project_dir}/${project_name} ]; then 
                    printf "Project already exist"
                    break
            else

                ## Creates Python Virtual Enviroment for Platformio
                source /home/gmello/bin/platformio/venv/bin/activate

                ## Creates Project's Directory
                mkdir -p ${project_dir}/${project_name}
                pushd ${project_dir}/${project_name} &> /dev/null
                
                platformio  init --board "$board" 
                echo -e "upload_port = /dev/ttyUSB0" >> ${project_dir}/${project_name}/platformio.ini 
                echo -e "upload_speed = 115200" >> ${project_dir}/${project_name}/platformio.ini 

                popd &> /dev/null

                ## Exit the Python Virtual Enviroment for Platformio
                deactivate 

                ## Creates the Project's Config files
                cp ~/bin/platformio/.ycm_extra_conf.py ${project_dir}/${project_name}/src/
                cp ~/bin/platformio/Makefile ${project_dir}/${project_name}/src/
                cp ~/.vimrc ${project_dir}/${project_name}
                git init ${project_dir}/${project_name}/src/ &> /dev/null
            fi
         ;;

        f) project_file=$OPTARG
            if [ -f ${project_dir}/${project_name}/${project_file} ]; then 
                printf " ${project_name}.c already exist "
                break
            else
                touch $project_dir/$project_name/src/${project_file}.ino
                echo -e "$template" > ${project_dir}/${project_name}/src/${project_file}.c
            fi
            ;;
         *|h)
             echo "Usage: newnodemcuproject -b <board> -n <project_name> -d <path/to/project/dir> -f <first_project_file> "
             echo -e "-b\tSelect the type of the board\n-n\tProject's name\n-d\tThe location of the project directory\n-f\tThe name of the project first file"
        esac
    done


