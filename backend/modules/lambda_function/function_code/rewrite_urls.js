exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    let uri = request.uri;

    console.log(`Handling request for URI: ${uri}`);

    // If requesting a directory, serve index.html
    if (uri.endsWith("/")) {
        request.uri += "index.html";
    }

    // If requesting a page without an extension, add .html
    else if (!uri.includes(".") && !uri.match(/\.[a-zA-Z0-9]+$/)) {
        request.uri += ".html";
    }

    return request;
};
