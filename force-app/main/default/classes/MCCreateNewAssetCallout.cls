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

      // get connection settings
      MCConnectionSetting__mdt settings = [
        SELECT client_id__c, client_secret__c, account_id__c, subdomain__c
        FROM MCConnectionSetting__mdt
        WHERE DeveloperName = :request.connection
      ];

      Map<String,String> assetTypes = new Map<String,String>();
      assetTypes.put('28', 'png');
      assetTypes.put('20', 'gif');
      assetTypes.put('23', 'jpg');

      // get Document Content
      ContentVersion[] contents = [
        SELECT Id, VersionData
        FROM ContentVersion
        WHERE ContentDocumentId = :request.fileId
        LIMIT 1
      ];
      MCCreateNewAssetResult result = new MCCreateNewAssetResult();
      if (contents.size() != 1) {
        return result;
      }

      // authentication
      String auth_token = '';
      Http http = new Http();
      HttpRequest httpAuthRequest = new HttpRequest();
      httpAuthRequest.setHeader('Content-Type', 'application/json');
      httpAuthRequest.setMethod('POST');
      httpAuthRequest.setEndpoint('https://' + settings.subdomain__c + '.auth.marketingcloudapis.com/v2/token');
      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartObject();
      gen.writeStringField('grant_type', 'client_credentials');      
      gen.writeStringField('client_id', settings.client_id__c);      
      gen.writeStringField('client_secret', settings.client_secret__c);      
      gen.writeStringField('account_id', settings.account_id__c);
      gen.writeEndObject();
      httpAuthRequest.setBody(gen.getAsString());
      HttpResponse httpAuthResponse = http.send(httpAuthRequest);
      JSONParser parser = JSON.createParser(httpAuthResponse.getBody());
      while (parser.nextToken() != null) {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
            (parser.getText() == 'access_token')) {
            // Get the value.
            parser.nextToken();
            auth_token = parser.getText();
        }
      }

      // asset post
      HttpRequest httpRestRequest = new HttpRequest();
      httpRestRequest.setMethod('POST');
      httpRestRequest.setHeader('Content-Type', 'application/json');
      httpRestRequest.setHeader('Authorization', 'Bearer ' + auth_token);
      httpRestRequest.setEndpoint('https://' + settings.subdomain__c + '.rest.marketingcloudapis.com/asset/v1/content/assets');
      JSONGenerator assetGen = JSON.createGenerator(true);
      assetGen.writeStartObject();
      assetGen.writeStringField('name', request.assetName);      
      assetGen.writeStringField('customerKey', request?.customerKey);      
      assetGen.writeStringField('description', request?.description);      
      assetGen.writeNumberField('version', request.version);      
      assetGen.writeFieldName('category');
      assetGen.writeStartObject();
      assetGen.writeNumberField('id', 1783484);      
      assetGen.writeEndObject();
      assetGen.writeFieldName('assetType');
      assetGen.writeStartObject();
      assetGen.writeStringField('name', assetTypes.get(request?.assetType));      
      assetGen.writeNumberField('id', Integer.valueOf(request?.assetType));      
      assetGen.writeEndObject();
      assetGen.writeFieldName('FileProperties');
      assetGen.writeStartObject();
      assetGen.writeStringField('fileName', request?.fileName);      
      assetGen.writeEndObject();
      assetGen.writeBlobField('file', contents[0]?.VersionData);      
      assetGen.writeEndObject();
      httpRestRequest.setBody(assetGen.getAsString());
      HttpResponse httpRestResponse = http.send(httpRestRequest);

      // parse response
      JSONParser assetParser = JSON.createParser(httpRestResponse.getBody());
      MCAssetResponse assetResponse = (MCAssetResponse)assetParser.readValueAs(MCAssetResponse.class);
      result.internalID = assetResponse?.id;
      result.publishedDatetime = assetResponse?.modifiedDate;
      result.publishedURL = assetResponse?.fileProperties?.publishedURL;
      result.status = assetResponse?.status?.name;
      result.fileSize = assetResponse?.fileProperties?.fileSize;
      result.width = assetResponse?.fileProperties?.width;
      result.height = assetResponse?.fileProperties?.height;

      return result;
    }


    global class MCCreateNewAssetRequest {
      @InvocableVariable(required=true label='Connection' description='Connection settings as defined in Custom Metadata MCConnectionSetting__mdt')
      global String connection;

      @InvocableVariable(required=true label='File ID' description='Identifier of the new file')
        global ID fileId;
     
      @InvocableVariable(required=true label='Record ID' description='Related Salesforrce record')
      global ID recordId;

      @InvocableVariable(required=true label='Asset Name' description='Name of the asset, set by the client. 200 character maximum')
      global String assetName;
      
      @InvocableVariable(label='Customer Key' description='Reference to customers private ID/name for the asset')
      global String customerKey;

      @InvocableVariable(label='Description' description='Description of the asset, set by the client')
      global String description;

      @InvocableVariable(label='Version' description='The version of the asset')
      global Integer version;

      @InvocableVariable(label='Asset Type Id' description='The type of the asset (i.e. 28 for png)')
      global String assetType;      

      @InvocableVariable(label='Asset File Name' description='The name of the asset file')
      global String fileName;      
    }
     
    global class MCCreateNewAssetResult {
      @InvocableVariable(label='Internal ID' description='Internal Marketing Cloud Identifier')
      global String internalID;
    
      @InvocableVariable(label='Published URL' description='Asset is available at this URL')
      global String publishedURL;

      @InvocableVariable(label='Status' description='Asset Status')
      global String status;

      @InvocableVariable(label='Published Datetime' description='Asset publication date and time')
      global Datetime publishedDatetime;

      @InvocableVariable(label='File Size' description='Asset file size')
      global Integer fileSize;

      @InvocableVariable(label='Asset Width' description='Asset pixel width')
      global Integer width;

      @InvocableVariable(label='Asset Height' description='Asset pixel height')
      global Integer height;
}
     
    class MCCreateNewAssetException extends Exception {}

    public class MCAssetResponse {
      public String id;
      public String objectID;
      public Integer version;
      public Datetime modifiedDate;
      public MCAssetResponseFileProperties fileProperties;
      public MCAssetResponseStatus status;
    }

    public class MCAssetResponseFileProperties {
      public String fileName;
      public Integer fileSize;
      public Integer width;
      public Integer height;
      public String publishedURL;
    }

    public class MCAssetResponseStatus {
      public String id;
      public String name;
    }

}
