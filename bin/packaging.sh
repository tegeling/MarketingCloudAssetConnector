sfdx force:package:create --name "MC Asset Connector" --description "Integrate Salesforce Core with Salesforce Marketing Cloud to upload media assets to Content Builder" --packagetype Unlocked --path force-app --nonamespace --targetdevhubusername mc-dev

sfdx force:package:version:create --package "MC Asset Connector" --path force-app --installationkeybypass --wait 20 --codecoverage --targetdevhubusername mc-dev

sfdx force:package:version:promote --package "MC Asset Connector@2.0.0-1" --targetdevhubusername mc-dev

https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5I000001mslhQAA
https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5I000001mslhQAA

