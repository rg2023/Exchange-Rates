import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom'; // <-- ייבוא הוק לניווט
import CurrencySelector from './currencySelector';
import ExchangeRateTable from './exchangeTable';

function HomePage() {
  const [baseCurrency, setBaseCurrency] = useState('');
  const [currencies, setCurrencies] = useState([]);

  const navigate = useNavigate(); // הוק לניווט בין דפים

  return (
    <div>
      <h1>Exchange Rates</h1>
      <CurrencySelector
        baseCurrency={baseCurrency}
        setBaseCurrency={setBaseCurrency}
        setCurrencies={setCurrencies}
        currencies={currencies}
      />

      {baseCurrency && (
        <>
          <ExchangeRateTable baseCurrency={baseCurrency} currencies={currencies} />
          <button
            className="btn btn-primary mt-3"
            onClick={() => navigate(`/upload/${baseCurrency}`)} // נווט לנתיב עם הפרמטר
          >
           🪣 שמור קובץ בבאקט
          </button>
        </>
      )}
    </div>
  );
}

export default HomePage;
