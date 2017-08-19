#!/bin/bash
# ---------------------------------------------------------------------------
# Author: John Hammond
# Date: August 19th, 2017

# Description: This is the  setup script for the USCGA Cyber Team Portal.
# It should install dependencies, configure the site, and show the user
# how to deploy.
# ---------------------------------------------------------------------------


DEPENDENCIES="python python-pip git vagrant docker python-markdown \
python-software-properties nodejs linuxbrew-wrapper nginx python-flask \
gunicorn python-passlib"


# Ensure you are root!
if [ $UID -ne 0 ]
then
	echo "You must run this script as root!"
	exit
fi

function install_dependencies(){

	# Get nodejs 
	curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - 
	# Install dependencies...
	apt-get update && sudo apt install -y $DEPENDENCIES

	# Get flask login...
	pip install flask_login

	# Let brew configure itself
	echo "" | brew

	# Brew will only install things if it is owned by root, so...
	# Kinda silly, but we've gotta do it.

	# Have brew install gotty
	su `logname` -c "brew install yudai/gotty/gotty"
	export PATH=$PATH:$HOME/.linuxbrew/bin/
	echo "export PATH=$PATH:$HOME/.linuxbrew/bin/" >> ~/.bashrc
	
}


function configure_nginx(){

	
	sudo rm -f /etc/nginx/sites-enabled/default
	sudo touch /etc/nginx/sites-available/flask-settings
	sudo ln -f -s /etc/nginx/sites-available/flask-settings \
			   /etc/nginx/sites-enabled/flask-settings

	cat <<EOF > /etc/nginx/sites-enabled/flask_settings
server {
		location / {
				proxy_pass http://127.0.0.1:8000;
		}
}
EOF

	sudo service nginx restart
}


function prepare_gunicorn(){

	gunicorn server:app
}

install_dependencies
configure_nginx