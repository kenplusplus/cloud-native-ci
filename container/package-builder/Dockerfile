From centos:8.1.1911

RUN yum -y --setopt="tsflags=nodocs" update
RUN yum -y --setopt="tsflags=nodocs" install epel-release && \
    yum -y --setopt="tsflags=nodocs" install mock rpmdevtools wget
RUN yum clean all && rm -rf /var/cache/yum/


COPY intel-linux-centos.cfg /etc/mock
COPY mock-build.sh /usr/bin/
COPY logging.ini /etc/mock/

RUN echo -e " \n\
config_opts['cache_topdir'] = '/opt/cache/mock' \n\
config_opts['docker_unshare_warning'] = False \n\
config_opts['plugin_conf']['ccache_enable'] = True \n\
config_opts['plugin_conf']['ccache_opts']['max_cache_size'] = '8G' \n\
config_opts['plugin_conf']['ccache_opts']['compress'] = None \n\
config_opts['plugin_conf']['ccache_opts']['dir'] = '/opt/cache/ccache' \n\
config_opts['http_proxy'] = '' \n\
config_opts['https_proxy'] = '' \n\
config_opts['no_proxy'] = '' " >> /etc/mock/site-defaults.cfg

RUN useradd -u 1000 builder && usermod -a -G mock builder

VOLUME [ "/intel-linux/repo" ]
VOLUME [ "/intel-linux/build" ]
VOLUME [ "/opt/cache" ]

RUN chown -R builder:mock /intel-linux
RUN chown -R builder:mock /opt/cache && chmod g+w /opt/cache

ENV PACKAGE=""

USER builder
ENV HOME /home/builder
