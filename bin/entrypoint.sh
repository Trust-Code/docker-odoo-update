#!/usr/bin/env bash

if [ $UID -eq 0 ]; then

echo "Iniciando o entrypoint com root"

ODOO_USER_ID=$(ls -ld /home/temp/.ssh | awk '{print $3}')
ODOO_GROUP_ID=$(ls -ld /home/temp/.ssh | awk '{print $4}')

# adduser
echo "Changing odoo user Id to be the same from host: $ODOO_USER_ID"
usermod -u $ODOO_USER_ID odoo
groupmod -g $ODOO_GROUP_ID odoo

cp /home/temp/.ssh/id_rsa /opt/.ssh/id_rsa
cp /home/temp/.ssh/id_rsa.pub /opt/.ssh/id_rsa.pub
chmod 400 /opt/.ssh/id_rsa
chmod 400 /opt/.ssh/id_rsa.pub
chown odoo:odoo /opt/.ssh/id_rsa
chown odoo:odoo /opt/.ssh/id_rsa.pub

exec env su odoo "$0" "$@"

fi

export PATH="/opt/odoo:$PATH"
export PATH="/opt/odoo/odoo:$PATH"

echo "Iniciando o entrypoint com odoo"
ssh-keyscan github.com >> ~/.ssh/known_hosts
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

cd /opt/odoo

if [ $ODOO_ENTERPRISE == 1 ] ; then
   git clone --single-branch -v -b $ODOO_VERSION git@github.com:Trust-Code/enterprise.git
fi

if [ $TRUSTCODE_ENTERPRISE == 1 ] ; then
  git clone --single-branch -b $ODOO_VERSION git@bitbucket.org:trustcode/trustcode-enterprise.git
  git clone --single-branch -b $ODOO_VERSION git@bitbucket.org:trustcode/odoo-reports.git
fi

exec "$1"
echo "Finalizou o entrypoint"
