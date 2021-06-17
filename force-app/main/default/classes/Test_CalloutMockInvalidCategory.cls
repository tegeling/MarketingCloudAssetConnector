@isTest
global class Test_CalloutMockInvalidCategory implements HttpCalloutMock {
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
      body += '    "error": "Something is wrong."';
      body += '}';
    }
    res.setBody(body);
    return res;
  }
}
