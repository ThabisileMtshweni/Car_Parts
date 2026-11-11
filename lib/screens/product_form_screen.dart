
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../store.dart';

class ProductFormScreen extends StatefulWidget {
  final int? partId;

  const ProductFormScreen({
    super.key,
    this.partId,
  });

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditing => widget.partId != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final part = Shop.instance.byId(widget.partId!);

      if (part != null) {
        _nameController.text = part.name;
        _categoryController.text = part.category;
        _descriptionController.text = part.description;
        _vehicleController.text = part.vehicle;
        _priceController.text = part.price.toStringAsFixed(2);
        _stockController.text = part.stock.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _vehicleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // SAVE NEW PRODUCT OR UPDATE EXISTING PRODUCT
  void _saveProduct() {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    final stock = int.tryParse(
      _stockController.text.trim(),
    );

    if (price == null ||
        !price.isFinite ||
        price <= 0 ||
        stock == null ||
        stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check price and stock'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      Shop.instance.savePart(
        id: widget.partId,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        vehicle: _vehicleController.text.trim(),
        price: price,
        stock: stock,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // REUSABLE TEXT FIELD
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
                (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit Spare Part'
              : 'Add Spare Part',
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.car_repair,
                  size: 70,
                  color: Colors.deepOrange,
                ),

                const SizedBox(height: 15),

                Text(
                  _isEditing
                      ? 'Update Product Details'
                      : 'Register New Spare Part',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // PART NAME
                _buildField(
                  controller: _nameController,
                  label: 'Part Name',
                  hint: 'e.g. Brake Pads',
                  icon: Icons.build,
                ),

                // CATEGORY
                _buildField(
                  controller: _categoryController,
                  label: 'Category',
                  hint: 'e.g. Brakes',
                  icon: Icons.category,
                ),

                // DESCRIPTION
                _buildField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe the spare part',
                  icon: Icons.description,
                  maxLines: 3,
                ),

                // VEHICLE COMPATIBILITY
                _buildField(
                  controller: _vehicleController,
                  label: 'Compatible Vehicle',
                  hint: 'e.g. Toyota Corolla',
                  icon: Icons.directions_car,
                ),

                // PRICE
                _buildField(
                  controller: _priceController,
                  label: 'Price (R)',
                  hint: 'e.g. 350.00',
                  icon: Icons.payments,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final price = double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (price == null ||
                        !price.isFinite ||
                        price <= 0) {
                      return 'Enter a valid positive price';
                    }

                    return null;
                  },
                ),

                // STOCK
                _buildField(
                  controller: _stockController,
                  label: 'Stock Quantity',
                  hint: 'e.g. 15',
                  icon: Icons.inventory_2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    final stock = int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (stock == null || stock < 0) {
                      return 'Enter a valid stock quantity';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // SAVE BUTTON
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed:
                    _isSaving ? null : _saveProduct,
                    icon: const Icon(Icons.save),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : _isEditing
                          ? 'Update Product'
                          : 'Save Product',
                      style: const TextStyle(fontSize: 17),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
