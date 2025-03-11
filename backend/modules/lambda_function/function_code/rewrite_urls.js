exports.handler = async (event) => {
    const request = event.Records[0].cf.request;
    let uri = request.uri;

    // Retrieve CloudFront distribution IDs from environment variables
    const rootDistributionId =
        process.env.CLOUDFRONT_ROOT_DISTRIBUTION_ID || "default-root-id";
    const subDistributionId =
        process.env.CLOUDFRONT_SUB_DISTRIBUTION_ID || "default-sub-id";

    console.log(`Handling request for URI: ${uri}`);
    console.log(`Root CloudFront Distribution ID: ${rootDistributionId}`);
    console.log(`Sub CloudFront Distribution ID: ${subDistributionId}`);

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
