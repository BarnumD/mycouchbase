############################################################
# Dockerfile to build the couchbase server
# Based on Ubuntu
#
# PREREQUISITES
#  Firewall:
#   firewall-cmd --zone=dmz --change-interface=eth0 --permanent
#   firewall-cmd --zone=dmz --add-port=4369/tcp --add-port=8091/tcp --add-port=8092/tcp --add-port=11209/tcp --add-port=11210/tcp --add-port=11211/tcp --add-port=11212/tcp --add-port=13306/tcp --add-port=21100-21199/tcp --permanent
#   firewall-cmd --reload
#
#To Build:
# docker build --pull=true -t my-couchbase .
#
# Docker run example:
#  For Dev:
#   docker run --name my-couchbase --add-host ${HOSTNAME}:127.0.0.1 -e DOCKERHOSTNAME=${HOSTNAME} -e DOCKERHOSTIP=$(ip address list eth0|grep -oP 'inet\s([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)'|awk '{print $2}') -e WWW_TIER=DEV -p 8091:8091 -p 8092:8092 -p 11209:11209 -p 11210:11210 -p 11211:11211 -p 11212:11212 -p 4369:4369 -p 21100-21199:21100-21199 -p 13306:13306 --ulimit nofile=40960:40960 --ulimit core=100000000:100000000 --ulimit memlock=100000000:100000000 my-couchbase &
############################################################
FROM phusion/baseimage:0.9.17
MAINTAINER Dave Barnum <dave@thebarnums.com>
ENV DEBIAN_FRONTEND noninteractive

#Update Ubuntu
RUN apt-get update; \
	apt-get upgrade -y -o Dpkg::Options::="--force-confold"

################## BEGIN INSTALLATION ######################

#---------------------------------------------------------------------
# Start Couchbase Configuration
#---------------------------------------------------------------------

# Install dependencies & Download & install couchbase
RUN apt-get install python wget hostname openssl tar -y; \
	wget http://packages.couchbase.com/releases/3.0.1/couchbase-server-community_3.0.1-ubuntu12.04_amd64.deb -O /tmp/couchbase-server-community_3.0.1-ubuntu12.04_amd64.deb -nv; \
	dpkg -i /tmp/couchbase-server-community_3.0.1-ubuntu12.04_amd64.deb; \
	rm -f /tmp/couchbase-server-community_3.0.1-ubuntu12.04_amd64.deb; \
	apt-get clean all && rm -rf /tmp/* /var/tmp/*;

# Expose ports:
#   - 8091: Web Admin
#   - 8092: API Port
#   - 11209 Internal Bucket Port
#   - 11210 Internal/External Bucket Port
#   - 11211 & 11212 Client Access
#   - 4369 Erlang Port Mapper
#   - 21100 -> 21199 Node data exchange
EXPOSE 8091 8092 11209 11210 11211 11212 4369
EXPOSE 21100-21199

#Configure Couchbase System Scripts
ADD root/bin/service_start_couchbase.sh /root/bin/service_start_couchbase.sh
ADD etc/service/couchbase/run /etc/service/couchbase/run
RUN chmod 750 /root/bin/service_start_couchbase.sh etc/service/couchbase/run
	#mkdir -p /etc/service/couchbase
	#ln -s /root/bin/service_start_couchbase.sh /etc/service/couchbase/run

#Configure Environment Variables
ENV CB_REST_USERNAME couchadm
ENV CB_REST_PASSWORD couchadmpwd


#---------------------------------------------------------------------
# Done Couchbase
#---------------------------------------------------------------------


#Copy other files
#Add root/bin/paping /root/bin/paping
#RUN chmod 750 /root/bin/paping


##################### INSTALLATION END #####################


# Configure the application tier.
# This variable will be used in application startup scripts to configure how the application behaves on different tiers.
# The tier will be set to NONE here, but must be set to DEV, TEST, or PROD when run for those tiers.
ENV WWW_TIER NONE

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
