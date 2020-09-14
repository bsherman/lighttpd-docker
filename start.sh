#!/bin/sh

if [ -n "$VHOST_DOMAIN" ]; then
  if [ -f /etc/lighttpd/.no-user-volume ]; then
    # if this file exists, user did not mount a config volume
    # so it's safe to modify the container's config
    cd /etc/lighttpd
    if [ ! -f lighttpd.conf.orig ]; then
      echo "created backup of original config for re-use in case of restart"
      cp -a lighttpd.conf lighttpd.conf.orig
    fi
    echo "configuring simple vhost for domain: $VHOST_DOMAIN"
    sed 's/#    "mod_simple_vhost/    "mod_simple_vhost/' lighttpd.conf.orig > lighttpd.conf
    echo simple-vhost.server-root = \"/var/www/localhost/\" >> lighttpd.conf
    echo simple-vhost.default-host = \"$VHOST_DOMAIN\" >> lighttpd.conf
    echo simple-vhost.document-root = \".\" >> lighttpd.conf
  fi

  if [ -d "/var/www/localhost/$VHOST_DOMAIN" ]; then
    echo "simple vhost directory already configured"
  else
    echo "created default index.html for http://$VHOST_DOMAIN"
    mkdir -p /var/www/localhost/$VHOST_DOMAIN
    echo "It Works!" > /var/www/localhost/$VHOST_DOMAIN/index.html
  fi
fi


chmod a+w /dev/pts/0
exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
