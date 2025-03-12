// Import the express module
const express = require('express');

// Create an instance of an Express application
const app = express();

// Define the port number
const PORT = process.env.PORT || 3000;

// Serve static files from the 'dist' directory
app.use(express.static('build'));

// Define a simple route
app.get('/', (req, res) => {
  res.send('Hello, World!');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});