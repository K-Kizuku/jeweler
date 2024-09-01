use aws_sdk_s3::{Client, Error};
use lambda_runtime::{handler_fn, Context, Error as LambdaError};
use serde_json::json;
use std::env;

#[tokio::main]
async fn main() -> Result<(), LambdaError> {
    let func = handler_fn(handler);
    lambda_runtime::run(func).await?;
    Ok(())
}

async fn handler(event: serde_json::Value, _: Context) -> Result<serde_json::Value, LambdaError> {
    let s3_client = Client::new(&aws_config::load_from_env().await);
    let bucket_name = env::var("BUCKET_NAME").expect("BUCKET_NAME must be set");

    let request = &event["Records"][0]["cf"]["request"];
    let host_header = request["headers"]["host"][0]["value"].as_str().unwrap();
    let subdomain = host_header.split('.').next().unwrap();
    let uri = request["uri"].as_str().unwrap();
    let key = format!("{}{}", subdomain, uri);

    match get_s3_object(&s3_client, &bucket_name, &key).await {
        Ok(data) => Ok(json!({
            "status": "200",
            "statusDescription": "OK",
            "headers": {
                "content-type": [{"key": "Content-Type", "value": "text/html"}]
            },
            "body": String::from_utf8_lossy(&data).to_string(),
        })),
        Err(_) => Ok(json!({
            "status": "404",
            "statusDescription": "Not Found",
            "headers": {
                "content-type": [{"key": "Content-Type", "value": "text/html"}]
            },
            "body": "404 Not Found",
        })),
    }
}

async fn get_s3_object(s3_client: &Client, bucket_name: &str, key: &str) -> Result<Vec<u8>, Error> {
    let resp = s3_client
        .get_object()
        .bucket(bucket_name)
        .key(key)
        .send()
        .await?;

    let data = resp.body.collect().await?;
    Ok(data.into_bytes().to_vec())
}