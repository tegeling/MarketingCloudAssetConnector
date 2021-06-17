@isTest
global class Test_CalloutMockValidResponse implements HttpCalloutMock {
  global HttpResponse respond(HttpRequest req) {
    // Create a fake response
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);
    String body = '';
    // check endpoint and method
    if (req.getEndpoint().contains('.auth.marketingcloudapis.com/v2/token')) {
      body += '{';
      body += '    "access_token": "token",';
      body += '    "token_type": "Bearer",';
      body += '    "expires_in": 1079,';
      body += '    "scope": "journeys_delete",';
      body += '    "soap_instance_url": "https://mc120345679012-abcdefghi-key.soap.marketingcloudapis.com/",';
      body += '    "rest_instance_url": "https://mc120345679012-abcdefghi-key.rest.marketingcloudapis.com/"';
      body += '}';
    } else if (
      req.getEndpoint()
        .contains('.rest.marketingcloudapis.com/asset/v1/content/categories')
    ) {
      body += '{';
      body += '    "count": 2,';
      body += '    "page": 1,';
      body += '    "pageSize": 50,';
      body += '    "links": {},';
      body += '    "items": [';
      body += '        {';
      body += '            "id": 100,';
      body += '            "description": "The root folder for assets",';
      body += '            "enterpriseId": 200,';
      body += '            "memberId": 300,';
      body += '            "name": "Content Builder",';
      body += '            "parentId": 0,';
      body += '            "categoryType": "asset"';
      body += '        },';
      body += '        {';
      body += '            "id": 101,';
      body += '            "description": "",';
      body += '            "enterpriseId": 200,';
      body += '            "memberId": 300,';
      body += '            "name": "TestCategory",';
      body += '            "parentId": 100,';
      body += '            "categoryType": "asset"';
      body += '        }';
      body += '    ]';
      body += '}';
    } else if (
      req.getEndpoint()
        .contains('.rest.marketingcloudapis.com/asset/v1/content/assets')
    ) {
      body += '{';
      body += '    "id": 9000,';
      body += '    "customerKey": "customerkey",';
      body += '    "objectID": "5000",';
      body += '    "assetType": {';
      body += '        "id": 28,';
      body += '        "name": "png",';
      body += '        "displayName": "Image"';
      body += '    },';
      body += '    "fileProperties": {';
      body += '        "fileName": "test",';
      body += '        "extension": "png",';
      body += '        "fileSize": 500,';
      body += '        "fileCreatedDate": "2021-02-16T09:00:26.7721445-06:00",';
      body += '        "width": 100,';
      body += '        "height": 100,';
      body += '        "publishedURL": "url"';
      body += '    },';
      body += '    "name": "test",';
      body += '    "owner": {';
      body += '        "id": 10,';
      body += '        "email": "",';
      body += '        "name": "name",';
      body += '        "userId": "10000"';
      body += '    },';
      body += '    "createdDate": "2021-02-16T09:00:26.773-06:00",';
      body += '    "createdBy": {';
      body += '        "id": 10,';
      body += '        "email": "",';
      body += '        "name": "name",';
      body += '        "userId": "10000"';
      body += '    },';
      body += '    "modifiedDate": "2021-02-16T09:00:26.773-06:00",';
      body += '    "modifiedBy": {';
      body += '        "id": 10,';
      body += '        "email": "",';
      body += '        "name": "name",';
      body += '        "userId": "10000"';
      body += '    },';
      body += '    "enterpriseId": 200,';
      body += '    "memberId": 300,';
      body += '    "status": {';
      body += '        "id": 2,';
      body += '        "name": "Published"';
      body += '    },';
      body += '    "category": {';
      body += '        "id": 101,';
      body += '        "name": "Content Builder",';
      body += '        "parentId": 0';
      body += '    },';
      body += '    "availableViews": [],';
      body += '    "modelVersion": 2';
      body += '}';
    }
    res.setBody(body);
    return res;
  }
}
