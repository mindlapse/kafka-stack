#
# Cookbook:: kafka-node
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

kafka_version = '0.10.2.1'
zookeeper_version = '3.4'

ips = node["zk_ips"]
puts '-------------------------' + ips.to_s
for i in 0..ips.length-1
  hostsfile_entry ips[i] do
    hostname "zk" + (i+1).to_s
    unique true
    comment 'Zookeeper host'
    action :create
  end
end

docker_service 'default' do
  action [:create, :start]
end

# Pull the images

docker_image 'wurstmeister/kafka' do
  action :pull
  tag kafka_version
end

docker_image 'zookeeper' do
  action :pull
  tag zookeeper_version
end

# Launch the containers


docker_container 'zookeeper' do
  servers = "ZOO_SERVERS="

  for i in 1..ips.length
    ip = i == Integer(node['broker_id']) ? "0.0.0.0" : ips[i-1]
    servers << "server." + i.to_s + "=" + ip + ":2888:3888 "
  end

  repo 'zookeeper'
  port ['2181:2181', '2888:2888', '3888:3888']
  network_mode "host"
  restart_policy 'unless-stopped'
  tag zookeeper_version
  env [
    "ZOO_MY_ID=" + Integer(node['broker_id']).to_s,
    servers
  ]
end


docker_container 'kafka' do
  repo 'wurstmeister/kafka'
  tag kafka_version
  port '9092:9092'
  network_mode "host"
  restart_policy 'on-failure'
  restart_maximum_retry_count 2
  autoremove false
  # TODO configure the volume
  action :run
  env [
    'KAFKA_HEAP_OPTS=-Xmx384m -Xms384m',
    'KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://' + node['hostname'] + ':9092',
    'KAFKA_ZOOKEEPER_CONNECT=' + node['hostname'] + ':2181',
    'KAFKA_BROKER_ID=' + node['broker_id']
  ]
end
