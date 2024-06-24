from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Any
import httpx

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["GET"],
    allow_headers=["*"],
)


currency_data = ["USD", "EUR", "GBP", "CNY", "ILS"]


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
                return filtered_rates
            else:
                raise HTTPException(status_code=response.status_code, detail="Failed to fetch exchange rates")
    except Exception as e:
        print(f"Error fetching exchange rates: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
