#!/bin/bash
# SK-importer
# skamasle.com | @skamasle
# Run at your own risk
# Import cPanel backup Into VestaCP
# beta 0.3.5 debuging yet but working 
# added count files " if big backup stay thinking a lot of time so we show something to user"
# Cron still not working...
# 3 abr 2016
# Ask or report bugs on twitter @skamasle, mail: yo@skamasle.com
# This script dont restore databases if you dont have one user asigned to database
# This script dont work yet if your cPanel has database prefix disabled.
# This script get all your databases and only export "localhost" databases
# so this script dont take "remote cPanel mysql hosts"
# If your cPanel has remote mysql data bases and it connect to orther host you may change "conect_to", but
# I cant warranty that work yet.
# This script dont restore mail password because cPanel use shadown and vestacp use md5, so
# This script will assing new passwor for mail account and show you at the end of restore.

#
# Only for gen_password but I dont like it, a lot of lt
# maybe will use it for orther functions :)
source /usr/local/vesta/func/main.sh 
sk_file=$1
sk_tmp=sk_tmp
sk_file_name=$(ls $sk_file)
tput setaf 2
echo "Checking provided file..."
tput sgr0 
if file $sk_file |grep -q -c "gzip compressed data, from Unix" ; then
	tput setaf 2
	echo "OK - Gziped File"
	tput sgr0 	
	if [ ! -d /root/$sk_tmp ]; then
		echo "Creating tmp.."
		mkdir /root/$sk_tmp
	fi
	echo "Extracting backup..."
	tar xzvf $sk_file -C /root/$sk_tmp 2>&1 |
        while read sk_extracted_file; do
       		 ex=$((ex+1))
       		 echo -en "wait... $ex files extracted\r"
        done

		if [ $? -eq 0 ];then
			tput setaf 2
			echo "Backup extracted whitout errors..."
			tput sgr0 
		else
			echo "Error on backup extraction, check your file, try extract it manually"
			echo "Remove tmp"
			rm -rf /root/$sk_tmp
			exit 1
		fi
	else
	echo "Error 3 not-gzip - no stantard cpanel backup provided"
	rm -rf /root/$sk_tmp
	exit 3
