# Test the TensorFlow Lite Food Classification Model
import tensorflow as tf
import numpy as np

# Food categories
FOOD_CATEGORIES = ['biriyani', 'bisibelebath', 'butternaan', 'chaat', 'chappati', 'dhokla', 'dosa', 'gulab jamun', 'halwa', 'idly', 'kathi roll', 'meduvadai', 'noodles', 'paniyaram', 'poori', 'samosa', 'tandoori chicken', 'upma', 'vada pav', 'ven pongal']

def test_model():
    # Load the model
    interpreter = tf.lite.Interpreter(model_path='food_classifier.tflite')
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print("Model loaded successfully!")
    print(f"Input shape: {input_details[0]['shape']}")
    print(f"Output shape: {output_details[0]['shape']}")
    
    # Test with random image
    test_image = np.random.random((1, 224, 224, 3)).astype(np.float32)
    
    interpreter.set_tensor(input_details[0]['index'], test_image)
    interpreter.invoke()
    
    output = interpreter.get_tensor(output_details[0]['index'])
    
    # Get prediction
    predicted_class = np.argmax(output)
    confidence = np.max(output)
    
    print(f"\nPrediction: {FOOD_CATEGORIES[predicted_class]}")
    print(f"Confidence: {confidence:.4f}")
    print("\nTop 3 predictions:")
    
    top_indices = np.argsort(output[0])[-3:][::-1]
    for i, idx in enumerate(top_indices):
        print(f"  {i+1}. {FOOD_CATEGORIES[idx]}: {output[0][idx]:.4f}")

if __name__ == "__main__":
    test_model()
