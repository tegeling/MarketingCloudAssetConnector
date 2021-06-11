sfdx force:package:create --name "MC Asset Connector" --description "Integrate Salesforce Core with Salesforce Marketing Cloud to upload media assets to Content Builder" --packagetype Unlocked --path force-app --nonamespace --targetdevhubusername devhub

sfdx force:package:version:create --package "MC Asset Connector" --path force-app --installationkeybypass --wait 20 --codecoverage --targetdevhubusername devhub

sfdx force:package:version:promote --package "MC Asset Connector@0.1.0-1" --targetdevhubusername devhub

https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5I000001eewrQAA
https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5I000001eewrQAA

