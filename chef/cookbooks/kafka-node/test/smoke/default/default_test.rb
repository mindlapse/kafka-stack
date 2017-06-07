# # encoding: utf-8

# Inspec test for recipe kafka-node::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/


describe docker.containers do
  its('images') { should include 'wurstmeister/kafka' }
end
