import 'dart:convert';
import 'dart:io';

import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/city.dart';
import 'package:calltaxi_desktop_admin/providers/city_provider.dart';
import 'package:calltaxi_desktop_admin/screens/city_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';

class CityDetailsScreen extends StatefulWidget {
  City? city;
  CityDetailsScreen({super.key, this.city});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  Map<String, dynamic> _initalValue = {};

  late CityProvider cityProvider;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cityProvider = Provider.of<CityProvider>(context, listen: false);

    _initalValue = {"name": widget.city?.name};
    print("widget.city");
    print(_initalValue);

    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "City Details",
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
              print(formKey.currentState?.value.toString());
              var request = Map.from(formKey.currentState?.value ?? {});
              try {
                if (widget.city == null) {
                  widget.city = await cityProvider.insert(request);
                } else {
                  widget.city = await cityProvider.update(
                    widget.city!.id,
                    request,
                  );
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const CityListScreen(),
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
              initialValue: _initalValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'City',
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
