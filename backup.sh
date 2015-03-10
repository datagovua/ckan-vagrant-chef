#/bin/bash


# scp etc
# scp /var
# scp /usr

# make backup
# FileStore
# TODO

# pg
/usr/lib/ckan/default/bin/paster --plugin=ckan db dump /var/backups/ckan_`date +%Y%m%d%H`.pg_dump --config=/etc/ckan/default/production.ini

# restore backup
/usr/lib/ckan/default/bin/paster --plugin=ckan db clean --config=/etc/ckan/default/production.ini
/usr/lib/ckan/default/bin/paster --plugin=ckan db load /var/backups/ckan_`date +%Y%m%d%H`.pg_dump --config=/etc/ckan/default/production.ini
/usr/lib/ckan/default/bin/paster --plugin=ckan db upgrade --config=/etc/ckan/default/production.ini

# after restore
/usr/lib/ckan/default/bin/paster --plugin=ckan search-index rebuild -r --config=/etc/ckan/default/production.ini
