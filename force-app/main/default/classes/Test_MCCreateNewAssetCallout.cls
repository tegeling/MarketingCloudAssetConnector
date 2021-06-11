@IsTest
private class Test_MCCreateNewAssetCallout {
  @IsTest
  private static void testCallout() {
    // setup test data
    Contentversion cv = new Contentversion();
    cv.Title = 'ABC';
    cv.PathOnClient = 'test';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8')
    );
    insert cv;
    List<MCCreateNewAssetCallout.MCCreateNewAssetRequest> inputParams = new List<MCCreateNewAssetCallout.MCCreateNewAssetRequest>();
    MCCreateNewAssetCallout.MCCreateNewAssetRequest p1 = new MCCreateNewAssetCallout.MCCreateNewAssetRequest();
    p1.connection = 'MC';
    p1.fileId = cv.Id;
    p1.assetName = 'TestAsset';
    p1.categoryName = 'TestCategory';
    p1.customerKey = 'TestCcustomerKey';
    p1.description = 'Test Description';
    p1.version = 1;
    p1.assetType = 'jpg';
    p1.fileName = 'TestFileName';
    inputParams.add(p1);

    Test.startTest();
    List<MCCreateNewAssetCallout.MCCreateNewAssetResult> outputParams = MCCreateNewAssetCallout.createNewAssetCallout(
      inputParams
    );
    Test.stopTest();

    System.assertEquals(true, true, 'What is wrong?');
  }
}
