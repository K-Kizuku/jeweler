# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import https_fn

import requests

# app = initialize_app()


@https_fn.on_request()
def addmessage(req: https_fn.Request) -> https_fn.Response:
    """Take the text parameter passed to this HTTP endpoint and insert it into
    a new document in the messages collection."""
    # Grab the text parameter.
    original = req.args.get("text")
    if original is None:
        return https_fn.Response("No text parameter provided", status=400)

    # firestore_client: google.cloud.firestore.Client = firestore.client()

    # # Push the new message into Cloud Firestore using the Firebase Admin SDK.
    # _, doc_ref = firestore_client.collection("messages").add(
    #     {"original": original}
    # )

    # Send back a message that we've successfully written the message
    return https_fn.Response(f"Message with ID {original} added.")

@https_fn.on_request()
def proxy(req: https_fn.Request) -> https_fn.Response:
    # return https_fn.Response("hoge")
    try:
        # Supabase Edge FunctionのURLにリクエストを転送
        supabase_url = "https://bvlhyrzkyzwoghnosmlz.supabase.co/functions/v1/jeweler"
        supabase_response = requests.request(
            method=req.method,
            url=supabase_url,
            headers={key: value for key, value in req.headers if key.lower() != 'host'},
            data=req.get_data() if req.method not in ['GET', 'HEAD'] else None
        )
        print(supabase_response.content)

        # Supabaseのレスポンスのボディを取得
        body = supabase_response.text
        # `Content-Type`を`text/html`に上書き
        headers = {key: value for key, value in supabase_response.headers.items() if key.lower() != 'content-type'}
        headers['Content-Type'] = 'text/html; charset=UTF-8'
        # print(https_fn.Response(body, status=supabase_response.status_code, headers=headers))
        # レスポンスをクライアントに返す
        return https_fn.Response(body, status=supabase_response.status_code)
    
    except Exception as e:
        # エラーハンドリング
        print(f"Error proxying request to Supabase: {str(e)}")
        return https_fn.Response("Internal Server Error", status=500)



