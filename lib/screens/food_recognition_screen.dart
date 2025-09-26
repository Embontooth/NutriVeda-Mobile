import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/food_classification_service.dart';
import '../theme/app_theme.dart';

class FoodRecognitionScreen extends StatefulWidget {
  const FoodRecognitionScreen({super.key});

  @override
  State<FoodRecognitionScreen> createState() => _FoodRecognitionScreenState();
}

class _FoodRecognitionScreenState extends State<FoodRecognitionScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  FoodClassificationResult? _classificationResult;
  bool isClassifying = false;
  bool isClassificationServiceReady = false;
  String selectedMealType = 'Breakfast';
  
  final List<String> mealTypes = ['Breakfast', 'Mid-Morning', 'Lunch', 'Evening', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _initializeFoodClassification();
  }

  Future<void> _initializeFoodClassification() async {
    final initialized = await FoodClassificationService.initialize();
    setState(() {
      isClassificationServiceReady = initialized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Food Recognition'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),
            
            // Meal Type Selector
            _buildMealTypeSelector(),
            const SizedBox(height: 24),
            
            // Camera/Image Section
            _buildImageSection(),
            const SizedBox(height: 24),
            
            // Classification Results
            if (_classificationResult != null) ...[
              _buildClassificationResults(),
              const SizedBox(height: 24),
            ],
            
            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 24),
            
            // Setup Guide
            if (!isClassificationServiceReady) ...[
              _buildSetupGuide(),
              const SizedBox(height: 24),
            ],
            
            // Supported Foods
            _buildSupportedFoodsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'AI-Powered Food Recognition',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isClassificationServiceReady 
                  ? 'Take a photo to identify food automatically with our trained AI model'
                  : 'Demo mode active - Experience realistic AI food recognition simulation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isClassificationServiceReady 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isClassificationServiceReady ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isClassificationServiceReady ? Icons.check_circle : Icons.info,
                    size: 16,
                    color: isClassificationServiceReady ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isClassificationServiceReady ? 'Real AI Active' : 'Demo Mode',
                    style: TextStyle(
                      color: isClassificationServiceReady ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Meal Type:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mealTypes.map((type) => ChoiceChip(
            label: Text(type),
            selected: selectedMealType == type,
            onSelected: (selected) {
              if (selected) {
                setState(() => selectedMealType = type);
              }
            },
            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
            checkmarkColor: AppTheme.primaryColor,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_camera, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Food Image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Image Display
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a photo or select from gallery',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Analysis Status
            if (isClassifying) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analyzing food image...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI is processing your image',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Camera Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isClassifying ? null : () => _pickImageAndClassify(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isClassifying ? null : () => _pickImageAndClassify(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear Image'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationResults() {
    if (_classificationResult == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recognition Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Primary Result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Primary Match',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _classificationResult!.primaryPrediction.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(_classificationResult!.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // All Predictions
            Text(
              'All Predictions:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...(_classificationResult!.topPredictions.asMap().entries.map((entry) {
              final index = entry.key;
              final prediction = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index == 0 
                      ? AppTheme.primaryColor.withOpacity(0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == 0 
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: index == 0 ? AppTheme.primaryColor : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prediction.foodName.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: index == 0 ? AppTheme.primaryColor : Colors.black87,
                            ),
                          ),
                          Text(
                            '${(prediction.confidence * 100).toStringAsFixed(1)}% confidence',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show nutrition button for primary result
                    if (index == 0) ...[
                      IconButton(
                        onPressed: () => _showNutritionInfo(prediction.foodName),
                        icon: Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                        ),
                        tooltip: 'Nutrition Info',
                      ),
                    ],
                  ],
                ),
              );
            }).toList()),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _logFood(_classificationResult!.primaryPrediction),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Log This Food'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _showNutritionInfo(_classificationResult!.primaryPrediction),
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Nutrition'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _classificationResult != null ? _retakePhoto : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showSetupInstructions,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Help'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupGuide() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Setup Guide',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Currently running in demo mode with realistic AI simulation.',
              style: TextStyle(color: Colors.orange[800]),
            ),
            const SizedBox(height: 8),
            Text(
              'To enable real TensorFlow Lite inference:\n'
              '• Uncomment ML code in food_classification_service.dart\n'
              '• Add tflite dependency in pubspec.yaml\n'
              '• Restart the app',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showSetupInstructions,
              icon: const Icon(Icons.code),
              label: const Text('View Full Guide'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedFoodsSection() {
    final supportedFoods = FoodClassificationService.supportedFoods;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Supported Foods (${supportedFoods.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Our AI can recognize these Indian foods:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: supportedFoods.map((food) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  food.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageAndClassify(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _classificationResult = null;
          isClassifying = true;
        });

        // Classify the food
        final result = await FoodClassificationService.classifyFood(_selectedImage!);
        
        setState(() {
          isClassifying = false;
          _classificationResult = result;
        });

        if (result != null) {
          _showResultSnackbar(result.primaryPrediction, result.confidence);
        }
      }
    } catch (e) {
      setState(() {
        isClassifying = false;
      });
      
      _showErrorSnackbar('Failed to process image: $e');
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _classificationResult = null;
    });
  }

  void _retakePhoto() {
    _clearImage();
  }

  void _logFood(String foodName) {
    _showQuantityDialog(foodName);
  }

  void _showQuantityDialog(String foodName) {
    final nutritionInfo = FoodClassificationService.getNutritionInfo(foodName);
    final quantityController = TextEditingController(text: '1.0');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log $foodName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal: $selectedMealType', 
                         style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Food: ${foodName.toUpperCase()}', 
                         style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity (portions)',
                  border: OutlineInputBorder(),
                  helperText: 'Nutritional values are per 100g',
                ),
              ),
              const SizedBox(height: 16),
              if (nutritionInfo != null) ...[
                const Text('Nutritional Info (per 100g):', 
                     style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildNutritionRow('Calories', '${nutritionInfo['calories']}'),
                _buildNutritionRow('Protein', '${nutritionInfo['protein']}g'),
                _buildNutritionRow('Carbohydrates', '${nutritionInfo['carbohydrates']}g'),
                _buildNutritionRow('Fat', '${nutritionInfo['fat']}g'),
                _buildNutritionRow('Fiber', '${nutritionInfo['fiber']}g'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 1.0;
              Navigator.pop(context);
              _confirmFoodLogging(foodName, quantity, nutritionInfo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmFoodLogging(String foodName, double quantity, Map<String, dynamic>? nutritionInfo) {
    _showSuccessSnackbar('✅ $foodName logged successfully for $selectedMealType');
    
    // Navigate back to food planner or show success
    Navigator.pop(context, {
      'foodName': foodName,
      'quantity': quantity,
      'mealType': selectedMealType,
      'nutritionInfo': nutritionInfo,
    });
  }

  void _showNutritionInfo(String foodName) {
    final nutritionInfo = FoodClassificationService.getNutritionInfo(foodName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${foodName.toUpperCase()} - Nutrition'),
        content: nutritionInfo != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailedNutritionCard(nutritionInfo),
                ],
              )
            : const Text('Nutrition information not available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (nutritionInfo != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logFood(foodName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log This Food'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedNutritionCard(Map<String, dynamic> nutritionInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Category:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${nutritionInfo['category']}'),
            ],
          ),
          const Divider(height: 20),
          _buildNutritionRow('Calories', '${nutritionInfo['calories']} kcal'),
          _buildNutritionRow('Protein', '${nutritionInfo['protein']} g'),
          _buildNutritionRow('Carbohydrates', '${nutritionInfo['carbohydrates']} g'),
          _buildNutritionRow('Fat', '${nutritionInfo['fat']} g'),
          _buildNutritionRow('Fiber', '${nutritionInfo['fiber']} g'),
          const SizedBox(height: 8),
          Text(
            'Values per 100g serving',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showSetupInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 Setup Guide'),
        content: SingleChildScrollView(
          child: Text(FoodClassificationService.integrationGuide),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResultSnackbar(String foodName, double confidence) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Detected: ${foodName.toUpperCase()} (${(confidence * 100).toStringAsFixed(1)}%)'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}