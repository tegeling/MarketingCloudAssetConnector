global with sharing class MCCreateNewAssetCallout {
  @InvocableMethod(
    label='Create New Asset'
    description='Uploads the referenced file as a new asset to MarketingCloud.'
    category='Marketing Cloud Assets'
    callout=true
  )
  global static List<MCCreateNewAssetResult> createNewAssetCallout(
    List<MCCreateNewAssetRequest> requests
  ) {
    List<MCCreateNewAssetResult> results = new List<MCCreateNewAssetResult>();
    for (MCCreateNewAssetRequest request : requests) {
      results.add(doCallout(request));
    }
    return results;
  }

  private static MCCreateNewAssetResult doCallout(
    MCCreateNewAssetRequest request
  ) {
    // get connection settings
    String clientId = '';
    String clientSecret = '';
    String accountId = '';
    String subdomain = '';
    if (!Test.isRunningTest()) {
      List<MCConnectionSetting__mdt> settings = [
        SELECT client_id__c, client_secret__c, account_id__c, subdomain__c
        FROM MCConnectionSetting__mdt
        WHERE DeveloperName = :request.connection
      ];
      if (settings.size() != 1) {
        throw new MCCreateNewAssetCallout.MCCreateNewAssetException(
          'Connection not found'
        );
      }
      clientId = settings[0].client_id__c;
      clientSecret = settings[0].client_secret__c;
      accountId = settings[0].account_id__c;
      subdomain = settings[0].subdomain__c;
    }

    Map<String, Integer> assetTypes = new Map<String, Integer>();
    assetTypes.put('png', 28);
    assetTypes.put('gif', 20);
    assetTypes.put('jpg', 23);

    // get Document Content
    ContentVersion[] contents = [
      SELECT Id, PathOnClient, FileExtension, VersionData, VersionNumber
      FROM ContentVersion
      WHERE ContentDocumentId = :request.fileId
      LIMIT 1
    ];
    if (contents.size() == 0) {
      throw new MCCreateNewAssetCallout.MCCreateNewAssetException(
        'No file attached'
      );
    }
    String pathOnClient = '';
    String fileExtension = '';
    Blob versionData = Blob.valueOf('This is version data');
    String versionNumber = '1';
    if (!Test.isRunningTest()) {
      pathOnClient = contents[0].PathOnClient;
      fileExtension = contents[0].FileExtension;
      versionData = contents[0].VersionData;
      versionNumber = contents[0].VersionNumber;
    }

    MCCreateNewAssetResult result = new MCCreateNewAssetResult();
    // check metadata
    Integer version = 0;
    if (request?.version != null) {
      version = request?.version;
    } else if (!String.isBlank(versionNumber)) {
      version = Integer.valueOf(versionNumber);
    }
    String assetType = 'gif';
    if (!String.isBlank(request?.assetType)) {
      assetType = request?.assetType;
    } else if (!String.isBlank(fileExtension)) {
      assetType = fileExtension;
    }
    String fileName = 'unknown';
    if (!String.isBlank(request?.fileName)) {
      fileName = request?.fileName;
    } else if (!String.isBlank(pathOnClient)) {
      fileName = pathOnClient;
    }
    String customerKey = 'unknown';
    if (!String.isBlank(request?.customerKey)) {
      customerKey = request?.customerKey;
    } else {
      customerKey = contents[0]?.Id;
    }
    Integer categoryId = 0;
    Integer rootCategoryId = 0;

    // check asset type is valid
    if (!assetTypes.containsKey(assetType)) {
      throw new MCCreateNewAssetCallout.MCCreateNewAssetException(
        'Unsupported asset type'
      );
    }

    // authentication
    String auth_token = '';
    Http http = new Http();
    HttpRequest httpAuthRequest = new HttpRequest();
    httpAuthRequest.setHeader('Content-Type', 'application/json');
    httpAuthRequest.setMethod('POST');
    httpAuthRequest.setEndpoint(
      'https://' +
      subdomain +
      '.auth.marketingcloudapis.com/v2/token'
    );
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('grant_type', 'client_credentials');
    gen.writeStringField('client_id', clientId);
    gen.writeStringField('client_secret', clientSecret);
    gen.writeStringField('account_id', accountId);
    gen.writeEndObject();
    httpAuthRequest.setBody(gen.getAsString());
    HttpResponse httpAuthResponse = http.send(httpAuthRequest);
    JSONParser parser = JSON.createParser(httpAuthResponse.getBody());
    while (parser.nextToken() != null) {
      if (
        (parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
        (parser.getText() == 'access_token')
      ) {
        // Get the value.
        parser.nextToken();
        auth_token = parser.getText();
      }
    }
    // check auth_token
    if (String.isBlank(auth_token)) {
      throw new MCCreateNewAssetCallout.MCCreateNewAssetException(
        'Authentication failed - ' + httpAuthResponse.getBody()
      );
    }

    // retrieve categories
    HttpRequest httpCategoryRequest = new HttpRequest();
    httpCategoryRequest.setMethod('GET');
    httpCategoryRequest.setHeader('Content-Type', 'application/json');
    httpCategoryRequest.setHeader('Authorization', 'Bearer ' + auth_token);
    httpCategoryRequest.setEndpoint(
      'https://' +
      subdomain +
      '.rest.marketingcloudapis.com/asset/v1/content/categories'
    );
    HttpResponse httpCategoryResponse = http.send(httpCategoryRequest);

    // parse categories response
    JSONParser categoryParser = JSON.createParser(
      httpCategoryResponse.getBody()
    );
    MCCategory categoryResponse = (MCCategory) categoryParser.readValueAs(
      MCCategory.class
    );
    for (MCCategoryItem catItem : categoryResponse.items) {
      // check root folder or category
      if (catItem.parentId == 0) {
        rootCategoryId = catItem.id;
      } else if (catItem?.name == request.categoryName) {
        categoryId = catItem.id;
      }
    }
    // check category
    if (categoryId == 0) {
      categoryId = rootCategoryId;
    }

    // raise exception if no category id was found
    if (categoryId == 0) {
      throw new MCCreateNewAssetCallout.MCCreateNewAssetException(
        'Category not found'
      );
    }

    // asset post
    HttpRequest httpRestRequest = new HttpRequest();
    httpRestRequest.setMethod('POST');
    httpRestRequest.setHeader('Content-Type', 'application/json');
    httpRestRequest.setHeader('Authorization', 'Bearer ' + auth_token);
    httpRestRequest.setEndpoint(
      'https://' +
      subdomain +
      '.rest.marketingcloudapis.com/asset/v1/content/assets'
    );
    JSONGenerator assetGen = JSON.createGenerator(true);
    assetGen.writeStartObject();
    assetGen.writeStringField('name', request.assetName);
    assetGen.writeStringField('customerKey', customerKey);
    assetGen.writeStringField('description', request?.description);
    assetGen.writeNumberField('version', version);
    assetGen.writeFieldName('category');
    assetGen.writeStartObject();
    assetGen.writeNumberField('id', categoryId);
    assetGen.writeEndObject();
    assetGen.writeFieldName('assetType');
    assetGen.writeStartObject();
    assetGen.writeStringField('name', assetType);
    assetGen.writeNumberField('id', assetTypes.get(assetType));
    assetGen.writeEndObject();
    assetGen.writeFieldName('FileProperties');
    assetGen.writeStartObject();
    assetGen.writeStringField('fileName', fileName);
    assetGen.writeEndObject();
    assetGen.writeBlobField('file', versionData);
    assetGen.writeEndObject();
    httpRestRequest.setBody(assetGen.getAsString());
    HttpResponse httpRestResponse = http.send(httpRestRequest);

    // parse response
    JSONParser assetParser = JSON.createParser(httpRestResponse.getBody());
    MCAssetResponse assetResponse = (MCAssetResponse) assetParser.readValueAs(
      MCAssetResponse.class
    );

    // check if response was successfully parsed
    if (assetResponse?.id == null) {
      throw new MCCreateNewAssetCallout.MCCreateNewAssetException(
        'Invalid response - ' + httpRestResponse.getBody()
      );
    }

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
    @InvocableVariable(
      required=true
      label='Connection'
      description='Connection settings as defined in Custom Metadata MCConnectionSetting__mdt'
    )
    global String connection;

    @InvocableVariable(
      required=true
      label='File ID'
      description='Identifier of the new file'
    )
    global ID fileId;

    @InvocableVariable(
      required=true
      label='Asset Name'
      description='Name of the asset, set by the client. 200 character maximum'
    )
    global String assetName;

    @InvocableVariable(
      required=true
      label='Category Name'
      description='Name of the category/folder, where the assets is stored. Default is root folder.'
    )
    global String categoryName;

    @InvocableVariable(
      label='Customer Key'
      description='Reference to customers private ID/name for the asset (optional)'
    )
    global String customerKey;

    @InvocableVariable(
      label='Description'
      description='Description of the asset, set by the client'
    )
    global String description;

    @InvocableVariable(
      label='Version'
      description='The version of the asset (optional)'
    )
    global Integer version;

    @InvocableVariable(
      label='Asset Type'
      description='The type of the asset (png, gif, jpg - optional)'
    )
    global String assetType;

    @InvocableVariable(
      label='Asset File Name'
      description='The name of the asset file (optional)'
    )
    global String fileName;
  }

  global class MCCreateNewAssetResult {
    @InvocableVariable(
      label='Internal ID'
      description='Internal Marketing Cloud Identifier'
    )
    global String internalID;

    @InvocableVariable(
      label='Published URL'
      description='Asset is available at this URL'
    )
    global String publishedURL;

    @InvocableVariable(label='Status' description='Asset Status')
    global String status;

    @InvocableVariable(
      label='Published Datetime'
      description='Asset publication date and time'
    )
    global Datetime publishedDatetime;

    @InvocableVariable(label='File Size' description='Asset file size')
    global Integer fileSize;

    @InvocableVariable(label='Asset Width' description='Asset pixel width')
    global Integer width;

    @InvocableVariable(label='Asset Height' description='Asset pixel height')
    global Integer height;
  }

  class MCCreateNewAssetException extends Exception {
  }

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

  public class MCCategory {
    public Integer count;
    public Integer page;
    public Integer pageSize;
    public List<MCCategoryItem> items;
  }

  public class MCCategoryItem {
    public Integer id;
    public String description;
    public Integer enterpriseId;
    public Integer memberId;
    public String name;
    public Integer parentId;
    public String categoryType;
  }
}
