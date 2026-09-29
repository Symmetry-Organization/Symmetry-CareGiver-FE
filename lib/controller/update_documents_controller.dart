import 'dart:io';

import 'package:clinician_app/controller/repository/profile_repo.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/common/base64_conversation.dart';
import '../core/constant/app_string.dart';
import '../model/chatScreen/chatList_model.dart';
import '../model/profile/update_documents_model.dart';
import '../model/request/request_data_model.dart';
import '../services/auth_api_services/auth_services.dart';
import 'package:clinician_app/services/mock/mock_data_service.dart';

class UpdateDocumentsController extends GetxController {
  final ApiService _api = Get.put(ApiService());
  final isDocListLoading = false.obs;
  final isSubDocListLoading = false.obs;
  final isDocumentSaveLoading = false.obs;
  final error = ''.obs;
  final documentResponseModel = DocumentResponseModel(
      document: []).obs;
  final Rxn<File> selectedPdfFile = Rxn<File>();
  final RxString fileName = ''.obs;
  final RxString filePath = ''.obs;
  final RxString fileNameValidation = ''.obs;
  // Pages captured with the camera, in the order they were scanned. They are
  // merged into a single PDF on save — the upload endpoint takes one file.
  final capturedPages = <CapturedPage>[].obs;
  final isExpDateShown = false.obs;
  final docSubList = <EmployeeDubDocumentDropDownModel>[].obs;

  // Edit-document flow
  final isPrefillLoading = false.obs;
  final Rxn<EmployeeDocumentPrefillData> prefillData =
      Rxn<EmployeeDocumentPrefillData>();

  // "Select document" options are fixed, not fetched from the API. The sub
  // document dropdown below still loads from the API, keyed off whichever
  // id is picked here.
  static final List<DocumentMetaDataModel> staticDocMetaList = [
    DocumentMetaDataModel(employeeDocumentTypeMetaDataId: 5, documentName: 'Acknowledgement'),
    DocumentMetaDataModel(employeeDocumentTypeMetaDataId: 1, documentName: 'Health Record'),
  ];
  final docMetaList = <DocumentMetaDataModel>[...staticDocMetaList].obs;
  final RxString expiryIsoDate = ''.obs;

  // ✅ selected dropdown value (use id)
  final selectedSubDocId = 0.obs;
  final selectedSubDocName = ''.obs;

  // selecte master visit
  final selectedMasterMetaDocId = 0.obs;
  final selectedMasterMetaDocName = ''.obs;

  @override
  void onClose() {
    super.onClose();
  }


   int maxBytes = 20 * 1024 * 1024; // 20MB

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // ✅ only pdf
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;

      // ✅ Ensure PDF only
      final ext = picked.name.split('.').last.toLowerCase();
      if (ext != 'pdf') {
        // Get.snackbar('Invalid file', 'Please select a PDF file only.');
        return;
      }

      // ✅ Size check (bytes)
      if (picked.size > maxBytes) {
        fileNameValidation.value = "File too large";
        // Get.snackbar('File too large', 'Please select a PDF under 20MB.');
        return;
      }

      // ✅ Must have valid path for File
      if (picked.path == null || picked.path!.isEmpty) {
        Get.snackbar('Error', 'File path not found.');
        return;
      }

      final file = File(picked.path!);

      // ✅ store in Rx<File?>
      selectedPdfFile.value = file;
      fileName.value = picked.name;
      filePath.value = picked.path!;

