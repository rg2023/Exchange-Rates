import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';

function SaveInDB() {
  const { baseCurrency } = useParams();
  const backendUrl = window.VITE_BACKEND_URL;
  const [message, setMessage] = useState('Saving data...');
  const [status, setStatus] = useState<'idle' | 'success' | 'error'>('idle');

  useEffect(() => {
    const upload = async () => {
      try {
        const response = await fetch(`${backendUrl}/save/${baseCurrency}`, {
          method: 'POST',
        });
        const result = await response.json();
        if (response.ok) {
          setStatus('success');
          setMessage(`✅ Data for ${baseCurrency} saved successfully.`);
        } else {
          setStatus('error');
          setMessage(`❌ Error: ${result.detail}`);
        }
      } catch (error) {
        setStatus('error');
        setMessage('❌ Error while saving data.');
        console.error(error);
      }
    };

    upload();
  }, [baseCurrency]);

  return (
    <div className="container mt-4">
      <h2>{status === 'success' ? 'Data Saved' : 'Saving...'}</h2>
      <p>{message}</p>
    </div>
  );
}

export default SaveInDB;
