import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/item_provider.dart';

class ReportItemScreen extends StatefulWidget {
  final String type;

  const ReportItemScreen({super.key, required this.type});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'Electronics';
  DateTime? _selectedDate;
  Uint8List? _imageBytes;
  String? _fileName;
  bool _hasShownError = false;

  static const List<String> _categories = [
    'Electronics',
    'Documents',
    'Clothing',
    'Accessories',
    'Bags',
    'Keys',
    'ID Cards',
    'Books',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ItemProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _isLost => widget.type == 'lost';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemProvider = context.watch<ItemProvider>();

    final errorMessage = itemProvider.errorMessage;
    if (errorMessage != null && !_hasShownError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
      _hasShownError = true;
    }
    if (errorMessage == null && _hasShownError) _hasShownError = false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(_isLost ? 'Report Lost Item' : 'Report Found Item'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeBadge(theme, isDark),
              const SizedBox(height: 20),
              _buildImageSection(theme, isDark),
              const SizedBox(height: 24),
              _buildInputField(
                controller: _titleController,
                label: 'Item Name',
                hint: 'What is the item?',
                icon: Icons.inventory_2_outlined,
                isDark: isDark,
                theme: theme,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter item name' : null,
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(theme, isDark),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _descController,
                label: 'Description',
                hint: 'Describe the item (color, size, etc.)',
                icon: Icons.description_outlined,
                isDark: isDark,
                theme: theme,
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _locationController,
                label: _isLost ? 'Lost Location' : 'Found Location',
                hint: _isLost ? 'Where did you lose it?' : 'Where did you find it?',
                icon: Icons.location_on_outlined,
                isDark: isDark,
                theme: theme,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              _buildDateField(theme, isDark),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _contactController,
                label: 'Contact Number',
                hint: 'Your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
                theme: theme,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter contact number' : null,
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(itemProvider, theme, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(ThemeData theme, bool isDark) {
    final color = _isLost ? const Color(0xFFFF7043) : const Color(0xFF26A69A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(
            _isLost ? Icons.report_problem_rounded : Icons.search_off_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            _isLost
                ? 'Reporting a Lost Item'
                : 'Reporting a Found Item',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2636) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _imageBytes != null
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(10),
            width: _imageBytes != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_imageBytes!, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: theme.colorScheme.primary.withAlpha(150),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to add photo',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optional but recommended',
                    style: TextStyle(
                        color: isDark ? Colors.white24 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(12) : const Color(0xFFE8E9ED),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: _categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(Icons.category_outlined, color: isDark ? Colors.white38 : Colors.black26, size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: isDark ? Colors.white38 : Colors.black26, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF5F6FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? Colors.white.withAlpha(12) : const Color(0xFFE8E9ED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLost ? 'Lost Date' : 'Found Date',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(12) : const Color(0xFFE8E9ED),
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.calendar_today_outlined, color: isDark ? Colors.white38 : Colors.black26, size: 20),
                ),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _selectedDate != null
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white24 : Colors.black26),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ItemProvider itemProvider, ThemeData theme, bool isDark) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: itemProvider.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLost ? const Color(0xFFFF7043) : const Color(0xFF26A69A),
          disabledBackgroundColor: (_isLost ? const Color(0xFFFF7043) : const Color(0xFF26A69A)).withAlpha(100),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: itemProvider.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isLost ? Icons.report_problem_rounded : Icons.search_off_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isLost ? 'Submit Lost Report' : 'Submit Found Report',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    // Request permission before picking
    final hasPermission = await _requestImagePermission(source);
    if (!hasPermission || !mounted) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  Future<bool> _requestImagePermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      permission = Permission.photos;
    }

    var status = await permission.status;

    // If already granted
    if (status.isGranted) return true;

    // If permanently denied, show settings dialog
    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      _showPermissionDeniedDialog();
      return false;
    }

    // Request permission
    status = await permission.request();

    if (status.isGranted) return true;

    // For photos, fallback to storage on older Android
    if (source == ImageSource.gallery && status.isDenied) {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;
    }

    if (!mounted) return false;

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.camera
              ? 'Camera permission is required to take photos'
              : 'Gallery permission is required to select photos'),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.photo_library_outlined, size: 48, color: Color(0xFF1565C0)),
        title: const Text('Permission Required'),
        content: const Text(
          'Camera and gallery permissions are needed to attach photos. Please enable them in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final itemProvider = context.read<ItemProvider>();
    final user = authProvider.user;
    if (user == null) return;

    final id = await itemProvider.createItem(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descController.text.trim(),
      location: _locationController.text.trim(),
      itemDate: _selectedDate,
      contactNumber: _contactController.text.trim(),
      type: widget.type,
      createdBy: user.displayName ?? user.email ?? 'Unknown',
      createdByUid: user.uid,
      imageBytes: _imageBytes,
      fileName: _fileName,
    );

    if (!mounted) return;
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLost ? 'Lost report submitted!' : 'Found report submitted!'),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    }
  }
}
