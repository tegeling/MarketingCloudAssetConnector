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

      // call Rest API
      MCCreateNewAssetResult result = new MCCreateNewAssetResult();
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
      assetGen.writeStringField('file', 'iVBORw  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');      
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
