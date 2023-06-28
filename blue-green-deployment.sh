#! /bin/bash

# UPGRADE USING BLUE/GREEN TECHNIQUE

# Push Green (1 Instance only) - Use the same manifest but change the name via parameter
# green-hazelcast-app is app name AND route name
cf push green-hazelcast-app -n green-hazelcast-app
sleep 15

# Add network policy from Green -> Green
cf add-network-policy green-hazelcast-app --destination-app green-hazelcast-app -o tony -s test --protocol tcp --port 5701
cf add-network-policy green-hazelcast-app --destination-app green-hazelcast-app -o tony -s test --protocol udp --port 5701

# Add network policy from Blue -> Green
cf add-network-policy hazelcast-app --destination-app green-hazelcast-app -o tony -s test --protocol tcp --port 5701
cf add-network-policy hazelcast-app --destination-app green-hazelcast-app -o tony -s test --protocol udp --port 5701

# Add network policy from Green -> Blue
cf add-network-policy green-hazelcast-app --destination-app hazelcast-app -o tony -s test --protocol tcp --port 5701
cf add-network-policy green-hazelcast-app --destination-app hazelcast-app -o tony -s test --protocol udp --port 5701

# Map Green to internal route
cf map-route green-hazelcast-app apps.internal --hostname hazelcast-app

# Scale Green up
cf scale green-hazelcast-app -i 3
sleep 30
curl "https://green-hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/nodes" --insecure

# Map the Blue route to the Green app
cf map-route green-hazelcast-app apps.h2o-75-10114.h2o.vmware.com --hostname hazelcast-app

# Unmap the Blue route
cf unmap-route hazelcast-app apps.h2o-75-10114.h2o.vmware.com --hostname hazelcast-app

# More Smoke Test
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/size" --insecure
echo ""
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/get?key=232" --insecure
echo ""
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/nodes" --insecure
# ----- End Smoke Test -----




# This is where I was losing data ... still have the nodes, but not the data ... 
# The theory is that when a node is shutdown a new leader is elected, but before
# that leader can be fully initialized, that node is shut down
# Testing with wait between the scaling event to allow hazelcast to fully synch

# Should get the number of instances from cf apps and then loop thru the scaling

# Scale Blue down to zero
cf scale hazelcast-app -i 2
sleep 15
cf scale hazelcast-app -i 1
sleep 15
cf scale hazelcast-app -i 0
sleep 15


# Removing all network policies that have Blue as the destination app
cf remove-network-policy hazelcast-app --destination-app hazelcast-app --protocol tcp --port 5701
cf remove-network-policy hazelcast-app --destination-app hazelcast-app --protocol udp --port 5701
cf remove-network-policy green-hazelcast-app --destination-app hazelcast-app --protocol udp --port 5701
cf remove-network-policy green-hazelcast-app --destination-app hazelcast-app --protocol tcp --port 5701

# Delete the Blue App
cf delete hazelcast-app -f

# Delete the Green route
cf delete-route apps.h2o-75-10114.h2o.vmware.com --hostname green-hazelcast-app -f

# Rename Green to Blue
cf rename green-hazelcast-app hazelcast-app

# Final Smoke Test
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/size" --insecure
