from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Any
import httpx
from pathlib import Path
import json
from app.utils.storage import upload_file
from app.utils.database import insert_data
from datetime import datetime
import io

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["GET"],
    allow_headers=["*"],
)


currency_data = ["USD", "EUR", "GBP", "CNY", "ILS"]
cached_exchange_data: Dict[str, list] = {}

@app.get("/currencies/", response_model=List[str])
def get_currencies():
    return currency_data

@app.get("/exchange-rates/{baseCurrency}", response_model=List[Dict[str, Any]])
async def get_exchange_rates(baseCurrency: str):
    try:
        api_key = "4e61cf72d3ae31c331eeed6a"
        url = f"https://v6.exchangerate-api.com/v6/{api_key}/latest/{baseCurrency}"
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            if response.status_code == 200:
                data = response.json()
                filtered_rates = [
                    {"currency": currency, "rate": data["conversion_rates"][currency]}
                    for currency in currency_data
                    if currency != baseCurrency and currency in data["conversion_rates"]
                ]
                cached_exchange_data[baseCurrency] = filtered_rates
                return filtered_rates
            else:
                raise HTTPException(status_code=response.status_code, detail="Failed to fetch exchange rates")
    except Exception as e:
        print(f"Error fetching exchange rates: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))



@app.post("/upload-to-bucket/{baseCurrency}")
def upload_to_bucket(baseCurrency: str):
    if baseCurrency not in cached_exchange_data:
        raise HTTPException(status_code=404, detail="Data not found in memory. Please select a currency first.")
    try:
        json_data = json.dumps(cached_exchange_data[baseCurrency], indent=4)
        bucket_name = "bucket_sandbox-lz-rachelge"
        today_str = datetime.now().strftime("%Y-%m-%d")  
        filename = f"exchange_rates_{baseCurrency}_{today_str}.json"
        file_stream = io.BytesIO(json_data.encode('utf-8'))
        upload_file(bucket_name, file_stream, filename)
        return {"message": f"{filename} uploaded successfully to bucket {bucket_name}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    


@app.post("/save/{baseCurrency}")
def save_to_db(baseCurrency: str):
    if baseCurrency not in cached_exchange_data:
        raise HTTPException(status_code=404, detail="Data not found in memory. Please select a currency first.")
    try:
        exchange_data = cached_exchange_data[baseCurrency]
        insert_data("sandbox-lz-rachelge", baseCurrency, exchange_data)
        return {"message": "Data saved to database successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

 