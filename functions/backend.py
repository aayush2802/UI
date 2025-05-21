import sys
import json
import joblib
import numpy as np

# Load the pre-trained KNN model
model = joblib.load('knn_model.pkl')

def handler():
    try:
        # Read JSON input from Firebase Functions (passed as command-line argument)
        data = json.loads(sys.stdin.read())

        # Extract feature values
        carbon = data.get('Carbon')
        organic_matter = data.get('Organic Matter')
        phosphorous = data.get('Phosphorous')
        calcium = data.get('Calcium')
        magnesium = data.get('Magnesium')
        potassium = data.get('Potassium')

        # Check if any feature is missing
        if None in [carbon, organic_matter, phosphorous, calcium, magnesium, potassium]:
            print(json.dumps({'error': 'Missing or invalid input values'}))
            return

        # Prepare features for prediction
        features = np.array([[carbon, organic_matter, phosphorous, calcium, magnesium, potassium]])

        # Predict using KNN model
        predicted_crop = model.predict(features)[0]
        crop_name = "Soybean" if predicted_crop == 1 else "Paddy"

        # Return prediction as JSON
        print(json.dumps({'predicted_crop': crop_name}))

    except Exception as e:
        print(json.dumps({'error': str(e)}))

if __name__ == "__main__":
    handler()
