#/!bin/bash


# Install Go
wget https://go.dev/dl/go1.20.6.linux-amd64.tar.gz

# Command to remove existing Go installation and extract new tarball
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.6.linux-amd64.tar.gz

# Add export statement to $HOME/.profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile

# Add export statement to /etc/profile
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile

# First, install the package
sudo apt install -y golang

# Then add the following to your .bashrc
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Reload your .bashrc
source ~./bashrc

# Check if installation was successful
if [ -x "$(command -v go)" ]; then
  # If successful, display "Installation Successful" in green
  echo -e "\e[32mInstallation Successful\e[0m"

  # Display Go version for 10 seconds
  timeout 10 go version
else
  # If failed, display "Installation Failed" in red
  echo -e "\e[31mInstallation Failed\e[0m"
fi

# Update package lists and install dependencies
echo "Updating package lists and installing dependencies..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y dnsutils coreutils grep sed sed awk procps curl wget tar unzip git

# Install SQLMap
echo "Installing SQLMap..."
cd /opt
sudo wget https://github.com/sqlmapproject/sqlmap/archive/v1.3.12.tar.gz
sudo tar -xzvf v1.3.12.tar.gz
sudo mv sqlmap-1.3.12 sqlmap
sudo rm v1.3.12.tar.gz
sudo ln -s /opt/sqlmap/sqlmap.py /usr/bin/sqlmap
sudo chown -R $USER:$USER /opt/sqlmap

# WebApp Tools installation
cd ~/
mkdir WebApp_Tools
cd ~/WebApp_Tools/

# Clone Arjun and install
git clone https://github.com/s0md3v/Arjun
cd Arjun
python3 setup.py install
if [ $? -eq 0 ]; then
  echo "Arjun installation successful."
else
  echo "Arjun installation failed."
fi
cd ..

# Install uncover
go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest
if [ $? -eq 0 ]; then
  echo "uncover installation successful."
else
  echo "uncover installation failed."
fi

# Install nuclei
cd ~/WebApp_Tools/
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
if [ $? -eq 0 ]; then
  echo "nuclei installation successful."
else
  echo "nuclei installation failed."
fi

# Install httpx
cd ~/WebApp_Tools/
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
if [ $? -eq 0 ]; then
  echo "httpx installation successful."
else
  echo "httpx installation failed."
fi

# Install subfinder
cd ~/WebApp_Tools/
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
if [ $? -eq 0 ]; then
  echo "subfinder installation successful."
else
  echo "subfinder installation failed."
fi

# Install dalfox
cd ~/WebApp_Tools/
go install github.com/hahwul/dalfox/v2@latest
if [ $? -eq 0 ]; then
  echo "dalfox installation successful."
else
  echo "dalfox installation failed."
fi

# Install katana
cd ~/WebApp_Tools/
go install github.com/projectdiscovery/katana/cmd/katana@latest
if [ $? -eq 0 ]; then
  echo "katana installation successful."
else
  echo "katana installation failed."
fi

# Install waybackurls
cd ~/WebApp_Tools/
go install github.com/tomnomnom/waybackurls@latest
if [ $? -eq 0 ]; then
  echo "waybackurls installation successful."
else
  echo "waybackurls installation failed."
fi

# Install gf
cd ~/WebApp_Tools/
go install github.com/tomnomnom/gf@latest
echo 'export PATH=$PATH:/usr/local/go/bin/gf' >> $HOME/.profile
echo 'export PATH=$PATH:/usr/local/go/bin/gf' | sudo tee -a /etc/profile
cd ~
cd mkdir gf
if [ $? -eq 0 ]; then
  echo "gf installation successful."
else
  echo "gf installation failed."
fi

# Clone Gf-Patterns
cd ~/WebApp_Tools/
git clone https://github.com/1ndianl33t/Gf-Patterns
mv ~/WebApp_Tools/Gf-Patterns/*.json ~/gf
mv ~/gf ~/.gf
if [ $? -eq 0 ]; then
  echo "Gf-Patterns installation successful."
else
  echo "Gf-Patterns installation failed."
fi

# Install interactsh-client
cd ~/WebApp_Tools/
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
if [ $? -eq 0 ]; then
  echo "interactsh-client installation successful."
else
  echo "interactsh-client installation failed."
fi

# Clone autossrf and install requirements
cd ~/WebApp_Tools/
git clone https://github.com/Th0h0/autossrf.git
cd autossrf
pip install -r requirements.txt
if [ $? -eq 0 ]; then
  echo "autossrf installation successful."
else
  echo "autossrf installation failed."
fi
cd ..

# Install Amass
sudo apt install amass -y
if [ $? -eq 0 ]; then
  echo "Amass installation successful."
else
  echo "Amass installation failed."
fi
cd ~/WebApp_Tools/

# Install ParamSpider and make it accessible globally
cd ~/WebApp_Tools/ || exit
git clone https://github.com/devanshbatham/ParamSpider
cd ParamSpider || exit
pip3 install -r requirements.txt
if [ $? -eq 0 ]; then
  echo "ParamSpider installation successful."
  echo 'export PATH=$PATH:~/WebApp_Tools/ParamSpider' >> ~/.profile
  echo 'export PATH=$PATH:~/WebApp_Tools/ParamSpider' >> ~/.bashrc
else
  echo "ParamSpider installation failed."
fi
cd ~/WebApp_Tools/ || exit

# Install OpenRedireX
cd ~/WebApp_Tools/ || exit
git clone https://github.com/devanshbatham/OpenRedireX
if [ $? -eq 0 ]; then
  echo "OpenRedireX installation successful."
  echo 'export PATH=$PATH:~/WebApp_Tools/OpenRedireX' >> ~/.profile
  echo 'export PATH=$PATH:~/WebApp_Tools/OpenRedireX' >> ~/.bashrc
else
  echo "OpenRedireX installation failed."
fi
cd ~/WebApp_Tools/ || exit

# Refresh the shell
source ~/.profile
source ~/.bashrc

# Display a message indicating successful completion
echo -e "\n\e[32mWebApp Tools installation completed successfully.\e[0m"
