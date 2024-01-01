from debian:12

run apt update
run apt install apt-transport-https lsb-release ca-certificates wget acl curl fping git graphviz imagemagick mariadb-client mariadb-server mtr-tiny nginx-full nmap php8.2-cli php8.2-curl php8.2-fpm php8.2-gd php8.2-gmp php8.2-mbstring php8.2-mysql php8.2-snmp php8.2-xml php8.2-zip python3-dotenv python3-pymysql python3-redis python3-setuptools python3-systemd python3-pip rrdtool snmp snmpd unzip whois -y

run useradd librenms -d /opt/librenms -M -r -s "$(which bash)"

run cd /opt && git clone https://github.com/librenms/librenms.git

run chown -R librenms:librenms /opt/librenms
run chmod 771 /opt/librenms
run setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
run setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/

user librenms
run ./opt/librenms/scripts/composer_wrapper.php install --no-dev
user root

copy fpm.diff /etc/php/8.2/fpm/
run cd /etc/php/8.2/fpm/ && patch -p0 < fpm.diff && rm fpm.diff

copy cli.diff /etc/php/8.2/cli/
run cd /etc/php/8.2/cli/ && patch -p0 < cli.diff && rm cli.diff

run rm /etc/localtime
run ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

copy serverconf.diff /etc/mysql/mariadb.conf.d/
run cd /etc/mysql/mariadb.conf.d/ && patch -p0 < serverconf.diff && rm serverconf.diff

# TODO start mariadb at startup using `system mariadb start` and load the database as desired

run cp /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/librenms.conf
copy wsconf.diff /etc/php/8.2/fpm/pool.d/
run cd /etc/php/8.2/fpm/pool.d/ && patch -p0 < wsconf.diff && rm wsconf.diff && rm www.conf

copy librenms.vhost /etc/nginx/sites-enabled/
run rm /etc/nginx/sites-enabled/default

run ln -s /opt/librenms/lnms /usr/bin/lnms
run cp /opt/librenms/misc/lnms-completion.bash /etc/bash_completion.d/

run cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf

copy snmpd.conf.diff /etc/snmp/
run cd /etc/snmp/ && patch -p0 < snmpd.conf.diff && rm snmpd.conf.diff

run curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
run chmod +x /usr/bin/distro

run cp /opt/librenms/dist/librenms.cron /etc/cron.d/librenms

run cp /opt/librenms/dist/librenms-scheduler.service /opt/librenms/dist/librenms-scheduler.timer /etc/init.d/

run cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms

arg initscript=init_script.sh
arg start_script_dir=/usr/local/bin/
copy $initscript $start_script_dir
run chmod +x $start_script_dir$initscript

expose 8000 514 514/udp 162 162/udp

workdir $start_script_dir
entrypoint init_script.sh
