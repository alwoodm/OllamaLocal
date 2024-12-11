const express = require('express');
const ollama = require('ollama');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 3000;

// Set up multer for file upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/')
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname))
  }
});
const upload = multer({ storage: storage });

// Serve static files
app.use(express.static('public'));
app.use('/uploads', express.static('uploads'));

// Main route
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/views/index.html');
});

// Image analysis route
app.post('/analyze', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    const response = await ollama.chat({
      model: 'llama3.2-vision',
      messages: [{
        content: 'What is in this image?',
        images: [req.file.path]
      }]
    });

    res.json({ 
      description: response.message.content,
      imagePath: req.file.path 
    });
  } catch (error) {
    console.error('Error analyzing image:', error);
    res.status(500).json({ error: 'Failed to analyze image' });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
