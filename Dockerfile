FROM alpine:3.17 as niktoBase

ENV NIKTO_VERSION=2.1.6

#id to be created
ENV SSH_USERID=1000 
ENV SSH_GROUPID=1000 
ENV SSH_USERNAME=nikto 

# add packages
RUN apk add --update --no-cache \
  tini git curl ca-certificates \
  perl perl-net-ssleay \
  dropbear dropbear-dbclient dropbear-scp \
  jq

# configure dropbear
RUN mkdir /etc/dropbear

# setup new user
RUN addgroup -g ${SSH_USERID} ${SSH_USERNAME} \
  && adduser -u ${SSH_GROUPID} -G ${SSH_USERNAME} -s /bin/sh -D ${SSH_USERNAME} 

# setup profile system-wide, no-history, [TODO!]
# RUN echo 'unset HISTFILE' >> /etc/profile.d/disable.history.sh


# add nikto
RUN git clone --depth 1 --branch "nikto-${NIKTO_VERSION}" https://github.com/sullo/nikto.git /home/${SSH_USERNAME}/src-nikto \
  && chown -R ${SSH_USERNAME}:${SSH_USERNAME} /home/${SSH_USERNAME}/src-nikto \
  && chmod +x /home/${SSH_USERNAME}/src-nikto/program/nikto.pl \
  && ln -s /home/${SSH_USERNAME}/src-nikto/program/nikto.pl /usr/bin/nikto

# add nikto-scan.sh
COPY --chown=${SSH_USERNAME}:${SSH_USERNAME} ./nikto-scan.sh /home/${SSH_USERNAME}/nikto-scan.sh
COPY --chown=${SSH_USERNAME}:${SSH_USERNAME} ./nikto-scan-json.sh /home/${SSH_USERNAME}/nikto-scan-json.sh
RUN chmod +x /home/${SSH_USERNAME}/*

# setup boot
EXPOSE 22
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/run.sh"]