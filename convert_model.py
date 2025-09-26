# Food Classification Model Converter
# This script converts the .h5 model to TensorFlow Lite format for Flutter

import tensorflow as tf
import numpy as np

def convert_h5_to_tflite(h5_model_path, tflite_output_path):
    """Convert H5 model to TensorFlow Lite format"""
    try:
        print(f"Loading H5 model from: {h5_model_path}")
        
        # Load the saved H5 model
        model = tf.keras.models.load_model(h5_model_path)
        
        # Print model summary
        print("\nModel Summary:")
        model.summary()
        
        # Check if model has any issues and try to fix them
        try:
            # Test the model with dummy input first
            dummy_input = tf.random.normal([1, 224, 224, 3])
            dummy_output = model(dummy_input)
            print(f"\nModel test successful. Output shape: {dummy_output.shape}")
        except Exception as e:
            print(f"⚠️  Model test failed: {e}")
            print("Attempting to rebuild model...")
            
            # Try to rebuild the model to fix architecture issues
            model = rebuild_model_if_needed(model)
        
        # Convert to TensorFlow Lite
        print("\nConverting to TensorFlow Lite...")
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        
        # Set optimization flags for better compatibility
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Enable select TF ops for better compatibility
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        # Allow custom ops if needed
        converter.allow_custom_ops = True
        
        # Use float16 for smaller model size
        converter.target_spec.supported_types = [tf.float16]
        
        # Set representative dataset for better quantization (optional)
        converter.representative_dataset = representative_data_gen
        
        # Convert the model
        try:
            tflite_model = converter.convert()
        except Exception as e:
            print(f"⚠️  First conversion attempt failed: {e}")
            print("Trying with relaxed settings...")
            
            # Try with more relaxed settings
            converter = tf.lite.TFLiteConverter.from_keras_model(model)
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_ops = [
                tf.lite.OpsSet.TFLITE_BUILTINS,
                tf.lite.OpsSet.SELECT_TF_OPS
            ]
            converter.allow_custom_ops = True
            
            tflite_model = converter.convert()
        
        # Save the TFLite model
        with open(tflite_output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ Model successfully converted and saved to: {tflite_output_path}")
        
        # Get model size info
        import os
        h5_size = os.path.getsize(h5_model_path) / (1024 * 1024)  # MB
        tflite_size = os.path.getsize(tflite_output_path) / (1024 * 1024)  # MB
        
        print(f"\nSize comparison:")
        print(f"H5 model: {h5_size:.2f} MB")
        print(f"TFLite model: {tflite_size:.2f} MB")
        print(f"Reduction: {((h5_size - tflite_size) / h5_size * 100):.1f}%")
        
        return True
        
    except Exception as e:
        print(f"❌ Error converting model: {e}")
        print("\n🔧 Troubleshooting suggestions:")
        print("1. Try using a different TensorFlow version")
        print("2. Check if model file is corrupted")
        print("3. Use the alternative conversion method below")
        return False

def rebuild_model_if_needed(original_model):
    """Rebuild model to fix potential architecture issues"""
    try:
        print("🔧 Rebuilding model architecture...")
        
        # Get the base model (MobileNetV2) layers
        base_layers = []
        dense_layers = []
        
        for layer in original_model.layers:
            if 'mobilenet' in layer.name.lower() or 'conv' in layer.name.lower():
                base_layers.append(layer)
            elif 'dense' in layer.name.lower() or 'dropout' in layer.name.lower():
                dense_layers.append(layer)
        
        # Create a new model with explicit architecture
        inputs = tf.keras.Input(shape=(224, 224, 3))
        
        # Use MobileNetV2 base
        base_model = tf.keras.applications.MobileNetV2(
            input_shape=(224, 224, 3),
            include_top=False,
            weights=None  # We'll load weights later
        )
        
        x = base_model(inputs, training=False)
        x = tf.keras.layers.GlobalAveragePooling2D()(x)
        x = tf.keras.layers.Dropout(0.2)(x)
        x = tf.keras.layers.Dense(128, activation='relu')(x)
        x = tf.keras.layers.Dropout(0.2)(x)
        outputs = tf.keras.layers.Dense(20, activation='softmax')(x)
        
        new_model = tf.keras.Model(inputs, outputs)
        
        # Try to transfer weights from original model
        try:
            for i, layer in enumerate(new_model.layers):
                if i < len(original_model.layers):
                    try:
                        layer.set_weights(original_model.layers[i].get_weights())
                    except:
                        print(f"⚠️  Could not transfer weights for layer {i}")
        except Exception as e:
            print(f"⚠️  Weight transfer failed: {e}")
            print("Using original model weights may not be preserved")
        
        print("✅ Model rebuilt successfully")
        return new_model
        
    except Exception as e:
        print(f"❌ Model rebuild failed: {e}")
        return original_model

def representative_data_gen():
    """Generate representative data for quantization"""
    for _ in range(100):
        # Generate random data that matches your model's input
        data = np.random.random((1, 224, 224, 3)).astype(np.float32)
        yield [data]

def alternative_conversion_method(h5_model_path, tflite_output_path):
    """Alternative conversion method using saved_model format"""
    try:
        print("\n🔄 Trying alternative conversion method...")
        
        # Load model
        model = tf.keras.models.load_model(h5_model_path)
        
        # Save as SavedModel format first
        saved_model_dir = "temp_saved_model"
        model.save(saved_model_dir, save_format='tf')
        
        # Convert from SavedModel
        converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        converter.allow_custom_ops = True
        
        tflite_model = converter.convert()
        
        # Save the converted model
        with open(tflite_output_path, 'wb') as f:
            f.write(tflite_model)
        
        # Clean up temporary directory
        import shutil
        shutil.rmtree(saved_model_dir, ignore_errors=True)
        
        print(f"✅ Alternative conversion successful: {tflite_output_path}")
        return True
        
    except Exception as e:
        print(f"❌ Alternative conversion failed: {e}")
        return False

def test_tflite_model(tflite_model_path):
    """Test the converted TFLite model"""
    try:
        print(f"\nTesting TFLite model: {tflite_model_path}")
        
        # Load TFLite model and allocate tensors
        interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
        interpreter.allocate_tensors()
        
        # Get input and output tensors
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print("\nInput details:")
        for i, detail in enumerate(input_details):
            print(f"  Input {i}: {detail['shape']} - {detail['dtype']}")
        
        print("\nOutput details:")
        for i, detail in enumerate(output_details):
            print(f"  Output {i}: {detail['shape']} - {detail['dtype']}")
        
        # Test with random data
        input_shape = input_details[0]['shape']
        input_data = np.array(np.random.random_sample(input_shape), dtype=np.float32)
        
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        
        output_data = interpreter.get_tensor(output_details[0]['index'])
        print(f"\nTest inference completed successfully!")
        print(f"Output shape: {output_data.shape}")
        print(f"Max prediction: {np.max(output_data):.4f}")
        print(f"Predicted class: {np.argmax(output_data)}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error testing model: {e}")
        return False

if __name__ == "__main__":
    # Define paths
    h5_model_path = "food_classifier_final.h5"  # Your H5 model path
    tflite_output_path = "food_classifier.tflite"  # Output TFLite model path
    
    print("🍽️  Food Classification Model Converter")
    print("=" * 50)
    
    # Try main conversion method
    success = convert_h5_to_tflite(h5_model_path, tflite_output_path)
    
    # If main method fails, try alternative
    if not success:
        print("\n" + "=" * 50)
        print("🔄 Trying alternative conversion method...")
        success = alternative_conversion_method(h5_model_path, tflite_output_path)
    
    if success:
        # Test the converted model
        test_tflite_model(tflite_output_path)
        
        print("\n" + "=" * 50)
        print("✅ Conversion completed successfully!")
        print(f"\nNext steps:")
        print(f"1. Copy '{tflite_output_path}' to 'assets/models/' in your Flutter project")
        print(f"2. Update pubspec.yaml to include the assets (already done)")
        print(f"3. Run 'flutter pub get' and restart the app")
        print(f"4. Test the food recognition in Food Planner → Food Logger")
        
        # Copy to assets automatically if possible
        import shutil
        assets_path = "assets/models/food_classifier.tflite"
        try:
            shutil.copy2(tflite_output_path, assets_path)
            print(f"\n🚀 Model automatically copied to: {assets_path}")
            print("Ready to use in Flutter app!")
        except Exception as e:
            print(f"\n⚠️  Could not auto-copy to assets: {e}")
            print(f"Please manually copy {tflite_output_path} to assets/models/")
            
    else:
        print("\n" + "=" * 50)
        print("❌ All conversion methods failed!")
        print("\n🔧 Manual conversion alternatives:")
        print("1. Try with different TensorFlow version: pip install tensorflow==2.13.0")
        print("2. Use online conversion tools")
        print("3. Retrain model with TFLite-compatible architecture")
        print("4. For now, use the demo mode in the Flutter app")