import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Addbucketlistscreen extends StatefulWidget {
  final VoidCallback? onAdd;
  const Addbucketlistscreen({super.key, this.onAdd});

  @override
  State<Addbucketlistscreen> createState() => _AddbucketlistscreenState();
}

class _AddbucketlistscreenState extends State<Addbucketlistscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  bool _isSubmitting = false;
  String? _previewUrl;

  @override
  void dispose() {
    _itemController.dispose();
    _costController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _updatePreview(String value) {
    final trimmed = value.trim();
    final isValid =
        trimmed.isNotEmpty &&
        Uri.tryParse(trimmed)?.hasAbsolutePath == true;
    setState(() {
      _previewUrl = isValid ? trimmed : null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await Dio().post(
        "https://flutterapitest-73108-default-rtdb.firebaseio.com/bucketlist.json",
        data: {
          "item": _itemController.text.trim(),
          "cost": int.parse(_costController.text.trim()),
          "image": _imageController.text.trim(),
        },
      );

      if (mounted) {
        widget.onAdd?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Item added!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add item. Try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validateItem(String? value) {
    if (value == null || value.trim().isEmpty) return "Item name is required";
    return null;
  }

  String? _validateCost(String? value) {
    if (value == null || value.trim().isEmpty) return "Cost is required";
    if (int.tryParse(value.trim()) == null) return "Enter a valid number";
    return null;
  }

  String? _validateImage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (Uri.tryParse(value.trim())?.hasAbsolutePath != true) {
      return "Enter a valid URL";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Bucket List")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _itemController,
                decoration: InputDecoration(
                  labelText: "Item name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: _validateItem,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Cost",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: _validateCost,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: "Image URL (optional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: _validateImage,
                onChanged: _updatePreview,
              ),
              SizedBox(height: 16),
              if (_previewUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _previewUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 40),
                            SizedBox(height: 8),
                            Text("Could not load image"),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text("Add to bucket list"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}