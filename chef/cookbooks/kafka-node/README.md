# kafka-node

TODO: Enter the cookbook description here.

## Bootstrapping a node
knife bootstrap ubuntu@n0 --sudo --node-name kafka-node-0 -i ~/.ssh/aws/toronto-ai.pem -r "kafka-node::default" -j "{\"broker_id\":\"1\"}" -y
knife bootstrap ubuntu@n1 --sudo --node-name kafka-node-1 -i ~/.ssh/aws/toronto-ai.pem -r "kafka-node::default" -j "{\"broker_id\":\"2\"}" -y
knife bootstrap ubuntu@n2 --sudo --node-name kafka-node-2 -i ~/.ssh/aws/toronto-ai.pem -r "kafka-node::default" -j "{\"broker_id\":\"3\"}" -y

## Upload a new cookbook version
knife cookbook upload kafka-node

## Reconverge each node
knife ssh 'name:*' 'sudo chef-client'
knife ssh -i ~/.ssh/aws/toronto-ai.pem -x ubuntu 'name:*' 'sudo chef-client'
knife ssh -i ~/.ssh/aws/toronto-ai.pem --no-host-key-verify -x ubuntu 'name:kafka-node-0' 'echo {\"broker_id\":\"1\"} | sudo chef-client -j /dev/stdin'
knife ssh -i ~/.ssh/aws/toronto-ai.pem --no-host-key-verify  -x ubuntu 'name:kafka-node-1' 'echo {\"broker_id\":\"2\"} | sudo chef-client -j /dev/stdin'
knife ssh -i ~/.ssh/aws/toronto-ai.pem --no-host-key-verify  -x ubuntu 'name:kafka-node-2' 'echo {\"broker_id\":\"3\"} | sudo chef-client -j /dev/stdin'
