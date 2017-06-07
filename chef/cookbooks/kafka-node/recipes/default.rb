#
# Cookbook:: kafka-node
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

docker_service 'default' do
  action [:create, :start]
end


docker_image 'wurstmeister/kafka' do
  action :pull
end

