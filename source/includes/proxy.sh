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
    
    local setup_status="$(get_config_param 'setup_status')";
    
    # Logic
    
    if [ -z "$setup_status" ]; then
        
        check_system && prepare_system && setup_tor2web && \
            clean_system && print_dns_instructs;
        
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
    
    local distro="$(get_distro_name)";
    local version="$(get_distro_version)";
    
    # Logic
    
    if [ "$distro" == "ubuntu" ]; then
        
        if [ "$version" != "16.04" ] && [ "$version" != "18.04" ]; then
            printf "[X] That version of CentOS isn't supported.\n" && exit 1;
        fi
        
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
    
    local distro="$(get_distro_name)";
    local version="$(get_distro_version)";
    local codename="$(get_distro_codename)";
    
    # Logic
    
    printf "[*] Preparing the system...\n";
    
    if [ "$distro" = "ubuntu" ]; then
        
        # Setup GlobaLeaks Repository
        
        printf "deb https://deb.globaleaks.org $codename/
deb-src http://deb.globaleaks.org $codename/\n" \
            > "/etc/apt/sources.list.d/globaleaks.list";
        
        gpg --import "$J_T2W_SOURCE_DIR/other/gpg/globaleaks.asc" && \
            gpg --export "B353922AE4457748559E777832E6792624045008" | \
                apt-key add -;
        
        printf "APT::Get::AllowUnauthenticated \"true\";
APT::Get::AllowInsecureRepositories \"true\";" > "/etc/apt/apt.conf.d/99tor2web";
        
        # Update System
        
        apt-get update && apt-get upgrade -y;
        
        # Install Prerequisites
        
        apt-get install pwgen -y;
        
        if [ "$codename" = "bionic" ]; then
            
            apt-get install gcc g++ make -y;
            
            wget "https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tar.xz" && \
                tar xf "Python-3.5.1.tar.xz" && cd "Python-3.5.1" && \
                    ./configure && make && make install && cd ..;
            
        fi
       
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
    
    local distro="$(get_distro_name)";
    local codename="$(get_distro_codename)";
    
    # Other Variables
    
    local sum="";
    local node="$(pwgen 10 1)";
    local domain="";
    local ipv4="";
    local ipv6="";
    
    # Logic
    
    if [ "$distro" = "ubuntu" ]; then
        
        # Install Tor2Web
        
        printf "[*] Installing Tor2Web...\n";
        
        apt-get install tor2web -y;
        
        sed -i "s/APPARMOR_SANDBOXING=1/APPARMOR_SANDBOXING=0/" \
            "/etc/default/tor2web";
        
        if [ "$codename" = "bionic" ]; then
            
            apt-get install python-cryptography python-openssl \
                python-twisted-core -y;
            
            wget "https://deb.globaleaks.org/bionic/tor2web_3.1.74_all.deb" && \
                dpkg -i *.deb;
            
        fi
        
        # Generate Tor2Web Certificate
        
        printf "[*] Generating arbitrary SSL certificates...\n";
        
        openssl genrsa -out "/home/tor2web/certs/tor2web-key.pem" 4096;
        
        openssl req -new -key "/home/tor2web/certs/tor2web-key.pem" \
            -out "/home/tor2web/certs/tor2web-csr.pem" \
                -subj "/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=tor.org";
        
        openssl x509 -req -days 365 -in "/home/tor2web/certs/tor2web-csr.pem" \
            -signkey "/home/tor2web/certs/tor2web-key.pem" \
            -out "/home/tor2web/certs/tor2web-cert.pem";
        
        # Domain Setup
        
        printf "[-] Enter your domain: " && read domain;
        
        printf "[*] Determining IPv4 address...\n";
        
        ipv4="$(host "$domain" | grep -m 1 -oP "(([0-9]+).+)+([0-9]+)")";
        
        printf "[*] IPv4 address is '$ipv4'\n";
        
        [ ! -z "$ipv4" ] && sed  -i "s/#listen_ipv4/listen_ipv4/" \
            "/etc/tor2web.conf";
        
        printf "[*] Determining IPv6 address...\n";
        
        ipv6="$(host "$domain" | grep -m 1 -oP "(([A-z0-9]+):+)+([A-z0-9]+)")";
        
        printf "[*] IPv4 address is '$ipv6'\n";
        
        [ ! -z "$ipv6" ] && sed -i "s/#listen_ipv6/listen_ipv6/" \
            "/etc/tor2web.conf";
        
        # Apply Tor2Web Configuration
        
        printf "[*] Applying Tor2Web configuration...\n";
        
        cp "$J_T2W_SOURCE_DIR/other/configs/tor2web.conf" "/etc/tor2web.conf";
        
        sed -i "s/{{ nodename }}/$node/" "/etc/tor2web.conf";
        sed -i "s/{{ domain }}/$domain/" "/etc/tor2web.conf";
        sed -i "s/{{ ipv4 }}/$ipv4/" "/etc/tor2web.conf";
        sed -i "s/{{ ipv6 }}/$ipv6/" "/etc/tor2web.conf";
        
        # Apply Tor Configuration
        
        printf "[*] Applying Tor configuration...\n";
        
        cp "$J_T2W_SOURCE_DIR/other/configs/tor.conf" "/etc/tor/torrc";
        
        # Start Tor2Web
        
        printf "[*] Starting Tor2Web...\n";
        
        systemctl start tor2web && systemctl enable tor2web;
        
    else
        
        printf "[X] Your distribution isn't supported.\n" && exit 1;
        
    fi
    
    return 0;
}

# Cleans system from generated files, etc.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

clean_system()
{
    # Core Variables
    
    local distro="$(get_distro_name)";
    local codename="$(get_distro_codename)";
    
    # Logic
    
    printf "[*] Cleaning files...\n";
    
    get_config_param "setup_status" "finalized";
    
    apt-mark hold python3 tor tor2web;
    
    rm -rfd {includes,other,tor2web.sh};
    
    return 0;
}

# Prints DNS instructions for finalizing the setup.
# 
# @author: Djordje Jocic <office@djordjejocic.com>
# @copyright: 2019 MIT License (MIT)
# @version: 1.0.0
# 
# @return integer
#   It always returns <i>0</i> - SUCCESS.

print_dns_instructs()
{
    # Logic
    
    printf "=====================

Congratulations, you have setup Tor2Web on your machine!

To finalize the configuration, please alter your DNS records.

Records \"@\" and \"*\" should match your IP address.\n";
    
    return 0;
}
