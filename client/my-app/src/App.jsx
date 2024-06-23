import React, { useState } from 'react';
import CurrencySelector from './currencySelector';
import ExchangeRateTable from './exchangeTable';
import './App.css';

function App() {
  const [baseCurrency, setBaseCurrency] = useState('');
  const [currencies, setCurrencies] = useState([]);

  return (
    <div>
      <h1>Exchange Rates</h1>
      <CurrencySelector
        baseCurrency={baseCurrency}
        setBaseCurrency={setBaseCurrency}
        setCurrencies={setCurrencies}
        currencies={currencies}
      />
      {baseCurrency && <ExchangeRateTable baseCurrency={baseCurrency} currencies={currencies} />}
    </div>
  );
}

export default App;
