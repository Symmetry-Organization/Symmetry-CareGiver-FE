/// DO NOT DELETE THIS FILE

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import '../../../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';
final ApiService Api = Get.put(ApiService());
Future<void> saveMapAsJsonFile(
    BuildContext context, Map<String, dynamic> data, String fileName, {bool isUpdating=false, int templateID=-1}) async {
  try {
    data['template_name'] += ' ' + data["title"];
    data['template_name'] = data['template_name'].replaceAll('  ', ' ');
    data['template_code'] =
        formatFormAndSubformId(data['formId'], data['subFormId']);
    // Convert map to JSON string
    resetSelectedToFalse(data);
    final jsonString = jsonEncode(data);

    // if(!isUpdating)
    //   {
    //     await uploadFormTemplate(context, formData: data);
    //   }
    // else
    //   {
    //     await updateFormTemplate(context, id: templateID, formData: data);
    //   }

    // Create a Blob and anchor element
    final bytes = utf8.encode(jsonString);
    var html;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '${data['template_code']} $fileName.json')
      ..click();

    html.Url.revokeObjectUrl(url); // Clean up
  } catch (e) {
    print('Error saving JSON file: $e');
  }
}

void resetSelectedToFalse(dynamic data) {
  if (data is Map<String, dynamic>) {
    data.forEach((key, value) {
      if (key == 'selected') {
        data[key] = false;
      } else {
        resetSelectedToFalse(value);
      }
    });
  } else if (data is List) {
    for (var item in data) {
      resetSelectedToFalse(item);
    }
  }
}

String formatFormAndSubformId(int formId, int subformId) {
  // Pad formId to be exactly 3 digits
  String formIdStr = formId.toString().padLeft(3, '0');

  // Pad subformId to be exactly 4 digits
  String subformIdStr = subformId.toString().padLeft(4, '0');

  // Concatenate and return the result
  return formIdStr + subformIdStr;
}

Future<bool> uploadFormTemplate(
  BuildContext context, {
  required Map<String, dynamic> formData,
}) async {
  try {
    // var response = await Api.post(
    //   '/form-templates',
    //   formData,
    // );  // MOCKED for local UI testing
    var response = mockResponse(
      MockData.get('forms.uploadFormTemplate'),
      statusCode: 201,
      statusMessage: 'Created',
    );
    if (response.statusCode == 201) {
      print("UPLOADED CODE: ${response.data['template_code']}");
      print("NAME: ${response.data['template_name']}");
      print("TEMPLATE ID: ${response.data['form_template_id']}");
      return true;
    } else {
      print("....................................................");
      print("ERROR WHILE UPLOADING ${formData['template_code']}");
      print("${response.data['message']}");
      print("....................................................");
      return false;
    }
  } catch (e) {
    print("Error $e");
    return false;
  }
}
//
// Future<bool> updateFormTemplate(
//   BuildContext context, {
//   required int id,
//   required Map<String, dynamic> formData,
// }) async {
//   try {
//     var response = await Api(context).put(
//       path: '/form-templates/$id',
//       data: formData,
//     );
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       print("UPDATED FORM DATA");
//       print("UPLOADED CODE: ${response.data['template_code']}");
//       print("NAME: ${response.data['template_name']}");
//       print("TEMPLATE ID: ${response.data['form_template_id']}");
//       return true;
//     } else {
//       print("....................................................");
//       print("STATUS CODE ${response.statusCode}");
//       print("ERROR WHILE UPLOADING ${formData['template_code']}");
//       print("${response.data['message']?? response.data}");
//       print("....................................................");
//       return false;
//     }
//   } catch (e) {
//     print("Error $e");
//     return false;
//   }
// }
