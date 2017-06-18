# kafka-node

TODO: Enter the cookbook description here.

## Bootstrapping a node
knife bootstrap ubuntu@broker_zero --sudo --node-name kafka-node-0 -i ~/.ssh/aws/toronto-ai.pem -r "kafka-node::default"

## Upload a new cookbook version
knife cookbook upload kafka-node

## Reconverge each node
knife ssh 'name:*' 'sudo chef-client'
knife ssh -i ~/.ssh/aws/toronto-ai.pem -x ubuntu 'name:*' 'sudo chef-client'
knife ssh -i ~/.ssh/aws/toronto-ai.pem -x ubuntu 'name:*' 'echo {\"broker_id\":\"0\"} | sudo chef-cl
ient -j /dev/stdin'

Configuration:
KAFKA_BROKER_ID
KAFKA_CREATE_TOPICS pair_usdcad
