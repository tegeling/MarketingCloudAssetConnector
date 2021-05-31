global with sharing class MCCreateNewAssetCallout {
    @InvocableMethod(label='Create New Asset' description='Uploads the referenced file as a new asset to MarketingCloud.' category= 'Marketing Cloud Assets' callout=true)

    global static List<MCCreateNewAssetResult> createNewAssetCallout(List<MCCreateNewAssetRequest> requests) {
        List<MCCreateNewAssetResult> results = new List<MCCreateNewAssetResult>();
        for (MCCreateNewAssetRequest request : requests) {
          results.add(doCallout(request));
        }
        return results;
    }

    private static MCCreateNewAssetResult doCallout(MCCreateNewAssetRequest request) {
        // call Rest API
        MCCreateNewAssetResult result = new MCCreateNewAssetResult();
        return result;
    }

    global class MCCreateNewAssetRequest {
        @InvocableVariable(required=true label='File ID' description='Identifier of the new file')
        global ID fileId;
     
        @InvocableVariable(required=true label='Record ID' description='Related Salesforrce record')
        global ID recordId;
      }
     
      global class MCCreateNewAssetResult {
        @InvocableVariable(label='Object ID' description='Unique MarketingCloud Identifier')
        global String objectID;
     
        @InvocableVariable(label='Published URL' description='Asset is available at this URL')
        global String publishedURL;
      }
     
      class MCCreateNewAssetException extends Exception {}
}
