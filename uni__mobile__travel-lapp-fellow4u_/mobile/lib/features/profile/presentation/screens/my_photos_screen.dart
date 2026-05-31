import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';

class MyPhotosScreen extends StatelessWidget {
  const MyPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final photos = profileProvider.profile?.photos ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Photos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF00CEA6)),
            onPressed: () => _showAddPhotoDialog(context),
          ),
        ],
      ),
      body: photos.isEmpty
          ? const Center(child: Text('No photos yet', style: TextStyle(color: Colors.grey)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullImage(context, photos[index].imageUrl),
                  child: Hero(
                    tag: 'photo_${photos[index].id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(photos[index].imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddPhotoDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Photo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter image URL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                final token = context.read<AuthProvider>().token;
                if (token != null) {
                  final success = await context.read<ProfileProvider>().addPhoto(url, token);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo added successfully')),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00CEA6)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Hero(
              tag: 'photo_full', // simplified for demo
              child: InteractiveViewer(
                child: Image.network(url),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
