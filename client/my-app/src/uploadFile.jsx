import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';

function UploadPage() {
  const { baseCurrency } = useParams();
  const backendUrl = window.VITE_BACKEND_URL;
  const [successMessage, setSuccessMessage] = useState('');

  useEffect(() => {
    const upload = async () => {
      try {
        const response = await fetch(`${backendUrl}/upload-to-bucket/${baseCurrency}`, {
          method: 'POST',
        });
        const result = await response.json();
        if (response.ok) {
          setSuccessMessage('📤 הקובץ הועלה ל־GCS בהצלחה!');
        } else {
          setSuccessMessage(`שגיאה: ${result.detail}`);
        }
      } catch (error) {
        setSuccessMessage('שגיאה בהעלאה');
        console.error(error);
      }
    };

    upload();
  }, [baseCurrency, backendUrl]);

  return (
    <div className="container mt-4">
      <h2>העלאת נתונים עבור מטבע: {baseCurrency}</h2>
      <p>{successMessage}</p>
    </div>
  );
}

export default UploadPage;