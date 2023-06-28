#! /bin/bash

# ---- VITAL NOTES ---- #
# The manifest will provide the application name
# The application name MUST be set in the hazelcast.yaml under the "member-list"
# When modified the hazelcast.yaml - you MUST rebuild (./gradlew clean build) and push the app
# --------------------- #

# INITIAL INSTALL

# Push with NO instance only - the manifest should have instances: 0 - because the 
# manifest will be used during initial deployment and upgrades
# Initial deployment can start with 1 instance - but deployment MUST have zero
cf push

# Add network policies (tcp/udp) for port 5701 which is used by Hazelcast
cf add-network-policy hazelcast-app --destination-app hazelcast-app -o tony -s test --protocol tcp --port 5701
cf add-network-policy hazelcast-app --destination-app hazelcast-app -o tony -s test --protocol udp --port 5701

# Add internal route for the app
cf map-route hazelcast-app apps.internal --hostname hazelcast-app

# Scale app to SINGLE instance
# One single instance must be started before others to establish the control node
cf scale hazelcast-app -i 1

# ----- Smoke Test -----
# returns: {"value":"0"}
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/size" --insecure

# returns: {"value":"1000 entries inserted to the map... keys are 1 to 1000"}
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/populate" --insecure

# returns: {"value":"1000"}
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/size" --insecure
# ----- End Smoke Test -----

# Scale app to x instances
cf scale hazelcast-app -i 3

# Check for nodes participating in the cluster
curl "https://hazelcast-app.apps.h2o-75-10114.h2o.vmware.com/nodes" --insecure

# The logs will also output the members of the cluster - this will be output in each container

# [APP/PROC/WEB/0] OUT Members {size:3, ver:3} [
# [APP/PROC/WEB/0] OUT 	Member [10.255.192.29]:5701 - caa9b3bc-cff0-46b0-a96c-9145f6b68c8a this
# [APP/PROC/WEB/0] OUT 	Member [10.255.169.239]:5701 - d9cd69e8-0689-4bfc-9116-e66d766e9f72
# [APP/PROC/WEB/0] OUT 	Member [10.255.168.78]:5701 - f93b15ec-9d88-47aa-9889-8a698d759ebc
# [APP/PROC/WEB/0] OUT ]
#
# [APP/PROC/WEB/2] OUT Members {size:3, ver:3} [
# [APP/PROC/WEB/2] OUT 	Member [10.255.192.29]:5701 - caa9b3bc-cff0-46b0-a96c-9145f6b68c8a
# [APP/PROC/WEB/2] OUT 	Member [10.255.169.239]:5701 - d9cd69e8-0689-4bfc-9116-e66d766e9f72 this
# [APP/PROC/WEB/2] OUT 	Member [10.255.168.78]:5701 - f93b15ec-9d88-47aa-9889-8a698d759ebc
# [APP/PROC/WEB/2] OUT ]
#
# [APP/PROC/WEB/1] OUT Members {size:3, ver:3} [
# [APP/PROC/WEB/1] OUT 	Member [10.255.192.29]:5701 - caa9b3bc-cff0-46b0-a96c-9145f6b68c8a
# [APP/PROC/WEB/1] OUT 	Member [10.255.169.239]:5701 - d9cd69e8-0689-4bfc-9116-e66d766e9f72
# [APP/PROC/WEB/1] OUT 	Member [10.255.168.78]:5701 - f93b15ec-9d88-47aa-9889-8a698d759ebc this
# [APP/PROC/WEB/1] OUT ]

# The other way is to issue many curl commands to get data
# The log will show which app instance (APP/PROC/WEB/x) is being used
