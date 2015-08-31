FROM ubuntu:14.04.3
MAINTAINER James Mbabazi "jmbabazi@pih.org"
RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get -yq dist-upgrade
ENV HOSTNAME openmrs
RUN echo openmrs >> /etc/hosts
# Set timezone
RUN apt-get -y install tzdata
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#mysql

ADD MySQL/mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf
#add mysql user not necessary
RUN useradd openmrs -p password -d /home/openmrs -m -g root
RUN echo mysql-server-5.5 mysql-server/root_password password passw0rd | debconf-set-selections
RUN echo mysql-server-5.5 mysql-server/root_password_again password passw0rd | debconf-set-selections
RUN apt-get install -y daemontools \
                        mysql-server \
                        mysql-server-5.5 \
                        mysql-server-core-5.5

#mysql tweaks
RUN sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i "s/3306/3308/" /etc/mysql/my.cnf
ADD scripts/createdb.sh /home/openmrs/createdb.sh
RUN echo default-character-set=utf8 >> /etc/mysql/my.cnf
RUN echo innodb_buffer_pool_size = 100M >> /etc/mysql/my.cnf
#RUN sh /home/openmrs/createdb.sh
#ENTRYPOINT service mysql start && sh /home/openmrs/createdb.sh && bash

# Tomcat and Java
RUN apt-get -y install python-software-properties
RUN apt-get -y install software-properties-common

RUN add-apt-repository ppa:webupd8team/java
RUN apt-get -y update && apt-get -y install vim 
# Accept the license
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 boolean true"
#Solve the error user did not accept the oracle-license-v1-1 license
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | \
  sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | \
   sudo debconf-set-selections
#RUN dpkg-reconfigure debconf
RUN apt-get -y install oracle-java7-installer

# tomcat installation
RUN echo "CATALINA_HOME=/usr/share/tomcat7" >> /etc/default/tomcat7
RUN apt-get -y install tomcat7 tomcat7-user tomcat7-admin
RUN echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/default/tomcat7
#RUN echo "JAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /root/.bashrc
#RUN echo "CATALINA_HOME=/usr/share/tomcat7" >> /etc/default/tomcat7

#useradd -d /tomcat -r -s /bin/false -g 9000 -u 9000 tcuser && \
#tomcat7-instance-create /tomcat && \ 
#ADD root/tomcat root/tomcat
#RUN chown -R tomcat7:tomcat7 root/tomcat

#VOLUME ["root/tomcat/logs", "root/tomcat/temp", "root/tomcat/work"]
# Expose HTTP only by default. EXPOSE 8080 # Workaround for https://bugs.launchpad.net/ubuntu/+source/tomcat7/+bug/1232258 
RUN ln -s /var/lib/tomcat7/common/ /usr/share/tomcat7/common && \
 ln -s /var/lib/tomcat7/server/ /usr/share/tomcat7/server && \
 ln -s /var/lib/tomcat7/shared/ /usr/share/tomcat7/shared
# Use IPv4 by default and UTF-8 encoding. These are almost universally useful. ENV JAVA_OPTS -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8 # All your base... ENV CATALINA_BASE /tomcat # Drop privileges and run Tomcat. USER tcuser CMD /usr/share/tomcat7/bin/catalina.sh run
ENV JAVA_OPTS -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8
# All your base... 
ENV CATALINA_BASE /var/lib/tomcat7
#RUN cp openmrs.war 
# Drop privileges and run Tomcat. 
#USER root
#CMD /usr/share/tomcat7/bin/catalina.sh run
# openmrs.war
RUN apt-get -y install wget
ADD OpenMRS/openmrs.war /home/openmrs/openmrs.war
# Expose the default tomcat port
#EXPOSE 8080
RUN mkdir /root/.OpenMRS
ADD MySQL/DemoDB.sql /home/openmrs/DemoDB.sql
ADD OpenMRS/openmrs-runtime.properties /root/.OpenMRS/openmrs-runtime.properties
RUN chown -R tomcat7:root /usr/share/tomcat7/ && chown -R tomcat7:tomcat7 /var/lib/tomcat7 && chown -R root:root /root/.OpenMRS
#COPY DemoDB.sql /home/openmrs/DemoDB.sql
ADD scripts/entrypoint.sh /home/openmrs/entrypoint.sh
ENTRYPOINT sh /home/openmrs/entrypoint.sh && bash

