import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayurvedic Color Palette'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introduction Card
            Card(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.healingGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Icon(
                      Icons.spa,
                      size: 48,
                      color: AppTheme.saffronColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'NutriVeda Color Palette',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.backgroundColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Inspired by traditional Ayurvedic elements:\nhealing herbs, sacred spices, and natural harmony',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.backgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Primary Palette Section
            _buildSectionHeader('Primary Palette'),
            const SizedBox(height: 12),
            
            _buildColorCard(
              'Deep Forest Green',
              AppTheme.primaryColor,
              '#2D5016',
              'Represents nature, healing herbs, and balance',
            ),
            
            _buildColorCard(
              'Primary Variant',
              AppTheme.primaryVariant,
              '#3A5F3A',
              'Alternative green for depth and variation',
            ),
            
            _buildColorCard(
              'Warm Saffron',
              AppTheme.saffronColor,
              '#E4A853',
              'Connects to traditional spices and spiritual practices',
            ),
            
            _buildColorCard(
              'Turmeric Gold',
              AppTheme.turmericColor,
              '#D4AF37',
              'Sacred spice representing healing and purification',
            ),
            
            _buildColorCard(
              'Soft Cream',
              AppTheme.backgroundColor,
              '#F7F5F3',
              'Clean backgrounds and breathing space',
            ),
            
            const SizedBox(height: 24),
            
            // Secondary Palette Section
            _buildSectionHeader('Secondary & Accent Colors'),
            const SizedBox(height: 12),
            
            _buildColorCard(
              'Terracotta Clay',
              AppTheme.terracottaColor,
              '#B5651D',
              'Earthy, grounding, represents traditional pottery',
            ),
            
            _buildColorCard(
              'Clay Variant',
              AppTheme.clayColor,
              '#CD853F',
              'Lighter clay tone for warmth and earthiness',
            ),
            
            _buildColorCard(
              'Soft Sage Green',
              AppTheme.softSageColor,
              '#9CAF88',
              'Gentle, calming, medicinal plants',
            ),
            
            _buildColorCard(
              'Sage Variant',
              AppTheme.sageVariant,
              '#A8B5A0',
              'Alternative sage for subtle variations',
            ),
            
            _buildColorCard(
              'Warm Gold',
              AppTheme.warmGoldColor,
              '#B8860B',
              'For highlights and premium features',
            ),
            
            const SizedBox(height: 24),
            
            // Supporting Neutrals Section
            _buildSectionHeader('Supporting Neutrals'),
            const SizedBox(height: 12),
            
            _buildColorCard(
              'Charcoal Brown',
              AppTheme.textColor,
              '#3E2723',
              'For text and serious content',
            ),
            
            _buildColorCard(
              'Light Sage Gray',
              AppTheme.lightSageGray,
              '#E8EDE8',
              'For subtle backgrounds and dividers',
            ),
            
            _buildColorCard(
              'Surface Cream',
              AppTheme.surfaceColor,
              '#FAF8F5',
              'Card surfaces and elevated elements',
            ),
            
            const SizedBox(height: 24),
            
            // Gradients Section
            _buildSectionHeader('Ayurvedic Gradients'),
            const SizedBox(height: 12),
            
            _buildGradientCard(
              'Healing Gradient',
              AppTheme.healingGradient,
              'Forest Green → Primary Variant',
              'For healing and nature-focused elements',
            ),
            
            _buildGradientCard(
              'Warmth Gradient',
              AppTheme.warmthGradient,
              'Saffron → Turmeric',
              'For warmth and spiritual energy',
            ),
            
            _buildGradientCard(
              'Earth Gradient',
              AppTheme.earthGradient,
              'Terracotta → Clay',
              'For grounding and stability',
            ),
            
            _buildGradientCard(
              'Serenity Gradient',
              AppTheme.serenityGradient,
              'Soft Sage → Sage Variant',
              'For calm and peaceful elements',
            ),
            
            const SizedBox(height: 24),
            
            // Usage Guidelines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usage Guidelines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGuidelineItem(
                      'Primary Actions',
                      'Use Deep Forest Green for main buttons and primary elements',
                    ),
                    _buildGuidelineItem(
                      'Secondary Actions',
                      'Use Terracotta/Clay for secondary buttons and accents',
                    ),
                    _buildGuidelineItem(
                      'Highlights',
                      'Use Saffron/Turmeric for important information and success states',
                    ),
                    _buildGuidelineItem(
                      'Backgrounds',
                      'Use Soft Cream and Surface colors for clean, readable layouts',
                    ),
                    _buildGuidelineItem(
                      'Text',
                      'Use Charcoal Brown for primary text, with opacity variations for hierarchy',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildColorCard(String name, Color color, String hex, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _copyToClipboard(hex),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightSageGray,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hex,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor.withOpacity(0.8),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy,
                color: AppTheme.textColor.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCard(String name, LinearGradient gradient, String colors, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightSageGray,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colors,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
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

  Widget _buildGuidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppTheme.saffronColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String hex) {
    Clipboard.setData(ClipboardData(text: hex));
    // Note: In a real app, you'd show a snackbar here
    // ScaffoldMessenger.of(context).showSnackBar(...)
  }
}