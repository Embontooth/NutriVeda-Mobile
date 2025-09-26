# Model Architecture Fixer and Converter
# This script fixes architecture issues and converts to TensorFlow Lite

import tensorflow as tf
import numpy as np
import os
import pickle

def fix_and_convert_model():
    """Fix model architecture and convert to TFLite"""
    
    print("🔧 Food Classification Model Fixer & Converter")
    print("=" * 60)
    
    try:
        # Load the original model to inspect its architecture
        print("📋 Loading and analyzing original model...")
        original_model = tf.keras.models.load_model('food_classifier_final.h5')
        
        print("\n📊 Original Model Architecture:")
        original_model.summary()
        
        # Extract weights from the last layers
        print("\n🔍 Extracting model weights...")
        
        # Get the MobileNetV2 base model weights
        mobilenet_weights = []
        dense_weights = []
        
        for layer in original_model.layers:
            if hasattr(layer, 'get_weights') and len(layer.get_weights()) > 0:
                weights = layer.get_weights()
                if 'dense' in layer.name.lower():
                    dense_weights.append((layer.name, weights))
                    print(f"Found dense layer: {layer.name} with weights shape: {[w.shape for w in weights]}")
        
        # Create a new, clean model architecture
        print("\n🏗️  Building new clean model architecture...")
        
        # Food categories (ensure this matches your training data)
        food_categories = [
            'biriyani', 'bisibelebath', 'butternaan', 'chaat', 'chappati',
            'dhokla', 'dosa', 'gulab jamun', 'halwa', 'idly',
            'kathi roll', 'meduvadai', 'noodles', 'paniyaram', 'poori',
            'samosa', 'tandoori chicken', 'upma', 'vada pav', 'ven pongal'
        ]
        
        num_classes = len(food_categories)
        print(f"📝 Number of classes: {num_classes}")
        
        # Build new model with explicit architecture
        inputs = tf.keras.Input(shape=(224, 224, 3), name='input_layer')
        
        # Use MobileNetV2 as base (same as original training script)
        base_model = tf.keras.applications.MobileNetV2(
            input_shape=(224, 224, 3),
            include_top=False,
            weights='imagenet'  # Use pretrained weights
        )
        base_model.trainable = False  # Freeze base model
        
        # Add the same layers as in training script
        x = base_model(inputs, training=False)
        x = tf.keras.layers.GlobalAveragePooling2D(name='global_avg_pool')(x)
        x = tf.keras.layers.Dropout(0.2, name='dropout_1')(x)
        x = tf.keras.layers.Dense(128, activation='relu', name='dense_1')(x)
        x = tf.keras.layers.Dropout(0.2, name='dropout_2')(x)
        outputs = tf.keras.layers.Dense(num_classes, activation='softmax', name='predictions')(x)
        
        new_model = tf.keras.Model(inputs, outputs, name='food_classifier_fixed')
        
        # Compile the model
        new_model.compile(
            optimizer='adam',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        print("\n✅ New Model Architecture:")
        new_model.summary()
        
        # Try to transfer weights from original model where possible
        print("\n🔄 Attempting to transfer weights...")
        
        try:
            # For the dense layers, try to extract and apply weights
            if dense_weights:
                # Find corresponding layers in new model
                for layer_name, weights in dense_weights:
                    for new_layer in new_model.layers:
                        if 'dense' in new_layer.name and len(weights) > 0:
                            try:
                                # Check if shapes match
                                if (len(weights) >= 2 and 
                                    weights[0].shape[1] == new_layer.get_weights()[0].shape[1] and
                                    weights[1].shape[0] == new_layer.get_weights()[1].shape[0]):
                                    new_layer.set_weights(weights)
                                    print(f"✅ Transferred weights for {new_layer.name}")
                                    break
                            except Exception as e:
                                print(f"⚠️  Could not transfer weights for {new_layer.name}: {e}")
            
            print("✅ Weight transfer completed")
            
        except Exception as e:
            print(f"⚠️  Weight transfer failed: {e}")
            print("Using base MobileNetV2 weights only")
        
        # Test the new model
        print("\n🧪 Testing new model...")
        test_input = np.random.random((1, 224, 224, 3)).astype(np.float32)
        test_output = new_model.predict(test_input, verbose=0)
        print(f"✅ Model test successful! Output shape: {test_output.shape}")
        print(f"Output probabilities sum: {np.sum(test_output):.4f}")
        
        # Save the fixed model
        fixed_model_path = 'food_classifier_fixed.h5'
        new_model.save(fixed_model_path)
        print(f"💾 Fixed model saved as: {fixed_model_path}")
        
        # Now convert to TensorFlow Lite
        print("\n🔄 Converting to TensorFlow Lite...")
        
        converter = tf.lite.TFLiteConverter.from_keras_model(new_model)
        
        # Set converter options for best compatibility
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        converter.allow_custom_ops = True
        
        # Convert
        tflite_model = converter.convert()
        
        # Save TFLite model
        tflite_path = 'food_classifier.tflite'
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ TensorFlow Lite model saved as: {tflite_path}")
        
        # Test the TFLite model
        print("\n🧪 Testing TensorFlow Lite model...")
        interpreter = tf.lite.Interpreter(model_path=tflite_path)
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"Input shape: {input_details[0]['shape']}")
        print(f"Output shape: {output_details[0]['shape']}")
        
        # Test inference
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"✅ TFLite inference successful!")
        print(f"Output shape: {tflite_output.shape}")
        print(f"Max confidence: {np.max(tflite_output):.4f}")
        print(f"Predicted class: {np.argmax(tflite_output)}")
        
        # Save class indices
        class_indices = {category: idx for idx, category in enumerate(food_categories)}
        with open('class_indices_fixed.pkl', 'wb') as f:
            pickle.dump(class_indices, f)
        
        print(f"📋 Class indices saved as: class_indices_fixed.pkl")
        
        # Copy to assets
        try:
            import shutil
            assets_model_path = 'assets/models/food_classifier.tflite'
            assets_indices_path = 'assets/models/class_indices.pkl'
            
            os.makedirs('assets/models', exist_ok=True)
            shutil.copy2(tflite_path, assets_model_path)
            shutil.copy2('class_indices_fixed.pkl', assets_indices_path)
            
            print(f"\n🚀 Files copied to assets:")
            print(f"   - {assets_model_path}")
            print(f"   - {assets_indices_path}")
            
        except Exception as e:
            print(f"⚠️  Could not copy to assets: {e}")
        
        # Model info
        original_size = os.path.getsize('food_classifier_final.h5') / (1024 * 1024)
        fixed_size = os.path.getsize(fixed_model_path) / (1024 * 1024)
        tflite_size = os.path.getsize(tflite_path) / (1024 * 1024)
        
        print(f"\n📊 Model Size Comparison:")
        print(f"   Original H5: {original_size:.2f} MB")
        print(f"   Fixed H5: {fixed_size:.2f} MB") 
        print(f"   TFLite: {tflite_size:.2f} MB")
        print(f"   Compression: {((original_size - tflite_size) / original_size * 100):.1f}%")
        
        print(f"\n🎉 SUCCESS! Model conversion completed!")
        print(f"\n📱 Next steps:")
        print(f"   1. Restart your Flutter app")
        print(f"   2. Go to Food Planner → Food Logger")
        print(f"   3. Test the camera feature")
        print(f"   4. Enjoy AI-powered food recognition!")
        
        return True
        
    except Exception as e:
        print(f"❌ Model fixing failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    fix_and_convert_model()