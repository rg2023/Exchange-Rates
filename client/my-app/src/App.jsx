import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import HomePage from './HomePage';
import UploadPage from './uploadFile';

function App() {
  return (
    <Router>
      <nav>
        <Link to="/" style={{ marginRight: 10 }}>Home</Link>
        {/* כאן אפשר להוסיף קישורים לדפים נוספים בעתיד */}
      </nav>

      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/upload/:baseCurrency" element={<UploadPage />} />
      </Routes>
    </Router>
  );
}
export default App;
