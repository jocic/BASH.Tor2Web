#!/bin/bash

###################################################################
# Script Author: Djordje Jocic                                    #
# Script Year: 2019                                               #
# Script License: MIT License (MIT)                               #
# =============================================================== #
# Personal Website: http://www.djordjejocic.com/                  #
# =============================================================== #
# Permission is hereby granted, free of charge, to any person     #
# obtaining a copy of this software and associated documentation  #
# files (the "Software"), to deal in the Software without         #
# restriction, including without limitation the rights to use,    #
# copy, modify, merge, publish, distribute, sublicense, and/or    #
# sell copies of the Software, and to permit persons to whom the  #
# Software is furnished to do so, subject to the following        #
# conditions.                                                     #
# --------------------------------------------------------------- #
# The above copyright notice and this permission notice shall be  #
# included in all copies or substantial portions of the Software. #
# --------------------------------------------------------------- #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, #
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND        #
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT     #
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,    #
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, RISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR   #
# OTHER DEALINGS IN THE SOFTWARE.                                 #
###################################################################

##################################
# Step 1 - Export Core Variables #
##################################

export J_T2W_USER_ID="$(id -u)";
export J_T2W_SOURCE_DIR="$(cd -- "$(dirname -- "$0")" && pwd -P)";
export J_T2W_VERSION="1.0.0";
export J_T2W_CONF_DIR="tor2web";
export J_T2W_CONF_FILE="basic.conf";
export J_T2W_VERBOSE="no";

##############################
# Step 2 - Include Functions #
##############################

. "$J_T2W_SOURCE_DIR/includes/core.sh";
. "$J_T2W_SOURCE_DIR/includes/system.sh";
. "$J_T2W_SOURCE_DIR/includes/configuration.sh";
. "$J_T2W_SOURCE_DIR/includes/proxy.sh";

##############################
# Step 3 - Check Priviledges #
##############################

if [ "$J_T2W_USER_ID" != 0 ]; then
    printf "[+] This script should be ran with root privileges.\n\n";
fi

######################################
# Step 4 - Create Configuration File #
######################################

if    [ $(create_config_dir;     echo "$?") = 1 ] \
   && [ $(is_config_dir_created; echo "$?") = 1 ]; then
    
    printf "[X] Configuration directory coudn't be created.\n" && exit;
    
elif    [ $(create_config_file;     echo "$?") = 1 ] \
     && [ $(is_config_file_created; echo "$?") = 1 ]; then
    
    printf "[X] Configuration file coudn't be created.\n" && exit;
    
fi

##############################
# STEP 5 - Process Arguments #
##############################

for arg in "$@"; do
    
    # Determine Option
    
    [ "$arg" = "-s" ] || [ "$arg" = "--setup" ] \
        && J_T2W_OPTION="setup";
    
    [ "$arg" = "-h" ] || [ "$arg" = "--help" ] \
        && J_T2W_OPTION="show-help";
    
    [ "$arg" = "-v" ] || [ "$arg" = "--version" ] \
        && J_T2W_OPTION="show-version";
    
    # Handle Flags
    
    [ "$arg" = "-V" ] || [ "$arg" = "--verbose" ] \
        && J_T2W_VERBOSE="yes";
    
done

export J_T2W_OPTION;

############################
# STEP 6 - Process Options #
############################

if [ "$J_T2W_OPTION" = "show-help" ]; then
    show_help;
elif [ "$J_T2W_OPTION" = "show-version" ]; then
    show_version;
elif [ "$J_T2W_OPTION" = "setup" ]; then
    setup;
else
    printf "[X] You didn't provide any option.\n";
fi
