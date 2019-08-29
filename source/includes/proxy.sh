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
        
        check_system && prepare_system && setup_tor && \
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
    
    # Logic
    
    [ "$distro" != "debian" ] && [ "$distro" != "centos" ] && \
        printf "[X] Your distribution isn't supported.\n" && exit 1;
    
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
    
    if [ "$distro" = "debian" ]; then
        
        # Install Prerequisities
        
        apt-get update && apt-get install gpg python-pip python-dev \
            build-essential wget libffi-dev pwgen -y;
        
        # Setup Tor Repository
        
        printf "deb http://deb.torproject.org/torproject.org stable main
deb-src http://deb.torproject.org/torproject.org stable main\n" \
            > "/etc/apt/sources.list.d/tor.list";
        
        gpg --import "$J_T2W_SOURCE_DIR/other/gpg/tor.asc" && \
            gpg --export "A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89" | \
                apt-key add -;
        
        # Import GlobaLeaks Key
        
        gpg --import "$J_T2W_SOURCE_DIR/other/gpg/globaleaks.asc" && \
            gpg --export "B353922AE4457748559E777832E6792624045008" | \
                apt-key add -;
        
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
    # Core Variables
    
    distro="$(get_distro_name)";
    
    # Other Variables
    
    sum="";
    
    # Logic
    
    printf "[*] Setting up Tor...\n";
    
    if [ "$distro" = "debian" ]; then
        
        # Install Dependencies
        
        apt-get install apparmor apparmor-utils python3-cryptography \
            python3-openssl python3-twisted -y;
        
        # Check Integrity
        
        sum="$(sha256sum "$J_T2W_SOURCE_DIR/other/packages/tor.deb" | cut -d " " -f 1)";
        
        if [ "$sum" != "7aece86efaafb28175dd29478ea8de482500b6cbc1ed52ec3b4ce047b4f86784" ]; then
            printf "[X] Invalid Tor debian package.\n" && exit 1;
        fi
        
        # Install Tor
        
        dpkg -i "$J_T2W_SOURCE_DIR/other/packages/tor.deb";
        
    elif [ "$distro" = "centos" ]; then
        
        yum install tor -y;
        
    else
        
        printf "[X] Your distribution isn't supported.\n" && exit 1;
        
    fi
    
    systemctl start tor && systemctl enable tor;
    
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
    
    if [ "$distro" = "debian" ]; then
        
        # Install Dependencies
        
        apt-get install apparmor apparmor-utils python3-cryptography \
            python3-openssl python3-twisted -y;
        
        # Check Integrity
        
        sum="$(sha256sum "$J_T2W_SOURCE_DIR/other/packages/tor2web.deb" | cut -d " " -f 1)";
        
        if [ "$sum" != "6d711ad3518a4781a7df1844e3a9fc02583037b8035375c4a221d6a6b12fc451" ]; then
            printf "[X] Invalid Tor2Web debian package.\n" && exit 1;
        fi
        
        # Install Tor2Web
        
        dpkg -i "$J_T2W_SOURCE_DIR/other/packages/tor2web.deb";
        
        sed -i "s/APPARMOR_SANDBOXING=1/APPARMOR_SANDBOXING=0/" \
            "/etc/default/tor2web";
        
        mv "usr/lib/python3.6/dist-packages/tor2web" \
            "usr/lib/python3/dist-packages";
        
        # Generate Tor2Web Certificate
        
        openssl genrsa -out "/home/tor2web/certs/tor2web-key.pem" 4096;
        
        openssl req -new -key "/home/tor2web/certs/tor2web-key.pem" \
            -out "/home/tor2web/certs/tor2web-csr.pem" \
                -subj "/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=tor.org";
        
        openssl x509 -req -days 365 -in "/home/tor2web/certs/tor2web-csr.pem" \
            -signkey "/home/tor2web/certs/tor2web-key.pem" \
            -out "/home/tor2web/certs/tor2web-cert.pem";
        
        # Configure Tor2Web
        
        sed -i "s/# nodename = [UNIQUE_IDENTIFIER]/nodename = $node/" \
            "/usr/share/tor2web/data/conf/tor2web-default.conf"
        
        sed -i "s/# dummyproxy = https://127.0.0.1:8080/dummyproxy = https://127.0.0.1:8080/" \
            "/usr/share/tor2web/data/conf/tor2web-default.conf"
        
    elif [ "$distro" = "centos" ]; then
        
        yum install tor privoxy -y;
        
    else
        
        printf "[X] Your distribution isn't supported.\n" && exit 1;
            
    fi
    
    systemctl start tor2web && systemctl enable tor2web;
    
    return 0;
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
    
    if [ "$distro" = "debian" ]; then
        
        echo "...";
        
    elif [ "$distro" = "centos" ]; then
        
        yum install httpd mod_ssl -y && \
            firewall-cmd --permanent --add-port=80/tcp && \
                firewall-cmd --permanent --add-port=443/tcp && \
                    firewall-cmd --reload && \
                        systemctl start httpd && systemctl enable httpd;
        
    else
        
        printf "[X] Your distribution isn't supported.\n" && exit 1;
        
    fi
    
    return 0;
}
