# sk-importer
v-import-cpanel-v2 is a copy of https://github.com/hestiacp/hestiacp/blob/main/bin/v-import-cpanel
Make some changes for testing, then make some pull request in oficial repo

v-import-cpanel-v2
- Add progress when restoring mails
- Add progress when unzip archive, good to know if script do something
- Fix EA-PHP paths in cron job / replace by hestiacp paths or default if not exists
- Fix Bug when restore addon domains
- Fix Bug when restore databases
- Added option to change cpanel user ( beta script also try fix PHP configuration files, database prefix, script search for most common configuration files settings.php. wp-config.php and fix DB_PREFIX_)
- Added options to restore if user alredy exist ( beta we try not overwrite existing data need more test )
- Added Option to restore only databases, Only emails or Only domains
- Now we can restore parked domains and parked domain mails.
- Improve output, change all ECHOs for printf
- Change VARS to UPERCASE ( 95% completed )
- Added option to restore SSL ( need more tests )
- Fix Bug, continue restoring either if php version not exists, just asign default.
- Added now quota for mail account asigned as in cpanel account
- By default disabled option to search and unzip compressed mails , in script change FIND_GZIPED_MAILS=no to yes to activate search for compressed mails, this function is too slowin big emails accounts
TODO:
- Check if mails are in maildir format or mdbox
- Restore DKIM really need restore it ? if local mail we can generate new one.
- Need check MX restore optión again.


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
