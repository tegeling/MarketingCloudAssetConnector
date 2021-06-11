#!/bin/bash

DURATION=7

if [ "$#" -eq 1 ]; then
  DURATION=$1
fi

sfdx force:org:create -a MCAssetConnector -s -f config/project-scratch-def.json -d $DURATION
sfdx force:source:push
sfdx force:user:permset:assign -n MCAssetConnectorPerm
sfdx force:org:open -p "/lightning/o/Creative_Asset__c/list?filterName=Recent"
echo "Org is set up"