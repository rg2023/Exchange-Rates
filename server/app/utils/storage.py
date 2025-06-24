from google.cloud import storage
from google.api_core.exceptions import GoogleAPIError

def upload_file(bucket_name, file_stream, filename):
    try:
        if not file_stream:
            raise ValueError("File stream is empty")
        client = storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(filename)
        file_stream.seek(0)
        blob.upload_from_file(file_stream)
        return True
    except GoogleAPIError as e:
        raise
    except Exception as e:
        raise