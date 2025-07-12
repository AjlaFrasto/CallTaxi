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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildForm(), _buildSaveButton()],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          label: Text("Cancel"),       
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            formKey.currentState?.saveAndValidate();
            if (formKey.currentState?.validate() ?? false) {
              print(formKey.currentState?.value.toString());
              var request = Map.from(formKey.currentState?.value ?? {});
              if (widget.city == null) {
                widget.city = await cityProvider.insert(request);
              } else {
                widget.city = await cityProvider.update(
                  widget.city!.id,
                  request,
                );
              }

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CityListScreen()),
              );
            }
          },
          style: ElevatedButton.styleFrom(foregroundColor: Colors.lightBlue),
          child: Text("Save"),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return FormBuilder(
      key: formKey,
      initialValue: _initalValue,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FormBuilderTextField(
              name: "name",
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.text_fields,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.match(
                  RegExp(r'^[A-Za-z\s]+'),
                  errorText: 'Only letters and spaces allowed',
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
