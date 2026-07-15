import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/profile_model.dart';
import '../provider/profile_provider.dart';

class AddJourneyScreen extends StatefulWidget {
  const AddJourneyScreen({super.key});

  @override
  State<AddJourneyScreen> createState() => _AddJourneyScreenState();
}

class _AddJourneyScreenState extends State<AddJourneyScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final List<UserPhoto> _selectedPhotos = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onDone() async {
    final title = _nameController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a journey name')),
      );
      return;
    }

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await context.read<ProfileProvider>().createJourney(
        title: title,
        locationName: location.isEmpty ? 'Unknown' : location,
        description: '', // Optional or default empty
        photoIds: _selectedPhotos.map((p) => p.id).toList(),
        token: token,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journey created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating journey: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSelectPhotosSheet() {
    final profileProvider = context.read<ProfileProvider>();
    final allPhotos = profileProvider.allPhotos;

    if (allPhotos.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Photos Available'),
          content: const Text('You need to add some photos to your gallery first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Photos',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Color(0xFF00CEA6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: allPhotos.length,
                        itemBuilder: (context, index) {
                          final photo = allPhotos[index];
                          final isSelected = _selectedPhotos.any((p) => p.id == photo.id);

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                if (isSelected) {
                                  _selectedPhotos.removeWhere((p) => p.id == photo.id);
                                } else {
                                  _selectedPhotos.add(photo);
                                }
                              });
                              // Triggers UI update in the main screen as well
                              setState(() {});
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      photo.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? const Color(0xFF00CEA6) : Colors.black26,
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
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
          'Add Journey',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isSaving)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Journey's Name",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00CEA6)),
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              'Location',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Location of Journey',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00CEA6)),
                ),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _showSelectPhotosSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00CEA6),
                    width: 1.5,
                    style: BorderStyle.solid, // solid matches clean UI
                  ),
                  color: const Color(0xFF00CEA6).withOpacity(0.02),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Color(0xFF00CEA6)),
                    SizedBox(width: 8),
                    Text(
                      'Upload Photos',
                      style: TextStyle(
                        color: Color(0xFF00CEA6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedPhotos.isNotEmpty) ...[
              const Text(
                'Selected Photos',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = _selectedPhotos[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(photo.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPhotos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
