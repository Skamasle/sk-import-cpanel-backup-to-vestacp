# sk-importer
v-import-cpanel-v2 is a copy of https://github.com/hestiacp/hestiacp/blob/main/bin/v-import-cpanel
Make some changes for testing, then make some pull request in oficial repo

# >>>> v-import-cpanel-v2 <<<<
 Check CHANGELOG
 
 v-import-cpanel-v2 backup.tar.gz
 
 v-import-cpanel-v2 backup.tar.gz ALL
 
 v-import-cpanel-v2 backup.tar.gz DOMAIN
 
 v-import-cpanel-v2 backup.tar.gz MAIL
 
 v-import-cpanel-v2 backup.tar.gz DB

#Import even if the user exists on the server

 v-import-cpanel-v2 backup.tar.gz ALL NO-CHECK-USER
 
#Change destination user ( BETA ) if cpanel account have any user ex: admin and you want restore it in admin2 or any other format is: RESTORE-IN-USER=user )

v-import-cpanel-v2 backup.tar.gz ALL RESTORE-IN-USER=admin2

# >>>> v-import-cwp <<<<

Import backups from Centos Web Panel

CHECK CHANGELOG-CWP

v-import-cwp bacackup.tar.gz

#If you not have databases we cant get user from backup, we need a user

v-import-cwp bacackup.tar.gz NEW_USER



# OLD
Import cPanel backup in vestacp

Beta 0.5.3

- Restore user password
- Restore MX from cpanel dnszone

Beta 0.5

- Improve database restauration.
- Just restore databases and vestacp rebuild users, this add compatibility to mysql 5.7 ( ubuntu 16+ )
- Try restore SSL, something fail if backup not have CA
- Some bugs fixed and some function added to test if have rsync and file installed

Beta 0.4

- Improve database restore, now is compatible whit more cPanel backups, fix some bugs when database dont have Grant ALL Privileges.
- Improve database privileges restauration, now only was restored real database privileges, skip cPanel main user privileges, and a lot of grant all privileges added by cPanel when account was migrated to orther server.
- Adding debug mode.
- Some bugs was fixed.

Beta 0.3.6

- Improve some functions, get real cPanel user.
- Improve data base restore, fix bugs when database not exists
- Fix some bugs
- Dont restore database if is already created.
 
Beta 0.3.5

-  Restore cPanel user.
-  Restore websites, subdomains, domains, main domain
-  Fix main domain restoring, skip public_html dirs if are used by domains or subdomains and this are currently restored
-  Restore mails if cPanel backup use dovecot
-  Restore data bases
-  Add file count to show user some progress when extract backup and restore domain files.

RUN:

bash sk-cpanel-importer-05.sh cpanel-backup.tar.gz

or

bash sk-cpanel-importer-05.sh cpanel-backup.tar.gz MX

Second option will restore your MX, this help people who use google apps, office 365 or remote mail system
