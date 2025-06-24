import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import HomePage from './home';
import UploadPage from './uploadFile';
import SaveInDB from './saveInDB'; // Assuming you have a SaveInDB component

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/upload/:baseCurrency" element={<UploadPage />} />
        <Route path="/save/:baseCurrency" element={<SaveInDB />} />
      </Routes>
    </Router>
  );
}
export default App;
