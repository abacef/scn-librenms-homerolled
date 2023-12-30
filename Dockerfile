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

# TODO set system timezone to west coast time