      // Get.snackbar('Selected PDF', picked.name);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void addCapturedPage(File image) {
    final DateTime now = DateTime.now();
    capturedPages.add(
      CapturedPage(
        file: image,
        label: '${DateFormat('yyyy/MM/ddHH:mm:ss').format(now)}'
            '${now.millisecondsSinceEpoch % 100000}.img',
      ),
    );
    fileNameValidation.value = '';
  }

  void removeCapturedPage(CapturedPage page) {
    capturedPages.remove(page);
  }

  /// Merges the captured pages into a single multi-page PDF in the temp
  /// directory, one page per capture.
  Future<File> buildCapturedPagesPdf() async {
    final pw.Document pdf = pw.Document();
    for (final CapturedPage page in capturedPages) {
      final pw.MemoryImage image = pw.MemoryImage(await page.file.readAsBytes());
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(child: pw.Image(image)),
        ),
      );
    }
    final Directory dir = await getTemporaryDirectory();
    final File out = File(
      '${dir.path}/scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await out.writeAsBytes(await pdf.save());
    return out;
  }

  void clearFile() {
    fileName.value = '';
    filePath.value = '';
  }
  void clearAll() {
    fileName.value = '';
    filePath.value = '';
    capturedPages.clear();
     selectedSubDocId.value = 0;
     selectedSubDocName.value = '';
     selectedMasterMetaDocId.value = 0;
     selectedMasterMetaDocName.value = '';
     fileNameValidation.value = '';
    expiryIsoDate.value = '';
     isExpDateShown.value = false;
    isDocumentSaveLoading.value = false;
  }

  Future<void> fetchSubDocList({required int docMetaId}) async {
    final list = await getSubDocumentListDropdown(docMetaId: docMetaId);
    docSubList.assignAll(list);

  }
  Future<void> fetchDocListDetails({required int empId,
    required String approveOnly,
    required String searchText,}) async {
    documentResponseModel.value = await getDocumentListData(empId: empId, approveOnly: approveOnly, searchText: searchText);
  }

  Future<DocumentResponseModel> getDocumentListData({
    required int empId,
    required String approveOnly,
    required String searchText,
  }) async {
    DocumentResponseModel? itemData;

    String formatIOSDate(String iosDate) {
      if (iosDate.isEmpty) return '';

      DateTime dateTime = DateTime.parse(iosDate);

      return DateFormat('yyyy/MM/dd')
          .format(dateTime)
          .toLowerCase();
    }

    try {
      isDocListLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   ProfileRepository.getUpdateListDocument(
      //     employeeId: empId,
      //     approveOnly: approveOnly, search: searchText,
      //   ),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.list'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        List<DocumentGroup> docData = [];

        if (res.data["document"] != null) {
          for (var d in res.data["document"]) {

            List<EmployeeDocument> docList = [];

            if (d["docList"] != null) {
              for (var doc in d["docList"]) {
                docList.add(
                  EmployeeDocument(
                    employeeDocumentId: doc['employeeDocumentId'] ?? 0,
                    employeeId: doc['employeeId'] ?? 0,
                    documentUrl: doc['DocumentUrl'] ?? '',
                    employeeDocumentTypeMetaDataId:
                    doc['EmployeeDocumentTypeMetaDataId'] ?? 0,
                    employeeDocumentTypeSetupId:
                    doc['EmployeeDocumentTypeSetupId'] ?? 0,
                    uploadDate: doc['UploadDate'] ?? '',
                    approved: doc['approved'] ?? false,
                    documentName: doc['documentName'] ?? '',
                    expiryDate: doc['expiry_date'] != null ? formatIOSDate(doc['expiry_date']) : '--',
                    docStatus: doc['docStatus'] ?? '',
                  ),
                );
              }
            }

            docData.add(
              DocumentGroup(
                docName: d['docName'] ?? '',
                metaId: d['metaId'] ?? 0,
                docList: docList,
              ),
            );
          }
        }


        itemData = DocumentResponseModel(document: docData);

      } else {
        error.value = "Failed to list data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isDocListLoading.value = false;
    }

    // ✅ GUARANTEED NON-NULL RETURN
    return itemData ?? DocumentResponseModel(document: []);
  }


  Future<List<EmployeeDubDocumentDropDownModel>> getSubDocumentListDropdown({
    required int docMetaId,

  }) async {
    List<EmployeeDubDocumentDropDownModel> itemData = [];

    String formatIOSDate(String iosDate) {
      if (iosDate.isEmpty) return '';

      DateTime dateTime = DateTime.parse(iosDate);

      return DateFormat('dd/MM/yyyy')
          .format(dateTime)
          .toLowerCase();
    }

    try {
      isSubDocListLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   ProfileRepository.getSubDocListDocument(docMetaId: docMetaId

      //   ),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.subDocTypes'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        for(var item in res.data){
          itemData.add(EmployeeDubDocumentDropDownModel(
              employeeDocumentTypeSetupId: item['EmployeeDocumentTypeSetupId'] ?? 0,
              documentName: item['DocumentName'] ?? '',
              expiry: item['Expiry'] ?? '',
              reminderThreshold: item['ReminderThreshold'] ?? '',
              employeeDocumentTypeMetaDataId: item['EmployeeDocumentTypeMetaDataId'] ?? 0,
              idOfDocument: item['idOfDocument'] ?? '',
              companyId: item['companyId'] ?? 0,
              expiry_type: item['expiry_type'] ?? '',
              threshold: item['threshold'] ?? 0));
        }
      } else {
        error.value = "Failed to list data";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isSubDocListLoading.value = false;
    }

    // ✅ GUARANTEED NON-NULL RETURN
    return itemData;
  }

  /// upload document
  Future<ApiData> postUploadDocumentData({
    required int docMetaId,
    required int docTypeSetupId,
    required int empId,
  }) async {
    try {
      isDocumentSaveLoading.value = true;
      error.value = '';

      // final res = await _api.post(ProfileRepository.postUploadDocument(
      //     docMetaId: docMetaId,
      //     docTypeSetupId: docTypeSetupId,
      //     empId: empId), {
      // });  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.upload'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        print('Doc uploaded successfully');
        // final data = res.data as Map<String, dynamic>;
        return ApiData(
            success: true,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }else{
        error.value = res.statusMessage!;
        return ApiData(
            success: false,
            message: res.statusMessage!,
            statusCode: res.statusCode!
        );
      }
    } catch (e) {
      error.value = e.toString();
      return ApiData(
          success: false,
          message:AppString.somethingWentWrong,
          statusCode: 404
      );
    } finally {
      isDocumentSaveLoading.value = false;
    }
  }

  /// Upload base 64
  Future<ApiData> postUploadDocumentBase64Data({
    required int docMetaId,
    required int docTypeSetupId,
    required int empId,
    required File base64File,
    required String documentName,
    String? expiryDate,
  }) async {
    try {
      isDocumentSaveLoading.value = true;
      error.value = '';

      final String base64 = await FileUtils.fileToBase64(base64File);
      print('Expiry Date: $expiryDate');

      // final res = await _api.post(
      //   ProfileRepository.postUploadDocumentBase64(
      //     docMetaId: docMetaId,
      //     docTypeSetupId: docTypeSetupId,
      //     empId: empId,
      //   ),
      //   {
      //     "base64": base64,
      //     "expiry_date": expiryDate,
      //     "documentName": documentName,
      //   },
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.upload'));

      print("Error message ${res.statusMessage}");
      if (res.statusCode == 200 || res.statusCode == 201) {
        final backendMessage = _extractBackendMessage(res.data, res.statusMessage);
        return ApiData(
          success: true,
          message: backendMessage,
          statusCode: res.statusCode!,
        );
      } else {
        final backendMessage = _extractBackendMessage(res.data, res.statusMessage);
        error.value = backendMessage;
        return ApiData(
          success: false,
          message: backendMessage,
          statusCode: res.statusCode!,
        );
      }
    } on DioException catch (e) {
      final backendMessage = _extractBackendMessage(e.response?.data, null);
      error.value = backendMessage;
      return ApiData(
        success: false,
        message: backendMessage,
        statusCode: e.response?.statusCode ?? 404,
      );
    } catch (e) {
      error.value = e.toString();
      return ApiData(
        success: false,
        message: AppString.somethingWentWrong,
        statusCode: 500,
      );
    } finally {
      isDocumentSaveLoading.value = false;
    }
  }

  /// Fetch a single employee document to prefill the edit-document dialog.
  Future<EmployeeDocumentPrefillData?> fetchPrefillDocument({
    required int employeeDocumentId,
  }) async {
    EmployeeDocumentPrefillData? data;
    try {
      isPrefillLoading.value = true;
      error.value = '';

      // final res = await _api.get(
      //   ProfileRepository.getOrPatchEmployeeDocument(
      //     employeeDocumentId: employeeDocumentId,
      //   ),
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.prefill'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        data = EmployeeDocumentPrefillData(
          documentName: res.data['DocumentName'] ?? '',
          expiry: res.data['expiry_date'] ?? '',
          reminderThresold: (res.data['ReminderThreshold'] ?? '').toString(),
          idOfDocument: (res.data['idOfDocument'] ?? '').toString(),
          documentType: res.data['DocumentType'] ?? '',
          empDocMetaDataId: res.data['EmployeeDocumentTypeMetaDataId'] ?? 0,
          empDocSetupId: res.data['EmployeeDocumentTypeSetupId'] ?? 0,
          documentUrl: res.data['DocumentUrl'] ?? '',
          employeeDocumentId: res.data['employeeDocumentId'] ?? 0,
          employeeId: res.data['employeeId'] ?? 0,
        );
        prefillData.value = data;
        print('Prefill data fetched: ${data.documentName} ${data.documentType}');
      } else {
        error.value = "Failed to load document";
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isPrefillLoading.value = false;
    }
    return data;
  }

  /// Metadata-only update — used when editing the expiry date without
  /// picking a new file, so the existing uploaded document is kept as-is.
  Future<ApiData> patchEmployeeDocumentMetadata({
    required int employeeDocumentId,
    required int docMetaId,
    required int docTypeSetupId,
    required int empId,
    required String documentUrl,
    required String uploadDate,
    String? expiryDate,
  }) async {
    try {
      isDocumentSaveLoading.value = true;
      error.value = '';

      // final res = await _api.patch(
      //   ProfileRepository.getOrPatchEmployeeDocument(
      //     employeeDocumentId: employeeDocumentId,
      //   ),
      //   {
      //     "EmployeeDocumentTypeMetaDataId": docMetaId,
      //     "EmployeeDocumentTypeSetupId": docTypeSetupId,
      //     "employeeId": empId,
      //     "DocumentUrl": documentUrl,
      //     "UploadDate": uploadDate,
      //     "expiry_date": expiryDate,
      //   },
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.patchMetadata'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final backendMessage = _extractBackendMessage(res.data, res.statusMessage);
        return ApiData(success: true, message: backendMessage, statusCode: res.statusCode!);
      } else {
        final backendMessage = _extractBackendMessage(res.data, res.statusMessage);
        error.value = backendMessage;
        return ApiData(success: false, message: backendMessage, statusCode: res.statusCode!);
      }
    } on DioException catch (e) {
      final backendMessage = _extractBackendMessage(e.response?.data, null);
      error.value = backendMessage;
      return ApiData(
        success: false,
        message: backendMessage,
        statusCode: e.response?.statusCode ?? 404,
      );
    } catch (e) {
      error.value = e.toString();
      return ApiData(
        success: false,
        message: AppString.somethingWentWrong,
        statusCode: 500,
      );
    } finally {
      isDocumentSaveLoading.value = false;
    }
  }

  /// Downloads an employee document by filename (derived from its URL)
  /// through the authenticated API instead of hitting the raw file URL.
  Future<DownloadFileData?> getEmployeeDocumentByFileName({
    required String fileUrl,
  }) async {
    try {
      // Signed URLs (e.g. "...file.pdf?token=...") carry query params —
      // split on '/' alone would leave "file.pdf?token=..." as the
      // filename, breaking both the API path and the saved file's extension.
      final uri = Uri.tryParse(fileUrl);
      final fileName = (uri != null && uri.pathSegments.isNotEmpty)
          ? uri.pathSegments.last
          : fileUrl.split('/').last;
      // final response = await _api.getBytes(
      //   path: "${ProfileRepository.employeeDocumentsDownload}/$fileName",
      // );  // MOCKED for local UI testing — no real file behind a mock URL
      final response = mockBytesResponse();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DownloadFileData(
          fileName: fileName,
          bytes: response.data,
        );
      } else {
        print('Api Error');
        return null;
      }
    } on DioException catch (e) {
      print("Error ${e.response?.data['message'] ?? e.message}");
      return null;
    } catch (e) {
      print("Error $e");
      return null;
    }
  }

  /// PATCH with a newly uploaded file, replacing the existing document.
  /// This endpoint's body only accepts base64 + documentName — it does not
  /// take an expiry date. Callers that also need to update the expiry
  /// should follow this with [patchEmployeeDocumentMetadata].
  Future<ApiData> patchEmployeeDocumentBase64Data({
    required int employeeDocumentId,
    required int docMetaId,
    required int docTypeSetupId,
    required int empId,
    required File base64File,
    required String documentName,
  }) async {
    try {
      isDocumentSaveLoading.value = true;
      error.value = '';

      final String base64 = await FileUtils.fileToBase64(base64File);
      // final res = await _api.patch(
      //   ProfileRepository.patchEmployeeDocumentWithBase64(
      //     employeeDocumentId: employeeDocumentId,
      //     docMetaId: docMetaId,
      //     docTypeSetupId: docTypeSetupId,
      //     empId: empId,
      //   ),
      //   {
      //     "base64": base64,
      //     "documentName": documentName,
      //   },
      // );  // MOCKED for local UI testing
      final res = mockResponse(MockData.get('documents.patchBase64'));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final backendMessage = _extractBackendMessage(res.data, res.statusMessage);
        return ApiData(success: true, message: backendMessage, statusCode: res.statusCode!);
      } else {
        final backendMessage = _extractBackendMessage(res.data, res.statusMessage);
        error.value = backendMessage;
        return ApiData(success: false, message: backendMessage, statusCode: res.statusCode!);
      }
    } on DioException catch (e) {
      final backendMessage = _extractBackendMessage(e.response?.data, null);
      error.value = backendMessage;
      return ApiData(
        success: false,
        message: backendMessage,
        statusCode: e.response?.statusCode ?? 404,
      );
    } catch (e) {
      error.value = e.toString();
      return ApiData(
        success: false,
        message: AppString.somethingWentWrong,
        statusCode: 500,
      );
    } finally {
      isDocumentSaveLoading.value = false;
    }
  }
}

/// One page scanned with the camera: the image on disk plus the timestamped
/// name shown on its thumbnail.
class CapturedPage {
  CapturedPage({required this.file, required this.label});

  final File file;
  final String label;
}

String _extractBackendMessage(dynamic data, String? fallback) {
  if (data is Map<String, dynamic> && data['message'] != null) {
    return data['message'].toString();
  } else if (data is String && data.isNotEmpty) {
    return data;
  }
  return fallback ?? AppString.somethingWentWrong;
}