import React, { useState, useEffect } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';

function ExchangeRateTable({ baseCurrency, currencies }) {
    const [exchangeRates, setExchangeRates] = useState([]);

    useEffect(() => {
        async function fetchData() {
            try {
                const response = await fetch(`http://localhost:8000/exchange-rates/${baseCurrency}`);
                if (!response.ok) {
                    throw new Error('Failed to fetch exchange rates');
                }
                const data = await response.json();
                setExchangeRates(data);
            } catch (error) {
                console.error('Error fetching exchange rates:', error);
            }
        }

        fetchData();
    }, [baseCurrency]);

    return (
        <div className="container mt-4">
            <table className="table table-striped table-bordered">
                <thead className="thead-dark">
                    <tr>
                        <th>Base Currency</th>
                        <th>Target Currency</th>
                        <th>Exchange Rate</th>
                    </tr>
                </thead>
                <tbody>
                    {exchangeRates.map((rate) => (
                        <tr key={rate.currency}>
                            <td>{baseCurrency}</td>
                            <td>{rate.currency}</td>
                            <td>{rate.rate.toFixed(3)}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

export default ExchangeRateTable;
