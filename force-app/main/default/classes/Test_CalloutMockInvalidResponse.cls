@isTest
global class Test_CalloutMockInvalidResponse implements HttpCalloutMock {
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
      body += '    "error": "Something is wrong."';
      body += '}';
    }
    res.setBody(body);
    return res;
  }
}
