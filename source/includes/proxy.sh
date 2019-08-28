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

# GET FUNCTIONS GO HERE

#################
# SET FUNCTIONS #
#################

# GET FUNCTIONS GO HERE

##################
# CORE FUNCTIONS #
##################

# Setups <i>Tor2Web</i> proxy on the current machine.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

setup()
{
    # Core Variables
    
    setup_status="$(get_config_param 'setup_status')";
    
    # Logic
    
    if [ -z "$setup_status" ]; then
        
        prepare_system && setup_tor && \
            setup_tor2web && setup_apache;
        
    else
        
        printf "[X] Tor2Web has already been setup on this machine.\n";
        
    fi
    
    return 0;
}

###################
# CHECK FUNCTIONS #
###################

# CHECK FUNCTIONS GO HERE

###################
# OTHER FUNCTIONS #
###################

# Prepares the system for <i>Tor2Web</i> setup.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

prepare_system()
{
    # Logic
    
    printf "[*] Preparing the system...\n";
    
    yum clean all && yum update -y && yum install centos-release-scl -y;
    
    yum install python36-pip python36-devel libffi-devel -y && \
        yum groupinstall "Development Tools" -y;
    
    return 0;
}

# Setups <i>Tor</i> on the machine.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

setup_tor()
{
    # Logic
    
    printf "[*] Setting up Tor...\n";
    
    yum install tor privoxy -y && \
        systemctl start tor && systemctl enable tor;
}

# Setups <i>Tor2Web</i> on the machine.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.


setup_tor2web()
{
    # Logic
    
    printf "[*] Setting up Tor2Web...\n";
    
    wget https://deb.globaleaks.org/install-tor2web.sh && \
        chmod +x install-tor2web.sh && ./install-tor2web.sh;
}

# Setups <i>Apache2</i> on the machine.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

setup_apache()
{
    # Logic
    
    printf "[*] Setting up Apache2...\n";
    
    yum install httpd mod_ssl -y && \
        firewall-cmd --permanent --add-port=80/tcp && \
            firewall-cmd --permanent --add-port=443/tcp && \
                firewall-cmd --reload && \
                    systemctl start httpd && systemctl enable httpd;
    
    return 0;
}
