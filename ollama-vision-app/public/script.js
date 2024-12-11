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
