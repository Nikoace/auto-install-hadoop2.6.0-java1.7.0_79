#!/bin/bash
sed -i 's/HOSTNAME=.*$/HOSTNAME=h1m1/g' /etc/sysconfig/network
sed -i 's/BOOTPROTO=.$*/BOOTPROTO="manual"'
echo "IPADDR=192.168.100.10">>/etc/sysconfig/network-scripts/ifcfg-eth0

echo "GATEWAY=192.168.100.254">>/etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK=255.255.255.0">>/etc/sysconfig/network-scripts/ifcfg-eth0
echo "192.168.100.100 h1m1">>/etc/hosts

service iptables status
service iptables stop
chkconfig iptables --list
chkconfig iptables off

mkdir /usr/lib/jdk
tar -zxvf jdk-7u79-linux-x64.tar.gz
mv jdk1.7.0_79 /usr/lib/jdk
echo "export JAVA_HOME=/usr/lib/jdk/jdk1.7.0_79">>/etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin">>/etc/profile
source /etc/profile
mkdir /usr/lib/hadoop
tar -zxvf hadoop-2.6.0.tar.gz
mv hadoop-2.6.0 /usr/lib/hadoop
cd /usr/lib/hadoop/hadoop-2.6.0
sed -i 's%${JAVA_HOME}%/usr/lib/jdk/jdk1.7.0_79/%g' etc/hadoop/hadoop-env.sh
sed -i 's%<configuration>.*$%<configuration> <property> <name>fs.defaultFS</name> <value>hdfs://h1m1:9000</value> </property><property> <name>hadoop.tmp.dir</name> <value>/usr/lib/hadoop/tmp</value> </property> <property> <name>io.file.buffer.size</name> <value>4096</value> </property>%g' etc/hadoop/core-site.xml
sed -i "s%<configuration>.*$%<configuration> <property> <name>dfs.replication</name> <value>2</value> </property> <property> <name>dfs.namenode.name.dir</name> <value>file:///usr/lib/hadoop/dfs/name</value> </property> <property> <name>dfs.datanode.data.dir</name> <value>file:///usr/lib/hadoop/dfs/data</value> </property> <property> <name>dfs.nameservices</name> <value>h1</value> </property> <property> <name>dfs.namenode.secondary.http-address</name> <value>h1m1:50090</value> </property> <property> <name>dfs.webhdfs.enabled</name> <value>true</value> </property> %g" etc/hadoop/hdfs-site.xml 
cd etc/hadoop
cp mapred-site.xml.template mapred-site.xml 
sed -i "s%<configuration>.*$%<configuration> <property> <name>mapreduce.framework.name</name> <value>yarn</value> <final>true</final> </property> <property> <name>mapreduce.jobtracker.http.address</name> <value>h1m1:50030</value> </property> <property> <name>mapreduce.jobhistory.address</name> <value>h1m1:10020</value> </property> <property> <name>mapreduce.jobhistory.webapp.address</name> <value>h1m1:19888</value> </property> <property> <name>mapred.job.tracker</name> <value>http://h1m1:9001</value> </property>%g" mapred-site.xml
sed -i "s%<configuration>.*$%<configuration> <!-- Site specific YARN configuration properties --> <property> <name>yarn.resourcemanager.hostname</name> <value>h1m1</value> </property> <property> <name>yarn.nodemanager.aux-services</name> <value>mapreduce_shuffle</value> </property> <property> <name>yarn.resourcemanager.address</name> <value>h1m1:8032</value> </property> <property> <name>yarn.resourcemanager.scheduler.address</name> <value>h1m1:8030</value> </property> <property> <name>yarn.resourcemanager.resource-tracker.address</name> <value>h1m1:8031</value> </property> <property> <name>yarn.resourcemanager.admin.address</name> <value>h1m1:8033</value> </property> <property> <name>yarn.resourcemanager.webapp.address</name> <value>h1m1:8088</value> </property>  %g" yarn-site.xml

cd ../../
echo "export HADOOP_HOME=/usr/lib/hadoop/hadoop-2.6.0">>/etc/profile
echo "export PATH=\$PATH:\$HADOOP_HOME/bin">>/etc/profile
source /etc/profile
java -version

cd ~/.ssh
ssh-keygen -t rsa 
cat id_rsa.pub >> authorized_keys
chmod 600 ./authorized_keys 

hdfs namenode -format 
/usr/lib/hadoop/hadoop-2.6.0/sbin/start-dfs.sh 
/usr/lib/hadoop/hadoop-2.6.0/sbin/start-yarn.sh 

jps
