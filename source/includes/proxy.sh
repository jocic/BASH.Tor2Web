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
        check_system && prepare_system && setup_tor2web;
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

# Checks if current system is supported or not.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

check_system()
{
    # Core Variables
    
    distro="$(get_distro_name)";
    version="$(get_distro_version)";
    
    # Logic
    
    if [ "$distro" == "ubuntu" ] && [ "$version" != "16.04" ]; then
        printf "[X] Version of Ubuntu isn't supported.\n" && exit 1;
    else
        printf "[X] Distribution isn't supported.\n" && exit 1;
    fi
    
    return 0;
}

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
    # Core Variables
    
    distro="$(get_distro_name)";
    
    # Logic
    
    printf "[*] Preparing the system...\n";
    
    if [ "$distro" = "ubuntu" ]; then
        
        # Setup GlobaLeaks Repository
        
        printf "deb https://deb.globaleaks.org xenial/
deb-src https://deb.globaleaks.org xenial/\n" \
            > "/etc/apt/sources.list.d/globaleaks.list";
        
        gpg --import "$J_T2W_SOURCE_DIR/other/gpg/globaleaks.asc" && \
            gpg --export "B353922AE4457748559E777832E6792624045008" | \
                apt-key add -;
        
        printf "APT::Get::AllowUnauthenticated \"true\";
APT::Get::AllowInsecureRepositories \"true\";" > "/etc/apt/apt.conf.d/99tor2web";
        
        # Update System
        
        apt-get update && apt-get upgrade -y;
        
    elif [ "$distro" = "centos" ]; then
        
        yum clean all && yum update -y && yum install centos-release-scl -y;
        
        yum install python36-pip python36-devel libffi-devel -y && \
            yum groupinstall "Development Tools" -y;
       
    else
        
        printf "[X] Your distribution isn't supported.\n" && exit 1;
        
    fi
    
    return 0;
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
    # Core Variables
    
    distro="$(get_distro_name)";
    
    # Other Variables
    
    sum="";
    node="$(pwgen 10 1");
    
    # Logic
    
    printf "[*] Setting up Tor2Web...\n";
    
    if [ "$distro" = "ubuntu" ]; then
        
        # Install Tor2Web
        
        apt-get install tor2web -y;
        
        sed -i "s/APPARMOR_SANDBOXING=1/APPARMOR_SANDBOXING=0/" \
            "/etc/default/tor2web";
        
        # Generate Tor2Web Certificate
        
        openssl genrsa -out "/home/tor2web/certs/tor2web-key.pem" 4096;
        
        openssl req -new -key "/home/tor2web/certs/tor2web-key.pem" \
            -out "/home/tor2web/certs/tor2web-csr.pem" \
                -subj "/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=tor.org";
        
        openssl x509 -req -days 365 -in "/home/tor2web/certs/tor2web-csr.pem" \
            -signkey "/home/tor2web/certs/tor2web-key.pem" \
            -out "/home/tor2web/certs/tor2web-cert.pem";
        
        # Apply Tor2Web
        
        sed -i "s/# nodename = [UNIQUE_IDENTIFIER]/nodename = $node/" \
            "/etc/tor2web.conf"
        
    elif [ "$distro" = "centos" ]; then
        
        yum install tor privoxy -y;
        
    else
        
        printf "[X] Your distribution isn't supported.\n" && exit 1;
            
    fi
    
    systemctl start tor2web && systemctl enable tor2web;
    
    return 0;
}
