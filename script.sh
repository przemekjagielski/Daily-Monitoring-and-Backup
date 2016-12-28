#!/bin/bash
##############################
#Monitoring and backup system#
##############################

#########
#Zmienne#
#########

wiadomosc=/tmp/email-$(date +%d:%m:%Y).txt
hostname=s1.filehosting24.com

########################################################
#Sprawdzanie i ewentualnie tworzenie szablou wiadomosci#
########################################################

if [ -e email/template.txt ]
then
	cp email/template.txt $wiadomosc
else
	touch email/template.txt
	echo 'From: postmaster@jagielski.ovh
To: postmaster@jagielski.ovh
Subject: Daily Report' >> email/template.txt
	cp email/template.txt $wiadomosc
fi
######################
#Aktualizacja systemu#
######################
echo "Hostname:"$hostname"" >> $wiadomosc

echo "######################" >> $wiadomosc
echo "#Aktualizacje systemu#" >> $wiadomosc
echo "######################" >> $wiadomosc

	apt-get update
	apt-get upgrade -y >> $wiadomosc
	apt-get autoclean >> $wiadomosc

if [ grep -q "apt-get autoremove" $wiadomosc ]
then
	apt-get autoremove -y >> $wiadomosc
else
	echo "Brak pakietow nieuzywanych" >> $wiadomosc
fi

##################
#Kontrola dyskowa#
##################

echo "####################" >> $wiadomosc
echo "#RAID & Disk status#" >> $wiadomosc
echo "####################" >> $wiadomosc

echo 'Filesystem                                                           Size  Used Avail Use% Mounted on' >> $wiadomosc
df -h | grep /dev/md2 >> $wiadomosc
df -h | grep /dev/md3 >> $wiadomosc

mdadm --detail /dev/md[023] >> $wiadomosc

########
#Bakcup#
########

echo "##################" >> $wiadomosc
echo "#Backup websystem#" >> $wiadomosc
echo "##################" >> $wiadomosc

zip -r backup-$(date +%d:%m:%Y).zip /home/www/filehosting24.com -x /home/www/filehosting24.com/files\* /home/www/filehosting24.com/plugins/mediaconverter/converter/_cache\*
mv backup-$(date +%d:%m:%Y).zip /backup >> /tmp/test.txt
if [ -e /backup/backup-$(date +%d:%m:%Y).zip ]
then
	ls -la /backup >> $wiadomosc
else
	cat /tmp/test.txt >> $wiadomosc
fi

#Wyslanie wiadomosci
ssmtp postmaster@jagielski.ovh < $wiadomosc
rm $wiadomosc
