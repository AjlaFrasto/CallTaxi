import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:calltaxi_mobile_driver/model/brand.dart';
import 'package:calltaxi_mobile_driver/model/search_result.dart';
import 'package:calltaxi_mobile_driver/model/vehicle.dart';
import 'package:calltaxi_mobile_driver/model/vehicle_tier.dart';
import 'package:calltaxi_mobile_driver/providers/brand_provider.dart';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
import 'package:calltaxi_mobile_driver/providers/vehicle_provider.dart';
import 'package:calltaxi_mobile_driver/providers/vehicle_tier_provider.dart';
import 'package:calltaxi_mobile_driver/utils/text_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehicleDetailsScreen extends StatefulWidget {
  Vehicle? vehicle;
  final VoidCallback? onVehicleSaved; // Callback to refresh the list

  VehicleDetailsScreen({super.key, this.vehicle, this.onVehicleSaved});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _seatsController = TextEditingController();

  late VehicleProvider vehicleProvider;
  BrandProvider? brandProvider;
  VehicleTierProvider? vehicleTierProvider;

  List<Brand> _brands = [];
  List<VehicleTier> _vehicleTiers = [];
  bool _isLoadingBrands = true;
  bool _isLoadingTiers = true;
  bool _isLoadingForm = false;
  String? _errorMessage;

  Brand? _selectedBrand;
  VehicleTier? _selectedVehicleTier;
  bool _petFriendly = false;
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _initializeForm();
    _loadDataLazy();
  }

  void _initializeProviders() {
    // Initialize providers immediately instead of using addPostFrameCallback
    vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    brandProvider = Provider.of<BrandProvider>(context, listen: false);
    vehicleTierProvider = Provider.of<VehicleTierProvider>(
      context,
      listen: false,
    );
  }

  void _initializeForm() {
    if (widget.vehicle != null) {
      _nameController.text = widget.vehicle!.name;
      _licensePlateController.text = widget.vehicle!.licensePlate;
      _colorController.text = widget.vehicle!.color;
      _yearController.text = widget.vehicle!.yearOfManufacture.toString();
      _seatsController.text = widget.vehicle!.seatsCount.toString();
      _petFriendly = widget.vehicle!.petFriendly;

      if (widget.vehicle!.picture != null &&
          widget.vehicle!.picture!.isNotEmpty) {
        _selectedImage = base64Decode(widget.vehicle!.picture!);
      }
    }
  }

  Future<void> _loadDataLazy() async {
    print("Starting lazy data loading...");

    // Load brands first
    await _loadBrands();

    // Load vehicle tiers
    await _loadVehicleTiers();

    // Set default selections after both are loaded
    _setDefaultSelections();
  }

  Future<void> _loadBrands() async {
    try {
      print("Loading brands...");
      setState(() {
        _isLoadingBrands = true;
      });

      if (brandProvider == null) {
        print("BrandProvider is null, reinitializing...");
        brandProvider = Provider.of<BrandProvider>(context, listen: false);
      }

      final result = await brandProvider!.get();
      print("Brand API response: ${result.items?.length ?? 0} brands");

      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _brands = result.items!;
          _isLoadingBrands = false;
        });
        print("Brands loaded successfully: ${_brands.length}");
      } else {
        print("No brands returned from API");
        setState(() {
          _brands = [];
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      print("Error loading brands: $e");
      setState(() {
        _brands = [];
        _isLoadingBrands = false;
        _errorMessage = "Failed to load brands: $e";
      });
    }
  }

  Future<void> _loadVehicleTiers() async {
    try {
      print("Loading vehicle tiers...");
      setState(() {
        _isLoadingTiers = true;
      });

      if (vehicleTierProvider == null) {
        print("VehicleTierProvider is null, reinitializing...");
        vehicleTierProvider = Provider.of<VehicleTierProvider>(
          context,
          listen: false,
        );
      }

      final result = await vehicleTierProvider!.get();
      print("Vehicle Tiers API response: ${result.items?.length ?? 0} tiers");

      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _vehicleTiers = result.items!;
          _isLoadingTiers = false;
        });
        print("Vehicle tiers loaded successfully: ${_vehicleTiers.length}");
      } else {
        print("No vehicle tiers returned from API");
        setState(() {
          _vehicleTiers = [];
          _isLoadingTiers = false;
        });
      }
    } catch (e) {
      print("Error loading vehicle tiers: $e");
      setState(() {
        _vehicleTiers = [];
        _isLoadingTiers = false;
        _errorMessage = "Failed to load vehicle tiers: $e";
      });
    }
  }

  void _setDefaultSelections() {
    print("Setting default selections...");
    print("Available brands: ${_brands.length}");
    print("Available tiers: ${_vehicleTiers.length}");

    if (_brands.isNotEmpty) {
      if (widget.vehicle != null) {
        try {
          _selectedBrand = _brands.firstWhere(
            (brand) => brand.id == widget.vehicle!.brandId,
            orElse: () => _brands.first,
          );
          print("Selected brand for editing: ${_selectedBrand?.name}");
        } catch (e) {
          print("Error setting brand: $e");
          _selectedBrand = _brands.first;
        }
      } else {
        _selectedBrand = _brands.first;
        print("Default brand set: ${_selectedBrand?.name}");
      }
    }

    if (_vehicleTiers.isNotEmpty) {
      if (widget.vehicle != null) {
        try {
          _selectedVehicleTier = _vehicleTiers.firstWhere(
            (tier) => tier.id == widget.vehicle!.vehicleTierId,
            orElse: () => _vehicleTiers.first,
          );
          print("Selected tier for editing: ${_selectedVehicleTier?.name}");
        } catch (e) {
          print("Error setting tier: $e");
          _selectedVehicleTier = _vehicleTiers.first;
        }
      } else {
        _selectedVehicleTier = _vehicleTiers.first;
        print("Default tier set: ${_selectedVehicleTier?.name}");
      }
    }

    setState(() {});
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBrand == null || _selectedVehicleTier == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Validation Error"),
          content: Text("Please select brand and vehicle tier"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoadingForm = true;
    });

    try {
      final request = {
        'name': _nameController.text,
        'licensePlate': _licensePlateController.text,
        'color': _colorController.text,
        'yearOfManufacture': int.parse(_yearController.text),
        'seatsCount': int.parse(_seatsController.text),
        'petFriendly': _petFriendly,
        'brandId': _selectedBrand!.id,
        'userId': UserProvider.currentUser!.id,
        'vehicleTierId': _selectedVehicleTier!.id,
        'picture': _selectedImage != null
            ? base64Encode(_selectedImage!)
            : null,
      };

      if (widget.vehicle == null) {
        await vehicleProvider.insert(request);
        // Call the callback to refresh the list
        widget.onVehicleSaved?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Vehicle added successfully")));
      } else {
        await vehicleProvider.update(widget.vehicle!.id, request);
        // Call the callback to refresh the list
        widget.onVehicleSaved?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Vehicle updated successfully")));
      }
    } catch (e) {
      print("Error saving vehicle: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Error saving vehicle: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoadingForm = false;
      });
    }
  }

  Widget _buildBrandDropdown() {
    if (_isLoadingBrands) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text(
              "Loading brands...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_brands.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text("No brands available", style: TextStyle(color: Colors.red)),
      );
    }

    return DropdownButtonFormField<Brand>(
      value: _selectedBrand,
      decoration: customTextFieldDecoration(
        "Brand",
        prefixIcon: Icons.branding_watermark,
      ),
      items: _brands.map((brand) {
        return DropdownMenuItem<Brand>(value: brand, child: Text(brand.name));
      }).toList(),
      onChanged: (Brand? value) {
        print("Brand dropdown changed to: ${value?.name} (ID: ${value?.id})");
        setState(() {
          _selectedBrand = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a brand";
        }
        return null;
      },
    );
  }

  Widget _buildVehicleTierDropdown() {
    if (_isLoadingTiers) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text(
              "Loading vehicle tiers...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_vehicleTiers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text(
          "No vehicle tiers available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<VehicleTier>(
      value: _selectedVehicleTier,
      decoration: customTextFieldDecoration(
        "Vehicle Tier",
        prefixIcon: Icons.star,
      ),
      items: _vehicleTiers.map((tier) {
        return DropdownMenuItem<VehicleTier>(
          value: tier,
          child: Text(tier.name),
        );
      }).toList(),
      onChanged: (VehicleTier? value) {
        print(
          "Vehicle tier dropdown changed to: ${value?.name} (ID: ${value?.id})",
        );
        setState(() {
          _selectedVehicleTier = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a vehicle tier";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? "Add Vehicle" : "Edit Vehicle"),
        actions: [
          if (!_isLoadingForm)
            TextButton(
              onPressed: _saveVehicle,
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message display
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),

              // Vehicle Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Add Photo",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Vehicle Name
              TextFormField(
                controller: _nameController,
                decoration: customTextFieldDecoration(
                  "Model Name",
                  prefixIcon: Icons.directions_car,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter model name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Brand Dropdown
              _buildBrandDropdown(),
              SizedBox(height: 16),

              // License Plate
              TextFormField(
                controller: _licensePlateController,
                decoration: customTextFieldDecoration(
                  "License Plate",
                  prefixIcon: Icons.confirmation_number,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter license plate";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: customTextFieldDecoration(
                  "Color",
                  prefixIcon: Icons.palette,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter color";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Year and Seats Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: customTextFieldDecoration(
                        "Year",
                        prefixIcon: Icons.calendar_today,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter year";
                        }
                        int? year = int.tryParse(value);
                        if (year == null || year < 1900 || year > 2100) {
                          return "Please enter a valid year";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _seatsController,
                      decoration: customTextFieldDecoration(
                        "Seats",
                        prefixIcon: Icons.airline_seat_recline_normal,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter seats count";
                        }
                        int? seats = int.tryParse(value);
                        if (seats == null || seats < 1 || seats > 20) {
                          return "Please enter valid seats count";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Vehicle Tier Dropdown
              _buildVehicleTierDropdown(),
              SizedBox(height: 16),

              // Pet Friendly Toggle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.orange[800]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Pet Friendly",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: _petFriendly,
                      onChanged: (bool value) {
                        setState(() {
                          _petFriendly = value;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoadingForm ? null : _saveVehicle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color(0xFFFF6F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoadingForm
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.vehicle == null
                              ? "Add Vehicle"
                              : "Update Vehicle",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
