import azure.functions as func
import json
import os
import io
from pypdf import PdfReader
from azure.storage.blob import BlobServiceClient

app = func.FunctionApp()

@app.blob_trigger(
    arg_name="myblob",
    path="resumes/{name}",
    connection="StorageConnectionString",
    source="EventGrid"
)
def score_resume(myblob: func.InputStream):
    filename = myblob.name.split("/")[-1]

    pdf_bytes = myblob.read()
    reader = PdfReader(io.BytesIO(pdf_bytes))

    text = ""
    for page in reader.pages:
        page_text = page.extract_text()
        if page_text:
            text += page_text.lower()

    keywords = [
        "azure",
        "python",
        "linux",
        "devops",
        "ansible"
    ]

    matched_keywords = []

    for keyword in keywords:
        if keyword in text:
            matched_keywords.append(keyword)

    score = int((len(matched_keywords) / len(keywords)) * 100)

    result = {
        "file": filename,
        "score": score,
        "matched_keywords": matched_keywords
    }

    connection_string = os.environ["StorageConnectionString"]

    blob_service_client = BlobServiceClient.from_connection_string(
        connection_string
    )

    results_container = blob_service_client.get_container_client("results")

    result_name = filename.rsplit(".", 1)[0] + ".json"

    results_container.upload_blob(
        name=result_name,
        data=json.dumps(result, indent=2),
        overwrite=True
    )

    print(f"Scored {filename}: {score}")
