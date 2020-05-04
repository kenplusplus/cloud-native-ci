From centos:8.1.1911

RUN echo -e "\n\
[epel] \n\
name=Extra Packages for Enterprise Linux $releasever - $basearch \n\
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/8/Everything/x86_64 \n\
        https://download.fedoraproject.org/pub/epel/8/Everything/x86_64 \n\
        https://linux-ftp.sh.intel.com/pub/mirrors/fedora-epel/8/Everything/x86_64/ \n\
enabled=1 \n\
gpgcheck=1 \n\
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/epel/RPM-GPG-KEY-EPEL-8 \n\
" >> /etc/yum.repos.d/epel.repo

RUN yum -y --setopt="tsflags=nodocs" update
RUN yum -y --setopt="tsflags=nodocs" install mock rpmdevtools wget
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
config_opts['http_proxy'] = '$http_proxy' \n\
config_opts['https_proxy'] = '$https_proxy' \n\
config_opts['no_proxy'] = '$no_proxy' " >> /etc/mock/site-defaults.cfg

RUN useradd -u 1000 builder && usermod -a -G mock builder

VOLUME [ "/intel-linux/repo" ]
VOLUME [ "/intel-linux/build" ]
VOLUME [ "/opt/cache" ]

RUN chown -R builder:mock /intel-linux
RUN chown -R builder:mock /opt/cache && chmod g+w /opt/cache

ENV PACKAGE=""

USER builder
ENV HOME /home/builder
