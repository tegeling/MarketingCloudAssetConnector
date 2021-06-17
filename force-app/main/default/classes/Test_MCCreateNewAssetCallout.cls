@IsTest
private class Test_MCCreateNewAssetCallout {
  @IsTest
  private static void testCalloutWithParams() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC.gif';
    cv.PathOnClient = 'ABC.gif';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('This is version data', 'UTF-8')
    );
    insert cv;
    ContentDocument doc = [
      SELECT Id, FileExtension, FileType, PublishStatus, Title
      FROM ContentDocument
      LIMIT 1
    ];
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = doc.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    p1.customerKey = 'TestCustomerKey';
    p1.description = 'Test Description';
    p1.version = 1;
    p1.assetType = 'gif';
    p1.fileName = 'TestFileName';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockValidResponse());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = MCCreateNewAssetCallout.createNewAssetCallout(
      inputParams
    );
    Test.stopTest();

    System.assertEquals(
      outputParams.size(),
      1,
      'Expected a single result record.'
    );
    System.assertEquals(
      outputParams[0].internalID,
      '9000',
      'Expected a single result record.'
    );
  }

  @IsTest
  private static void testCalloutWithoutParams() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC.gif';
    cv.PathOnClient = 'ABC.gif';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('This is version data', 'UTF-8')
    );
    insert cv;
    ContentDocument doc = [
      SELECT Id, FileExtension, FileType, PublishStatus, Title
      FROM ContentDocument
      LIMIT 1
    ];
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = doc.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockValidResponse());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = MCCreateNewAssetCallout.createNewAssetCallout(
      inputParams
    );
    Test.stopTest();

    System.assertEquals(
      outputParams.size(),
      1,
      'Expected a single result record.'
    );
    System.assertEquals(
      outputParams[0].internalID,
      '9000',
      'Expected a single result record.'
    );
  }

  @IsTest
  private static void testCalloutExNoFileAttached() {
    // setup test data
    Id docid = '0691X000001aKC3QAM';
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = docid;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockValidResponse());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetResult>();
    try {
      outputParams = MCCreateNewAssetCallout.createNewAssetCallout(inputParams);
    } catch (Exception ex) {
      System.assertEquals(
        ex.getMessage(),
        'No file attached',
        'Expected No file attached exception.'
      );
    }
    Test.stopTest();

    System.assertEquals(outputParams.size(), 0, 'Expected no result record.');
  }

  @IsTest
  private static void testCalloutExUnsupportedAssetType() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC.csv';
    cv.PathOnClient = 'ABC.csv';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('This is version data', 'UTF-8')
    );
    insert cv;
    ContentDocument doc = [
      SELECT Id, FileExtension, FileType, PublishStatus, Title
      FROM ContentDocument
      LIMIT 1
    ];
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = doc.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockValidResponse());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetResult>();
    try {
      outputParams = MCCreateNewAssetCallout.createNewAssetCallout(inputParams);
    } catch (Exception ex) {
      System.assertEquals(
        ex.getMessage(),
        'Unsupported asset type',
        'Expected Unsupported asset type exception.'
      );
    }
    Test.stopTest();

    System.assertEquals(outputParams.size(), 0, 'Expected no result record.');
  }

  @IsTest
  private static void testCalloutExAuthenticationFailed() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC.gif';
    cv.PathOnClient = 'ABC.gif';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('This is version data', 'UTF-8')
    );
    insert cv;
    ContentDocument doc = [
      SELECT Id, FileExtension, FileType, PublishStatus, Title
      FROM ContentDocument
      LIMIT 1
    ];
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = doc.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockAuthFailed());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetResult>();
    try {
      outputParams = MCCreateNewAssetCallout.createNewAssetCallout(inputParams);
    } catch (Exception ex) {
      System.assertEquals(
        ex.getMessage().contains('Authentication failed'),
        true,
        'Expected Authentication failed exception.'
      );
    }
    Test.stopTest();

    System.assertEquals(outputParams.size(), 0, 'Expected no result record.');
  }

  @IsTest
  private static void testCalloutExCategoryNotFound() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC.gif';
    cv.PathOnClient = 'ABC.gif';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('This is version data', 'UTF-8')
    );
    insert cv;
    ContentDocument doc = [
      SELECT Id, FileExtension, FileType, PublishStatus, Title
      FROM ContentDocument
      LIMIT 1
    ];
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = doc.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockInvalidCategory());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetResult>();
    try {
      outputParams = MCCreateNewAssetCallout.createNewAssetCallout(inputParams);
    } catch (Exception ex) {
      System.assertEquals(
        ex.getMessage(),
        'Category not found',
        'Expected Category not found exception.'
      );
    }
    Test.stopTest();

    System.assertEquals(outputParams.size(), 0, 'Expected no result record.');
  }

  @IsTest
  private static void testCalloutExInvalidResponse() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC.gif';
    cv.PathOnClient = 'ABC.gif';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('This is version data', 'UTF-8')
    );
    insert cv;
    ContentDocument doc = [
      SELECT Id, FileExtension, FileType, PublishStatus, Title
      FROM ContentDocument
      LIMIT 1
    ];
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = doc.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    inputParams.add(p1);

    // web service mockups
    Test.setMock(HttpCalloutMock.class, new Test_CalloutMockInvalidResponse());

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetResult>();
    try {
      outputParams = MCCreateNewAssetCallout.createNewAssetCallout(inputParams);
    } catch (Exception ex) {
      System.assertEquals(
        ex.getMessage().contains('Invalid response'),
        true,
        'Expected Invalid response exception.'
      );
    }
    Test.stopTest();

    System.assertEquals(outputParams.size(), 0, 'Expected no result record.');
  }
}
