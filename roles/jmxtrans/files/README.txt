WHAT IT IS
----------
jmxtrans makes it easy to extract JMX metrics from a JVM and feed the data to a logging, monitoring or graphing tool.
jmxtrans uses JSON based configuration that can be configured to monitor several JVM's and generate JMX metrics 

HOW TO USE JMXTRANS TO MONITOR A KAFKA CLUSTER
---------------------------------------------
jmxtrans uses OutputWriters to 	present the metrics in whichever format a user chooses. It also allows for plugging in custom writers.
One of the simplest writers is the KeyOutWriter that writes out the data to a tab delimited file.
KeyOutWriter sample output is as shown below
	
	127_0_0_1_9999.kafka.network.Count      0       1396442431355
	127_0_0_1_9999.kafka.network.Max        0.0     1396442431355
	127_0_0_1_9999.kafka.network.Min        0.0     1396442431355
	127_0_0_1_9999.kafka.network.StdDev     0.0     1396442431355
	127_0_0_1_9999.kafka.network.75thPercentile     0.0     1396442431355
	127_0_0_1_9999.kafka.network.95thPercentile     0.0     1396442431355
	127_0_0_1_9999.kafka.network.98thPercentile     0.0     1396442431355
	127_0_0_1_9999.kafka.network.99thPercentile     0.0     1396442431355
	127_0_0_1_9999.kafka.network.999thPercentile    0.0     1396442431355
	127_0_0_1_9999.kafka.network.50thPercentile     0.0     1396442431355
	127_0_0_1_9999.kafka.network.Mean       0.0     1396442431355

The kafka.json file configures jmxtrans to use a KeyOutWriter to write out kafka metrics to a single file.

Setting up jmxtrans to monitor a kafka cluster in 5 easy steps. 
1. Configure kafka to send out metrics via jmx. This is achieved by providing a jmx port to the file that starts the kafka server.
		add to ~/kafka/bin/kafka-server-start.sh
			export JMX_PORT=${JMX_PORT:-9999} 
Kafka is now ready to send out its metrics to our jmxtrans instance
2. Edit kafka.json to point to your kafka brokers 
	Change the lines to point to your servers and their ports adding as many brokers as is nesesarry
				"port": "9999",
				"host": "127.0.0.1",
				"port": "9999",
				"host": "x.x.x.x",
3.  Edit kafka.json log file location
		change the "outputFile": element to a suitable log file
4. Start jmxtrans.
	cd ~/jmxtrans
	./run.sh start <path to json file>
5. To stop jmxtrans
	./run.sh stop

	
HOW TO SETUP
------------
Prerequisites
	1. Git
	2. java-1.7.0-openjdk-devel
For a local build of RPM	
	3. ant    
	4. rpmbuild


KAFKA INSTALLATION
------------------		
1. Use git to download, build and install kafka
		git clone https://github.com/apache/kafka.git
		cd kafka
		git checkout -b 0.8 remotes/origin/0.8
		./sbt update
		./sbt package
		./sbt assembly-package-dependency
		
JMX INSTALLATION
----------------
1a. git clone https://github.com/jmxtrans/jmxtrans.git
	cd jmxtrans
	ant  rpm
or 
1b. download rpm from https://github.com/downloads/jmxtrans/jmxtrans/jmxtrans-20121016.145842.6a28c97fbb-0.noarch.rpm
2. sudo rpm -ivh jmxtrans-20121016.145842.6a28c97fbb-0.noarch.rpm
3. add to ~/kafka/bin/kafka-server-start.sh
		export JMX_PORT=${JMX_PORT:-9999} 
4. Configure jmxtrans
	cd /usr/share/jmxtrans
	vi jmxtrans.sh 
	LOG_DIR=${LOG_DIR:-"/home/vagrant/jmxtrans/logs"}
	JSON_DIR=${JSON_DIR:-"/home/vagrant/jmxtrans/json"}		
5. Add jmxtrans.sh to path
	vi ~/.bash_profile
	PATH=$PATH:/usr/share/jmxtrans
6. Get the basic jmxtrans config files
		add them to ~/jmxtrans/json
		kafka.json
		kafka2.json
		kafkallmetrics.json
7. Configure logging 
	mkdir ~/jmxtrans/logs
	touch ~/jmxtrans/logs/jmxtrans.log

8. To start jmxtrans
	cd /usr/share/jmxtrans
	jmxtrans.sh start ~/jmxtrans/json/kafka.json
10.Simple check
	tailf ~/jmxtrans/logs/jmxtrans.log
