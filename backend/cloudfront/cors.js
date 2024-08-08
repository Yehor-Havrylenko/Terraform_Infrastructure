var allowedDomains = ["*"]; 
function handler(event) {
    var request = event.request;
    var headers = request.headers;
    console.log(request);
    if (request.method === "OPTIONS") {
        var response = {
            statusCode: 204,
            statusDescription: 'OK',
            headers: {}
            }
        if (request.headers['origin']) {
          var regexp = allowedDomains.map((d) => {
            var rgxp = d.replace(/\./g, '\\.').replace('*', '.*');
 
            return new RegExp(`^$${rgxp}$$`);
          });
 
          var testDomen = (d) => {
            return regexp.some((r) => r.test(d));
          }
 
          if (allowedDomains.includes("*") || testDomen(request.headers['origin'].value)) {
            response.headers['access-control-allow-origin'] = {value: request.headers['origin'].value};
            response.headers['access-control-allow-headers'] = {value: "*"};
            response.headers['access-control-allow-methods'] = {value: "HEAD, GET, POST, PUT, DELETE, PATCH"};
            response.headers['access-control-allow-credentials'] = {value: "true"};
            response.headers['access-control-max-age'] = {value: "3600"};
            response.headers['access-control-expose-headers'] = {value: "Location"};
          }
        }
        console.log(response);
        return response;
    }
    return request;
}