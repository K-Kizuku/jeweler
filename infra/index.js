import { S3Client } from "@aws-sdk/client-s3";
const s3 = new S3Client({ region: "us-west-2" });

export const handler = async (event) => {
  const request = event.Records[0].cf.request;
  const subdomain = request.headers.host[0].value.split(".")[0];
  const key = `${subdomain}${request.uri}`;

  try {
    const s3Params = {
      Bucket: process.env.BUCKET_NAME,
      Key: key,
    };
    const data = await s3.getObject(s3Params).promise();

    const response = {
      status: "200",
      statusDescription: "OK",
      headers: {
        "content-type": [{ key: "Content-Type", value: "text/html" }],
      },
      body: data.Body.toString("utf-8"),
    };

    return response;
  } catch (error) {
    return {
      status: "404",
      statusDescription: "Not Found",
      headers: {
        "content-type": [{ key: "Content-Type", value: "text/html" }],
      },
      body: "404 Not Found",
    };
  }
};
