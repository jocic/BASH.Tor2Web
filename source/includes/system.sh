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

#################
# GET FUNCTIONS #
#################

# Gets distribution's name of the current system.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   Value <i>0</i> for <i>SUCCESS</i>, or value <i>1</i> for <i>FAILURE</i>.

get_distro_name()
{
    # Logic
    
    cat "/etc/os-release" | grep -m 1 -P '^ID=(.*)$' | \
        cut -d "=" -f 2 | sed "s/\"//g";
    
    return 0;
}

# Gets distribution's version of the current system.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   Value <i>0</i> for <i>SUCCESS</i>, or value <i>1</i> for <i>FAILURE</i>.

get_distro_version()
{
    # Logic
    
    cat "/etc/os-release" | grep -m 1 -P "^VERSION_ID=(.*)$" | \
        cut -d "=" -f 2 | sed "s/\"//g";
    
    return 0;
}

# Gets distribution's codename of the current system.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   Value <i>0</i> for <i>SUCCESS</i>, or value <i>1</i> for <i>FAILURE</i>.

get_distro_codename()
{
    # Logic
    
    cat "/etc/os-release" | grep -m 1 -P "^VERSION_CODENAME=(.*)$" | \
        cut -d "=" -f 2 | sed "s/\"//g";
    
    return 0;
}

#################
# SET FUNCTIONS #
#################

# SET FUNCTIONS GO HERE

##################
# CORE FUNCTIONS #
##################

# CORE FUNCTIONS GO HERE

###################
# CHECK FUNCTIONS #
###################

# CHECK FUNCTIONS GO HERE

###################
# OTHER FUNCTIONS #
###################

# OTHER FUNCTIONS GO HERE
