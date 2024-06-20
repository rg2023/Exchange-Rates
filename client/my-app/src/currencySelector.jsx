import React, { useEffect } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';

function CurrencySelector({ baseCurrency, setBaseCurrency, currencies, setCurrencies }) {
    useEffect(() => {
        async function fetchData() {
            try {
                const response = await fetch('http://localhost:8000/currencies');
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                const data = await response.json();
                if (Array.isArray(data)) {
                    setCurrencies(data);
                }
            } catch (error) {
                console.error('There was a problem with the fetch operation:', error);
            }
        }
        fetchData();
    }, [setCurrencies]);

    return (
        <div className="container">
            <div className="row justify-content-center mt-4">
                <div className="col-md-6">
                    <div className="card p-4 shadow-sm rounded">
                        <form>
                            <div className="form-group">
                                <select value={baseCurrency} onChange={(e) => setBaseCurrency(e.target.value)} className="form-control">
                                    {currencies.map((currency) => (
                                        <option key={currency} value={currency}>
                                            {currency}
                                        </option>
                                    ))}
                                </select>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default CurrencySelector;
