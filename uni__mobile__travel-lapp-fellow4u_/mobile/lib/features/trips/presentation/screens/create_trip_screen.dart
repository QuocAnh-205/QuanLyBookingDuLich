import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/trip_models.dart';
import '../provider/trips_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _fromTimeController = TextEditingController();
  final _toTimeController = TextEditingController();
  final _feeController = TextEditingController();
  final _languageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  int _travelersCount = 1;
  final List<String> _selectedAttractions = ['Dragon Bridge', 'My Khe Beach'];

  final List<Map<String, String>> _mockAttractions = [
    {
      'name': 'Dragon Bridge',
      'image': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?q=80&w=2127&auto=format&fit=crop',
    },
    {
      'name': 'Cham Museum',
      'image': 'https://images.unsplash.com/photo-1596423735880-5c62b9f36fcc?q=80&w=2070&auto=format&fit=crop',
    },
    {
      'name': 'My Khe Beach',
      'image': 'https://images.unsplash.com/photo-1543781747-d5ab0e5e0cf7?q=80&w=1974&auto=format&fit=crop',
    },
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _feeController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _handleDone() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAttractions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one attraction')),
        );
        return;
      }
      
      final auth = context.read<AuthProvider>();
      
      final newTrip = Trip(
        id: DateTime.now().millisecondsSinceEpoch % 100000, // random id
        travelerId: auth.userId ?? 0,
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        status: TripStatus.bidding,
        totalPrice: double.tryParse(_feeController.text) ?? 0.0,
        depositAmount: 0.0,
        meetingPoint: _locationController.text,
        specialRequests: 'Language: ${_languageController.text}, Attractions: ${_selectedAttractions.join(", ")}',
      );
      
      context.read<TripsProvider>().addLocalTrip(newTrip);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Trip',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildTextField(
              'Where you want to explore',
              _locationController,
              'Danang, Vietnam',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Date',
              _dateController,
              'mm/dd/yy',
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 24),
            const Text(
              'Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextFieldOnly(
                    _fromTimeController,
                    'From',
                    icon: Icons.access_time,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFieldOnly(
                    _toTimeController,
                    'To',
                    icon: Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Number of travelers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCounterButton(Icons.arrow_drop_down, () {
                  if (_travelersCount > 1) setState(() => _travelersCount--);
                }),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('$_travelersCount', style: const TextStyle(fontSize: 16)),
                  ),
                ),
                _buildCounterButton(Icons.arrow_drop_up, () {
                  setState(() => _travelersCount++);
                }),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Fee',
              _feeController,
              'Fee',
              icon: Icons.monetization_on_outlined,
              suffix: const Text('(\$/hour)', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              'Guide\'s Language',
              _languageController,
              'Korean, English',
              icon: Icons.public,
            ),
            const SizedBox(height: 32),
            const Text(
              'Attractions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildAttractionsGrid(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CEA6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('DONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {IconData? icon, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildTextFieldOnly(controller, hint, icon: icon, suffix: suffix),
      ],
    );
  }

  Widget _buildTextFieldOnly(TextEditingController controller, String hint, {IconData? icon, Widget? suffix}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        suffix: suffix,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00CEA6))),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF00CEA6)),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAttractionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _mockAttractions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddNewCard();
        }
        final attraction = _mockAttractions[index - 1];
        return _buildAttractionCard(attraction['name']!, attraction['image']!);
      },
    );
  }

  void _showAddAttractionDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Attraction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Attraction Name')),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _mockAttractions.insert(0, {
                    'name': nameController.text,
                    'image': urlController.text.isNotEmpty 
                        ? urlController.text 
                        : 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=2070&auto=format&fit=crop',
                  });
                  _selectedAttractions.add(nameController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCard() {
    return GestureDetector(
      onTap: _showAddAttractionDialog,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Color(0xFF00CEA6)),
              const SizedBox(height: 8),
              const Text('Add New', style: TextStyle(color: Color(0xFF00CEA6))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttractionCard(String name, String imageUrl) {
    final isSelected = _selectedAttractions.contains(name);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedAttractions.remove(name);
          } else {
            _selectedAttractions.add(name);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00CEA6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
