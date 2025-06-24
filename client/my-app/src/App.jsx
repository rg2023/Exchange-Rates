import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import HomePage from './home';
import UploadPage from './uploadFile';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/upload/:baseCurrency" element={<UploadPage />} />
      </Routes>
    </Router>
  );
}
export default App;
