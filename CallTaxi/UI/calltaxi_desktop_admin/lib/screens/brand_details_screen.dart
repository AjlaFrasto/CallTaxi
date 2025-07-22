import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/brand.dart';
import 'package:calltaxi_desktop_admin/providers/brand_provider.dart';
import 'package:calltaxi_desktop_admin/screens/brand_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'dart:io';

class BrandDetailsScreen extends StatefulWidget {
  Brand? brand;
  BrandDetailsScreen({super.key, this.brand});

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late BrandProvider brandProvider;
  bool isLoading = true;
  File? _image;

  @override
  void initState() {
    super.initState();
    brandProvider = Provider.of<BrandProvider>(context, listen: false);
    _initialValue = {
      "name": widget.brand?.name,
      "logo": widget.brand?.logo != null ? widget.brand!.logo.toString() : null,
    };
    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['logo'] = base64Encode(_image!.readAsBytesSync());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Brand Details",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.cancel),
          label: Text("Cancel"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () async {
            formKey.currentState?.saveAndValidate();
            if (formKey.currentState?.validate() ?? false) {
              var request = Map.from(formKey.currentState?.value ?? {});
              request['logo'] = _initialValue['logo'];
              try {
                if (widget.brand == null) {
                  widget.brand = await brandProvider.insert(request);
                } else {
                  widget.brand = await brandProvider.update(
                    widget.brand!.id,
                    request,
                  );
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const BrandListScreen(),
                  ),
                );
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          icon: Icon(Icons.save),
          label: Text("Save"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FormBuilder(
              key: formKey,
              initialValue: _initialValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Brand',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 24),
                  FormBuilderTextField(
                    name: "name",
                    decoration: customTextFieldDecoration(
                      "Name",
                      prefixIcon: Icons.text_fields,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.match(
                        RegExp(r'^[\p{L} ]+$', unicode: true),
                        errorText:
                            'Only letters (including international), and spaces allowed',
                      ),
                    ]),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      _initialValue['logo'] != null &&
                              (_initialValue['logo'] as String).isNotEmpty
                          ? Image.memory(
                              base64Decode(_initialValue['logo']),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 64, color: Colors.grey),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _pickLogo,
                        icon: Icon(Icons.upload_file),
                        label: Text("Upload Logo"),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