fi
cd /root/$sk_tmp/*
sk_importer_in=$(pwd)
echo "Access tmp directory $sk_importer_in"
echo "Get prefix..."
sk_dead_prefix=$(cat meta/dbprefix)
if [ $sk_dead_prefix = 1 ]; then
	echo "Error 666 - I dont like your prefix, I dont want do this job"
	exit 666
else
	echo "I like your prefix, start working"
fi
echo "Remove and move some files.."
rm mysql/openfileslimit -f
mv mysql/roundcube.sql .

if [ ! -z mysql ];then
	sk_cp_user=$(ls mysql |grep sql | grep -v roundcube.sql |head -n1 |cut -d "_" -f1)
	echo "$sk_cp_user" > sk_db_prefix
	tput setaf 2
	echo "Get user: $sk_cp_user"
	tput sgr0
	sk_restore_dbs=0
	
else
	sk_restore_dbs=1
# get real cPanel user if no databases exist
	sk_cp_user=$(cat homedir_paths | cut -d "/" -f3)
fi
# So get real user, may be we need it before
sk_real_cp_user=$(cat homedir_paths | cut -d "/" -f3)
#main_domain1 needed 100 lines after so dont change it
# put here to create vesta account whit user domain
main_domain1=$(grep main_domain userdata/main |cut -d " " -f2)

if /usr/local/vesta/bin/v-list-users | grep -q -w $sk_cp_user ;then
	echo "User exists on VestaCP but I dont stop restore, in this beta I asume you create user manually"
else
	echo "Generate password aleatory password for $sk_cp_user and create Vestacp Account ..."
	sk_password=$(gen_password)
	/usr/local/vesta/bin/v-add-user $sk_cp_user $sk_password administrator@$main_domain1 default $sk_cp_user $sk_cp_user
fi

#########################
#First file I do it in 3 files 

# Mysql database importer from cPanel to vestacp
# Version beta 0.2  working version
# skamasle.com | @skamasle
# 31 mar 2016
function sk_start_restore_db () {
DATE=$(date +%F)
TIME=$(date +%T)
conect_to=localhost
user_db_tmp=usertmp1
db_tmp=dbtmp1
tput setaf 2
echo "Get databases"
tput sgr0 
grep $conect_to mysql.sql > sk-database
#not modified .sql file for create bds.
cp sk-database sk-database-full.sql
echo "Fix some files"
sed -i -e 's/@/ /' sk-database
sed -i -e 's/\\//' sk-database
sed -i -e "s/'//g" sk-database
sed -i -e "s/\`/ /g" sk-database
sed -i -e "s/;/ /g" sk-database

mkdir $user_db_tmp
mkdir $db_tmp

###
#Get BDS, users, passwords, and users and password again...
sk_databases=$(grep "GRANT ALL" sk-database |cut -d " " -f6)
users_db=$(grep "GRANT USAGE" sk-database |cut -d " " -f6)
# need some fix for detect real main user.. for now working 
# 4 abril - fixed issue dont need it --pending remove --

main_user=$(grep "GRANT USAGE" sk-database |cut -d " " -f6 |head -1)
grep "GRANT USAGE" sk-database > sk_userpasusage
grep "GRANT ALL" sk-database > sk_db_user
echo "Working whit db..."
for user in $users_db
	do
		touch $user_db_tmp/$user
done

for sk_db in $sk_databases
	do
		touch $db_tmp/$sk_db
done
tput setaf 2
echo "Get mysql passwords.."
tput sgr0
function get_user_pass() {
		while read a1 a2 a3 a4 a5 user a7 a8 a9 a10 pass
	do
		echo "$pass" > $user_db_tmp/$user
done

} 
get_user_pass < sk_userpasusage

rm sk_userpasusage -f
# remove main user
rm -f $user_db_tmp/$main_user

# procesamos usuarios y bds..
echo "Start Importing Mysql Databases and Users..."
function get_db_user() {
b=0
		while read a1 a2 a3 a4 db a7 a8 userdb host
do
#if [ "$userdb" != "$main_user" ];then sk_real_cp_user
# Change this for compatibility whit account whit user longestthan 8 characters
if [ "$userdb" != "$sk_real_cp_user" ];then
	if [ -e $user_db_tmp/$userdb ]; then
		end_user_pass=$(cat $user_db_tmp/$userdb)
		echo "DB='$db' DBUSER='$userdb' MD5='$end_user_pass' HOST='localhost' TYPE='mysql' CHARSET='UTF8' U_DISK='0' SUSPENDED='no' TIME='$TIME' DATE='$DATE'" >> /usr/local/vesta/data/users/$sk_cp_user/db.conf
		mysql < mysql/$db.create
		echo "Importing database $db ..."
		mysql $db < mysql/$db.sql
		((b++))
#else
	# echo "Skip......"
	# need some functions here, maybe some one use main db user...
	fi
fi
done
} 
get_db_user < sk_db_user
rm -f sk_db_user
mysql < sk-database-full.sql
tput setaf 4
echo "$b databases imported!"
tput sgr0
# this need more work, if user exists and have databases so, some wc -l and orther things, but 
# for now working.
sed -i "s/U_sk_databases='0'/U_sk_databases='$b'/g" /usr/local/vesta/data/users/$main_user/user.conf

}

if [ $sk_restore_dbs -eq 0 ]; then
	sk_start_restore_db
else
	echo "No databases found for restore"
fi
tput setaf 2
echo "Start working whit web sites / files / domains / subdomains"
tput sgr0
##########
# second file
# file importer
echo "Get main domain: $main_domain1"
skaddons=$(cat addons |cut -d "=" -f1)
sed -i 's/_/./g; s/=/ /g' addons
echo "Converting addons domains, subdomains and some orther fun"
cp sds sk_sds
cp sds2 sk_sds2
sed -i 's/_/./g' sk_sds
sed -i 's/public_html/public@html/g; s/_/./g; s/public@html/public_html/g; s/=/ /g; s/$sk_default_sub/@/g' sk_sds2
cat addons | while read sk_addon_domain sk_addon_sub
do
echo "Converting default subdomain: $sk_addon_sub in domain: $sk_addon_domain"
sed -i -e "s/$sk_addon_sub/$sk_addon_domain/g" sk_sds
sed -i -e "s/$sk_addon_sub/$sk_addon_domain/g" sk_sds2
mv userdata/$sk_addon_sub userdata/$sk_addon_domain
done

tput setaf 2
echo "Start restoring domains"
tput sgr0
function get_domain_path() {
		while read sk_domain path
	do
		if [ -e userdata/$sk_domain ];then
			v-add-domain $sk_cp_user $sk_domain
			echo "Restoring $sk_domain..."
			rm -f /home/$sk_cp_user/web/$sk_domain/public_html/index.html
			rsync -av homedir/$path/ /home/$sk_cp_user/web/$sk_domain/public_html 2>&1 | 
    		while read sk_file_dm; do
       			 sk_sync=$((sk_sync+1))
       			 echo -en "Working: $sk_sync restored files\r"
    		done
			chown $sk_cp_user:$sk_cp_user -R /home/$sk_cp_user/web/$sk_domain/public_html
			echo "$sk_domain" >> exclude_path

		fi
done

} 
get_domain_path < sk_sds2

/usr/local/vesta/bin/v-add-domain $sk_cp_user $main_domain1
# need it for restore main domain
if [ ! -e exclude_path ];then
	touch exclude_path
fi
echo "Restore main domain: $main_domain1"
rm -f /home/$sk_cp_user/web/$main_domain1/public_html/index.html
rsync -av --exclude-from='exclude_path' homedir/public_html/ /home/$sk_cp_user/web/$main_domain1/public_html 2>&1 | 
    		while read sk_file_dm; do
       			 sk_sync=$((sk_sync+1))
       			 echo -en "Working: $sk_sync restored files\r"
    		done
chown $sk_cp_user:$sk_cp_user -R /home/$sk_cp_user/web/$main_domain1/public_html
rm -f sk_sds2 sk_sds

##################
# mail


tput setaf 2
echo "Start Restoring Mails"
tput sgr0
sk_mdir=$sk_importer_in/homedir/mail
cd $sk_mdir
for sk_maild in $(ls -1)
do
if [[ "$sk_maild" != "cur" && "$sk_maild" != "new" && "$sk_maild" != "tmp"  ]]; then
	if [ -d "$sk_maild" ]; then
		for sk_mail_account in $(ls $sk_maild/)
		 do
					
					echo "Create and restore mail account: $sk_mail_account@$sk_maild"
					sk_mail_pass1=$(gen_password)		
					v-add-mail-account $sk_cp_user $sk_maild $sk_mail_account $sk_mail_pass1
					mv $sk_maild/$sk_mail_account /home/$sk_cp_user/mail/$sk_maild
					chown $sk_cp_user:mail -R /home/$sk_cp_user/mail/$sk_maild
					echo "$sk_mail_account@$sk_maild | $sk_mail_pass1"	>> /root/sk_mail_password_$DATE-$TIME 
		done
	fi
#else
# this only detect default dirs account new, cur, tmp etc
# maybe can do something whit this, but on most cpanel default account have only spam.
fi
done
echo "All mail accounts restored"
#############

############
# Restore Cron
#
# need some extrafunctions.
sk_run_cron_restore() {
cr=0
grep -v "SHELL=" $sk_importer_in/cron/$sk_real_cp_user |grep -v "mailto" > $sk_importer_in/cron/sk_cron_p
mkdir sk-emptydir
cd sk-emptydir
function sk_restore_cron() {
while IFS= read -r line; do
    v-add-cron-job $sk_cp_user $line
	((cr++))
done 
}
sk_restore_cron < "$sk_importer_in/cron/sk_cron_p"
echo "$cr cron restored"
}
if [ -e $sk_importer_in/cron/$sk_real_cp_user ]; then
	tput setaf 2
	echo "Restore Crons for $sk_cp_user"
	tput sgr0
	# restore working, need some function to fix cron when have php comandas like php -q /absolutepath
	# so disabled for now,  vesta cant add cron from cli if cron has  * - bug ?
	# sk_run_cron_restore
else
	echo " No cron jobs found  for user $sk_cp_user"
fi
cd ..

echo "Remove tmp files"
rm -rf /root/$sk_tmp
echo "##############################"
echo "cPanel Backup restored"
echo "Review your content and report any fail"
echo "I reset mail password, cant restore yet shadow passwords to vesta format ( md5 )"
echo "Check your new passwords runing: cat /root/sk_mail_password_$DATE-$TIME"
echo "##############################"
