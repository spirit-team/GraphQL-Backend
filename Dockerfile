FROM centos:7.6.1810 AS builder

WORKDIR /

ENV NPM_CONFIG_LOGLEVEL notice

RUN yum install -y python2 gcc curl openssl ca-certificates wget make gcc-c++ kernel-devel &&\
wget --no-check-certificate https://rpm.nodesource.com/pub_12.x/el/7/x86_64/nodejs-12.9.1-1nodesource.x86_64.rpm &&\
rpm -ivh nodejs-12.9.1-1nodesource.x86_64.rpm &&\
yum install -y nodejs &&\
yum update -y

WORKDIR /build

ADD package*.json ./
RUN npm i
ADD . .
RUN npm run build

########################

FROM centos:7.6.1810
WORKDIR /

RUN yum install -y python2 gcc curl openssl ca-certificates wget make gcc-c++ kernel-devel &&\
wget --no-check-certificate https://rpm.nodesource.com/pub_12.x/el/7/x86_64/nodejs-12.9.1-1nodesource.x86_64.rpm &&\
rpm -ivh nodejs-12.9.1-1nodesource.x86_64.rpm &&\
yum install -y nodejs

WORKDIR /etc/yum.repos.d

RUN wget http://yum.oracle.com/public-yum-ol7.repo &&\
wget http://yum.oracle.com/RPM-GPG-KEY-oracle-ol7 &&\
rpm --import RPM-GPG-KEY-oracle-ol7 &&\
yum install -y yum-utils &&\
yum-config-manager --enable ol7_oracle_instantclient &&\
yum install -y oracle-release-el7 oracle-instantclient18.3-basic &&\
export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib &&\
sh -c "echo /usr/lib/oracle/18.3/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf" &&\
ldconfig &&\
yum update -y

WORKDIR /app
COPY --from=builder /build /app

CMD npm run production

