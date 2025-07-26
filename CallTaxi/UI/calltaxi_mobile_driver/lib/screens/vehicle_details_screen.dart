import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

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
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class VehicleDetailsScreen extends StatefulWidget {
  Vehicle? vehicle;
  final VoidCallback? onVehicleSaved; // Callback to refresh the list

  VehicleDetailsScreen({super.key, this.vehicle, this.onVehicleSaved});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {}; // Store form data like brand screen

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
  String? _selectedImageBase64; // Store image as base64 string
  Uint8List? _selectedImage; // Keep for backward compatibility

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
    // Set up initial values like brand screen
    _initialValue = {
      'name': widget.vehicle?.name ?? '',
      'licensePlate': widget.vehicle?.licensePlate ?? '',
      'color': widget.vehicle?.color ?? '',
      'yearOfManufacture': widget.vehicle?.yearOfManufacture?.toString() ?? '',
      'seatsCount': widget.vehicle?.seatsCount?.toString() ?? '',
      'petFriendly': widget.vehicle?.petFriendly ?? false,
      'picture': widget.vehicle?.picture ?? '',
    };

    if (widget.vehicle != null) {
      _petFriendly = widget.vehicle!.petFriendly;

      if (widget.vehicle!.picture != null &&
          widget.vehicle!.picture!.isNotEmpty) {
        _selectedImageBase64 = widget.vehicle!.picture;
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
    try {
      // Show image source options
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _selectImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a Photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _takePhoto();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error showing image picker options: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error selecting image: $e")));
    }
  }

  Future<void> _selectImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _selectedImageBase64 = base64Image;
          _selectedImage = bytes; // Keep for backward compatibility
          _initialValue['picture'] =
              base64Image; // Store in initial value like brand screen
        });
        print("Image selected from gallery: ${image.path}");
      }
    } catch (e) {
      print("Error selecting image from gallery: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error selecting image: $e")));
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _selectedImageBase64 = base64Image;
          _selectedImage = bytes; // Keep for backward compatibility
          _initialValue['picture'] =
              base64Image; // Store in initial value like brand screen
        });
        print("Photo taken: ${image.path}");
      }
    } catch (e) {
      print("Error taking photo: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error taking photo: $e")));
    }
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
      _formKey.currentState?.saveAndValidate();
      if (_formKey.currentState?.validate() ?? false) {
        var request = Map.from(_formKey.currentState?.value ?? {});

        // Send the base64 string directly like the brand screen
        request['picture'] = _initialValue['picture'];

        request['petFriendly'] = _petFriendly;
        request['brandId'] = _selectedBrand!.id;
        request['userId'] = UserProvider.currentUser!.id;
        request['vehicleTierId'] = _selectedVehicleTier!.id;

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Vehicle updated successfully")),
          );
        }
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
        child: FormBuilder(
          key: _formKey,
          initialValue: _initialValue,
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
                    child:
                        _selectedImageBase64 != null &&
                            _selectedImageBase64!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(_selectedImageBase64!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.error,
                                    size: 40,
                                    color: Colors.red,
                                  ),
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
              FormBuilderTextField(
                name: 'name',
                decoration: customTextFieldDecoration(
                  "Model Name",
                  prefixIcon: Icons.directions_car,
                ),
                initialValue: widget.vehicle?.name,
                validator: FormBuilderValidators.required(
                  errorText: "Please enter model name",
                ),
              ),
              SizedBox(height: 16),

              // Brand Dropdown
              _buildBrandDropdown(),
              SizedBox(height: 16),

              // License Plate
              FormBuilderTextField(
                name: 'licensePlate',
                decoration: customTextFieldDecoration(
                  "License Plate",
                  prefixIcon: Icons.confirmation_number,
                ),
                initialValue: widget.vehicle?.licensePlate,
                validator: FormBuilderValidators.required(
                  errorText: "Please enter license plate",
                ),
              ),
              SizedBox(height: 16),

              // Color
              FormBuilderTextField(
                name: 'color',
                decoration: customTextFieldDecoration(
                  "Color",
                  prefixIcon: Icons.palette,
                ),
                initialValue: widget.vehicle?.color,
                validator: FormBuilderValidators.required(
                  errorText: "Please enter color",
                ),
              ),
              SizedBox(height: 16),

              // Year and Seats Row
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'yearOfManufacture',
                      decoration: customTextFieldDecoration(
                        "Year",
                        prefixIcon: Icons.calendar_today,
                      ),
                      initialValue: widget.vehicle?.yearOfManufacture
                          ?.toString(),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: "Please enter year",
                        ),
                        FormBuilderValidators.numeric(
                          errorText: "Please enter a valid year",
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'seatsCount',
                      decoration: customTextFieldDecoration(
                        "Seats",
                        prefixIcon: Icons.airline_seat_recline_normal,
                      ),
                      initialValue: widget.vehicle?.seatsCount?.toString(),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: "Please enter seats count",
                        ),
                        FormBuilderValidators.numeric(
                          errorText: "Please enter valid seats count",
                        ),
                      ]),
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
