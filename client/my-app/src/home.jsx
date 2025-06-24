import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom'; // <-- ייבוא הוק לניווט
import CurrencySelector from './currencySelector';
import ExchangeRateTable from './exchangeTable';

function HomePage() {
  const [baseCurrency, setBaseCurrency] = useState('');
  const [currencies, setCurrencies] = useState([]);
  const navigate = useNavigate();

  return (
   <div className="d-flex flex-column align-items-center mt-5">
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
        onClick={() => navigate(`/upload/${baseCurrency}`)}
      >
        🪣 UPLOAD TO BUCKET 
      </button>
      <button
        className="btn btn-primary mt-3"
        onClick={() => navigate(`/save/${baseCurrency}`)}
      >
        SAVE IN DATABASE
      </button>
    </>
  )}
</div>
  );
}



export default HomePage;
