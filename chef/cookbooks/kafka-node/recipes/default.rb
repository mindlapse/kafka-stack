#
# Cookbook:: kafka-node
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

kafka_version = '0.10.2.1'
zookeeper_version = '3.4'

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
  repo 'zookeeper'
  port '2181:2181'
  tag zookeeper_version
end


docker_container 'kafka' do
  repo 'wurstmeister/kafka'
  tag kafka_version
  port '9092:9092'
  restart_policy 'on-failure'
  restart_maximum_retry_count 2
  autoremove false
  action :run
  env [
    'KAFKA_HEAP_OPTS=-Xmx384m -Xms384m',
    'KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://' + node['hostname'] + ':9092',
    'KAFKA_ZOOKEEPER_CONNECT=' + node['hostname'] + ':2181',
    'KAFKA_BROKER_ID=' + node['broker_id']
  ]
end
