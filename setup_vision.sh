#!/bin/bash

# Create project directory
mkdir -p ollama-vision-app
cd ollama-vision-app

# Initialize npm project
npm init -y

# Install required dependencies
npm install express ollama bootstrap multer

# Create project structure
mkdir public views
touch index.js
touch views/index.html
touch public/styles.css
touch public/script.js

# Populate index.js
cat << 'EOF' > index.js
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
EOF

# Populate views/index.html
cat << 'EOF' > views/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ollama Vision Image Analyzer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/styles.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1 class="text-center mb-4">Ollama Vision Image Analyzer</h1>
        <div class="row justify-content-center">
            <div class="col-md-6">
                <form id="imageForm" enctype="multipart/form-data">
                    <div class="mb-3">
                        <input class="form-control" type="file" id="imageUpload" name="image" accept="image/*" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Analyze Image</button>
                </form>
                <div id="resultContainer" class="mt-4 text-center" style="display: none;">
                    <img id="uploadedImage" class="img-fluid mb-3" alt="Uploaded Image">
                    <div id="analysisResult" class="alert"></div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/script.js"></script>
</body>
</html>
EOF

# Populate public/script.js
cat << 'EOF' > public/script.js
document.getElementById('imageForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const resultContainer = document.getElementById('resultContainer');
    const uploadedImage = document.getElementById('uploadedImage');
    const analysisResult = document.getElementById('analysisResult');
    
    try {
        const response = await fetch('/analyze', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        // Display uploaded image
        uploadedImage.src = data.imagePath;
        
        // Show result container
        resultContainer.style.display = 'block';
        
        // Display analysis result
        analysisResult.textContent = data.description;
        analysisResult.className = 'alert alert-success';
    } catch (error) {
        console.error('Error:', error);
        analysisResult.textContent = 'Failed to analyze image';
        analysisResult.className = 'alert alert-danger';
        resultContainer.style.display = 'block';
    }
});
EOF

# Populate public/styles.css
cat << 'EOF' > public/styles.css
body {
    background-color: #f4f4f4;
}

.container {
    max-width: 600px;
}

#uploadedImage {
    max-height: 300px;
    object-fit: contain;
}
EOF

# Create uploads directory
mkdir uploads

# Create README
cat << 'EOF' > README.md
# Ollama Vision Image Analyzer

## Prerequisites
- Node.js
- Ollama installed and running
- Llama3.2-vision model pulled

## Setup
1. Clone this repository
2. Run \`npm install\`
3. Start the server with \`node index.js\`
4. Open http://localhost:3000 in your browser

## Usage
1. Select an image
2. Click "Analyze Image"
3. View the AI's description of the image
EOF

# Print instructions
echo "Ollama Vision App setup complete!"
echo "Next steps:"
echo "1. cd ollama-vision-app"
echo "2. npm install"
echo "3. Make sure Ollama is running and llama3.2-vision model is pulled"
echo "4. node index.js"
echo "5. Open http://localhost:3000 in your browser"
