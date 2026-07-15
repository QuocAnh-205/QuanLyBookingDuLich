import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  // Predefined beautiful travel image URLs for mock gallery
  final List<String> _galleryImages = [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=500&q=80',
    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=500&q=80',
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=500&q=80',
    'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=500&q=80',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=500&q=80',
    'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=500&q=80',
    'https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=500&q=80',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=500&q=80',
    'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=500&q=80',
    'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=500&q=80',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500&q=80',
    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=500&q=80',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500&q=80',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=500&q=80',
  ];

  final Set<String> _selectedImages = {};
  bool _isUploading = false;

  // Extra images added by "taking a photo"
  final List<String> _cameraRoll = [
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500&q=80',
    'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=500&q=80',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=500&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=500&q=80',
    'https://images.unsplash.com/photo-1472214222541-d510753a8707?w=500&q=80',
  ];
  int _cameraRollIndex = 0;

  void _onDone() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one photo')),
      );
      return;
    }

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final provider = context.read<ProfileProvider>();
      for (final imageUrl in _selectedImages) {
        await provider.addPhoto(imageUrl, token);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedImages.length} photos added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _takePhoto() {
    final nextPhoto = _cameraRoll[_cameraRollIndex % _cameraRoll.length];
    _cameraRollIndex++;
    
    setState(() {
      // Insert the "taken photo" right after the "Take Photo" button
      _galleryImages.insert(0, nextPhoto);
      // Auto-select the taken photo
      _selectedImages.add(nextPhoto);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo captured and selected!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Photos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00CEA6)),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _onDone,
              child: const Text(
                'DONE',
                style: TextStyle(
                  color: Color(0xFF00CEA6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _galleryImages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: _takePhoto,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00CEA6), width: 1.5),
                  color: const Color(0xFF00CEA6).withOpacity(0.02),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Color(0xFF00CEA6), size: 30),
                    SizedBox(height: 8),
                    Text(
                      'Take Photo',
                      style: TextStyle(
                        color: Color(0xFF00CEA6),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final imageUrl = _galleryImages[index - 1];
          final isSelected = _selectedImages.contains(imageUrl);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedImages.remove(imageUrl);
                } else {
                  _selectedImages.add(imageUrl);
                }
              });
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF00CEA6) : Colors.black26,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
