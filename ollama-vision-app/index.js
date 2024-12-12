// app.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const ollama = require('ollama');

const app = express();
const port = 3000;

// Set up multer for handling file uploads
const upload = multer({ dest: 'uploads/' });

// Serve static files from the public directory
app.use(express.static('public'));

// Handle the image upload and analysis
app.post('/analyze', upload.single('image'), async (req, res) => {
  try {
    const imagePath = path.resolve(__dirname, req.file.path);

    const response = await ollama.chat({
      model: 'llama3.2-vision',
      messages: [{
        role: 'user',
        content: 'What is in this image?',
        images: [imagePath]
      }]
    });

    res.json({ result: response });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'An error occurred.' });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

// public/script.js
document.getElementById('imageForm').addEventListener('submit', async (e) => {
  e.preventDefault();

  const formData = new FormData();
  const imageFile = document.getElementById('imageUpload').files[0];
  formData.append('image', imageFile);

  try {
    const response = await fetch('/analyze', {
      method: 'POST',
      body: formData
    });

    const data = await response.json();

    // Display the image
    const uploadedImage = document.getElementById('uploadedImage');
    uploadedImage.src = URL.createObjectURL(imageFile);

    // Display the analysis result
    const analysisResult = document.getElementById('analysisResult');
    analysisResult.textContent = data.result;
    analysisResult.classList.add('alert-success');

    document.getElementById('resultContainer').style.display = 'block';

  } catch (error) {
    console.error(error);
    alert('An error occurred while analyzing the image.');
  }
});