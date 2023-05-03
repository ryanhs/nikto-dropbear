#!/bin/sh

# automagically add new authorization_keys based on environment variable, easier to integrate with docker-compose
if [ -n "$SSH_PUB_KEY" ]; then
  echo "env SSH_PUB_KEY exists!, use for authorization_keys";
  mkdir -p /home/${SSH_USERNAME}/.ssh
  echo "$SSH_PUB_KEY" > /home/${SSH_USERNAME}/.ssh/authorized_keys
fi;

/usr/sbin/dropbear -RFEmwsgjk -K 3600 -I 3600 -G ${SSH_USERNAME} -p 22