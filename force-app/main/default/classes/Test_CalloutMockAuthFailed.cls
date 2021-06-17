@isTest
global class Test_CalloutMockAuthFailed implements HttpCalloutMock {
  global HttpResponse respond(HttpRequest req) {
    // Create a fake response
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);
    String body = '';
    // check endpoint and method
    if (req.getEndpoint().contains('.auth.marketingcloudapis.com/v2/token')) {
      body += '{';
      body += '    "error": "invalid_client",';
      body += '    "error_description": "Client authentication failed. Make sure that the client ID and client secret are valid and that the package is installed and enabled.",';
      body += '    "error_uri": "https://developer.salesforce.com/docs"';
      body += '}';
    }
    res.setBody(body);
    return res;
  }
}
