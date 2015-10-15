#!/bin/bash

# fast 
#tar --remove-files -czf  /mnt/sdb1/archives/38nevest.web.local.tar.gz 38nevest.web.local

function backup_host {

	DATABASE=`echo $1 | cut -f1 -d "."`

	echo "Arhiving web host $1"
	echo -n "Looking for database $DATABASE: "

	# Looking for database
	if  database_exists $DATABASE ;
	then
		echo "OK"
	else
		echo "FAILED"
		read -p "Type database name for dump $1: " DATABASE 
	fi

	if [ "$DATABASE" != "" ]
	then
		# Dumping database
		echo "Dumping database $DATABASE"

		mysqldump $DATABASE > "$1/$1.sql"
		EXITSTATUS=$?

		if [ "$EXITSTATUS" -ne "0" ]
		then 
			echo "MySQL database dumping error: $EXITSTATUS" 
			read -p "Continue without backup MySQL Database (y/N): " REPLY

			if [ "$REPLY" != "y" ]
			then
				exit
			else
				echo " * Skiping dumping database"
			fi

		else
			echo "Droping database $DATABASE"
			mysqladmin drop $DATABASE -f
		fi
	fi

	if [ -f "/etc/apache2/sites-available/$1.conf" ]
	then
		echo "Disabling virtualhost: $1" 

		a2dissite "$1.conf"

		mv "/etc/apache2/sites-available/$1.conf" "/var/www/$1"

		if [ -f "/etc/apache2/sites-enabled/$1.conf" ]
		then

			rm "/etc/apache2/sites-enabled/$1.conf"
		fi

		service apache2 reload
	fi

	echo "Arhiving..."
	tar --remove-files -czf "/mnt/sdb1/archives/$1.tar.gz" "$1"
	EXITSTATUS=$?
	if [ "$EXITSTATUS" -eq "0" -a -d "/var/www/$1" ]
	then
		echo "Removing /var/www/$1"
		rm /var/www/$1
	fi

	echo "$1 arhived";
}

function database_exists {

	RESULT=`mysqlshow $1 2>/dev/null | grep -v Wildcard | grep -o $1`
	if [ "$RESULT" == "$1" ]; then
	    return 0;
	fi

	return 1;
}


cd "/var/www/";

for dir in *.web.local/ ; do
	HOST=`echo $dir | cut -f1 -d "/"`

	read -p "Arhive $HOST (y/N): " REPLY

	if [ "$REPLY" = "y" ]
	then
		backup_host $HOST
	fi
done

# 



