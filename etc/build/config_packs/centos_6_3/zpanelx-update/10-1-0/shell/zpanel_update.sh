chmod -R 744 /var/spool/cron/

##PASSWORD GEN##
genpasswd() {
    	 l=$1
           [ "$l" == "" ] && l=16
          tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}

## Determine if we need to update the postfix user
result=`mysql -u postfix -ppostfx --skip-column-names -e "SHOW DATABASES LIKE 'zpanel_postfix'"`

if [ "$result" == "zpanel_postfix" ]; then
	password=`genpasswd`;
	mysqladmin -u postfix password "$password"
	sed -i "s|password = postfix|myhostname = $password|" /etc/zpanel/configs/postfix/mysql-relay_domains_maps.cf
	sed -i "s|password = postfix|myhostname = $password|" /etc/zpanel/configs/postfix/mysql-virtual_alias_maps.cf
	sed -i "s|password = postfix|myhostname = $password|" /etc/zpanel/configs/postfix/mysql-virtual_domains_maps.cf
	sed -i "s|password = postfix|myhostname = $password|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_limit_maps.cf
	sed -i "s|password = postfix|myhostname = $password|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_maps.cf
	sed -i "s|\$db_password \= \'postfix\'\;|\$db_password \= \'$password\'\;|" /etc/zpanel/configs/postfix/vacation.conf
	sed -i "s|connect = host=localhost dbname=zpanel_postfix user=postfix password=postfix|connect = host=localhost dbname=zpanel_postfix user=postfix password=$password" /etc/zpanel/configs/dovecot/dovecot-dict-quota.conf
	sed -i "s|connect = host=localhost dbname=zpanel_postfix user=postfix password=postfix|connect = host=localhost dbname=zpanel_postfix user=postfix password=$password" /etc/zpanel/configs/dovecot/dovecot-mysql.conf
	echo -e "Your new MySQL 'postfix' is : $password";
fi


