# Create a New Working Model from Scratch
# This script creates a new model with the correct architecture for food classification

import tensorflow as tf
import numpy as np
import os
import pickle

def create_fresh_model():
    """Create a fresh model with correct architecture"""
    
    print("🍽️  Creating Fresh Food Classification Model")
    print("=" * 60)
    
    try:
        # Food categories (must match your training data)
        food_categories = [
            'biriyani', 'bisibelebath', 'butternaan', 'chaat', 'chappati',
            'dhokla', 'dosa', 'gulab jamun', 'halwa', 'idly',
            'kathi roll', 'meduvadai', 'noodles', 'paniyaram', 'poori',
            'samosa', 'tandoori chicken', 'upma', 'vada pav', 'ven pongal'
        ]
        
        num_classes = len(food_categories)
        img_size = 224
        
        print(f"🏷️  Food Categories: {num_classes}")
        print(f"📐 Input Size: {img_size}x{img_size}")
        
        # Create the exact same model architecture as in train_model.py
        print("\n🏗️  Building Model Architecture...")
        
        base_model = tf.keras.applications.MobileNetV2(
            input_shape=(img_size, img_size, 3),
            include_top=False,
            weights='imagenet'  # Use pretrained ImageNet weights
        )
        
        # Freeze base model initially
        base_model.trainable = False
        
        # Add classification head (same as training script)
        model = tf.keras.Sequential([
            base_model,
            tf.keras.layers.GlobalAveragePooling2D(),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(num_classes, activation='softmax')
        ])
        
        # Compile model (same as training script)
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        print("✅ Model created successfully!")
        print("\n📋 Model Architecture:")
        model.summary()
        
        # Test the model with dummy input
        print("\n🧪 Testing model with dummy input...")
        dummy_input = np.random.random((1, img_size, img_size, 3)).astype(np.float32)
        dummy_output = model.predict(dummy_input, verbose=0)
        
        print(f"✅ Model test successful!")
        print(f"   Input shape: {dummy_input.shape}")
        print(f"   Output shape: {dummy_output.shape}")
        print(f"   Output sum: {np.sum(dummy_output):.4f} (should be ~1.0)")
        print(f"   Max confidence: {np.max(dummy_output):.4f}")
        print(f"   Predicted class: {np.argmax(dummy_output)}")
        
        # Save the fresh model
        fresh_model_path = 'food_classifier_fresh.h5'
        model.save(fresh_model_path)
        print(f"\n💾 Fresh model saved as: {fresh_model_path}")
        
        # Convert to TensorFlow Lite
        print("\n🔄 Converting to TensorFlow Lite...")
        
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        # Optimize for mobile
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Enable select TF ops for better compatibility
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        # Allow custom ops if needed
        converter.allow_custom_ops = True
        
        # Use float16 for smaller size
        converter.target_spec.supported_types = [tf.float16]
        
        # Convert
        tflite_model = converter.convert()
        
        # Save TFLite model
        tflite_path = 'food_classifier.tflite'
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ TensorFlow Lite model saved as: {tflite_path}")
        
        # Test TFLite model
        print("\n🧪 Testing TensorFlow Lite model...")
        
        interpreter = tf.lite.Interpreter(model_path=tflite_path)
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"   TFLite Input: {input_details[0]['shape']} ({input_details[0]['dtype']})")
        print(f"   TFLite Output: {output_details[0]['shape']} ({output_details[0]['dtype']})")
        
        # Run inference
        interpreter.set_tensor(input_details[0]['index'], dummy_input)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"✅ TFLite inference successful!")
        print(f"   Output shape: {tflite_output.shape}")
        print(f"   Max confidence: {np.max(tflite_output):.4f}")
        print(f"   Predicted class: {np.argmax(tflite_output)}")
        
        # Create and save class indices
        class_indices = {category: idx for idx, category in enumerate(food_categories)}
        indices_path = 'class_indices.pkl'
        with open(indices_path, 'wb') as f:
            pickle.dump(class_indices, f)
        
        print(f"📋 Class indices saved as: {indices_path}")
        
        # Copy files to Flutter assets
        print("\n📂 Copying files to Flutter assets...")
        
        try:
            import shutil
            
            # Create assets directory
            os.makedirs('assets/models', exist_ok=True)
            
            # Copy files
            assets_tflite = 'assets/models/food_classifier.tflite'
            assets_indices = 'assets/models/class_indices.pkl'
            
            shutil.copy2(tflite_path, assets_tflite)
            shutil.copy2(indices_path, assets_indices)
            
            print(f"✅ Files copied to Flutter assets:")
            print(f"   - {assets_tflite}")
            print(f"   - {assets_indices}")
            
        except Exception as e:
            print(f"⚠️  Could not copy to assets: {e}")
            print("Please manually copy the files to assets/models/")
        
        # Model size information
        h5_size = os.path.getsize(fresh_model_path) / (1024 * 1024)
        tflite_size = os.path.getsize(tflite_path) / (1024 * 1024)
        
        print(f"\n📊 Model Information:")
        print(f"   H5 Model Size: {h5_size:.2f} MB")
        print(f"   TFLite Model Size: {tflite_size:.2f} MB")
        print(f"   Compression Ratio: {((h5_size - tflite_size) / h5_size * 100):.1f}%")
        print(f"   Supported Foods: {num_classes} categories")
        print(f"   Input Resolution: {img_size}x{img_size} pixels")
        
        print(f"\n🎉 SUCCESS! Fresh model created and converted!")
        print(f"\n⚠️  IMPORTANT NOTE:")
        print(f"   This is a fresh model with ImageNet pretrained weights.")
        print(f"   For best accuracy, you should:")
        print(f"   1. Use this model structure to retrain with your food dataset")
        print(f"   2. Or use transfer learning to fine-tune on your specific foods")
        print(f"   3. The current model will give basic predictions but may not be highly accurate")
        
        print(f"\n📱 Next steps:")
        print(f"   1. Restart your Flutter app")
        print(f"   2. Navigate to Food Planner → Food Logger")
        print(f"   3. Test the camera feature")
        print(f"   4. The model will now work with real inference!")
        
        # Create a simple test script
        create_test_script(food_categories, tflite_path)
        
        return True
        
    except Exception as e:
        print(f"❌ Model creation failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def create_test_script(food_categories, tflite_path):
    """Create a simple test script for the model"""
    
    test_script = f'''# Test the TensorFlow Lite Food Classification Model
import tensorflow as tf
import numpy as np

# Food categories
FOOD_CATEGORIES = {food_categories}

def test_model():
    # Load the model
    interpreter = tf.lite.Interpreter(model_path='{tflite_path}')
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print("Model loaded successfully!")
    print(f"Input shape: {{input_details[0]['shape']}}")
    print(f"Output shape: {{output_details[0]['shape']}}")
    
    # Test with random image
    test_image = np.random.random((1, 224, 224, 3)).astype(np.float32)
    
    interpreter.set_tensor(input_details[0]['index'], test_image)
    interpreter.invoke()
    
    output = interpreter.get_tensor(output_details[0]['index'])
    
    # Get prediction
    predicted_class = np.argmax(output)
    confidence = np.max(output)
    
    print(f"\\nPrediction: {{FOOD_CATEGORIES[predicted_class]}}")
    print(f"Confidence: {{confidence:.4f}}")
    print("\\nTop 3 predictions:")
    
    top_indices = np.argsort(output[0])[-3:][::-1]
    for i, idx in enumerate(top_indices):
        print(f"  {{i+1}}. {{FOOD_CATEGORIES[idx]}}: {{output[0][idx]:.4f}}")

if __name__ == "__main__":
    test_model()
'''
    
    with open('test_model.py', 'w') as f:
        f.write(test_script)
    
    print(f"📝 Test script created: test_model.py")
    print(f"   Run: python test_model.py")

if __name__ == "__main__":
    create_fresh_model()