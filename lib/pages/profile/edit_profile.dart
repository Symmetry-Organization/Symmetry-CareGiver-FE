import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/common_appbar.dart';
import 'package:clinician_app/core/ui/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_controller.dart';
import '../../core/ui/const_sucess_popup.dart';
import '../../utils/validator.dart';

class EditProfilePage extends StatefulWidget {
  final int employeeId;
  const EditProfilePage({super.key, required this.employeeId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const double _saveButtonHeight = 21;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: controller.isEmployeeLoading.value ?
        Center(child: CircularProgressIndicator(),) :Form(
          key: _formKey,
          child: Column(
            children: [
              Obx(() =>   CommonAppbar(
                onTap: () async {
                  await controller.fetchClinitionLoginDetails();
                  Get.back(result: controller.clinitinaLoginDataModel.value); // pass updated data back
                },
                label: "Edit Profile",
                trailing: controller.isEmployeeSaveLoading.value ? Padding(
                  padding: EdgeInsets.symmetric(horizontal:20.w ),
                  child: SizedBox(
                    height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(color: AppColors.primaryAppColor,)),
                ) : PrimaryButton(
                  onTap: () async{
                    if (_formKey.currentState!.validate()) {
                      // Form is valid
                      if(controller.selectedImage.value != null){
                        var response = await controller.patchEmployeeDataData(
                            empId: controller.employeeId.value,
                            employeeFirstName: controller.firstNameController
                                .value.text,
                            employeeLastName: controller.lastNameController.value
                                .text,
                            employeePhone: controller.phoneController.value.text,
                            employeeEmail: controller.emailController.value.text,
                            employeeaddress: "");
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          var imageResponse = await controller
                              .attachEmployeIamge(
                              empId: controller.employeeId.value);
                          if (imageResponse.statusCode == 200 ||
                              imageResponse.statusCode == 201) {
                            showSucessDialog(
                                context: context,
                                message: 'Profile updated successfully',
                                title: 'Successfully');
                            controller.fetchRecordType();
                          }
                          //Get.to(() => HomeScreen());
                          else {
                            showDocErrorDialog(context: context,
                                message: imageResponse.message,
                                title: "Error");
                            // Form is invalid
                            print('Validation failed');
                          }
                        }
                      }else{
                        var response = await controller.patchEmployeeDataData(
                            empId: controller.employeeId.value,
                            employeeFirstName: controller.firstNameController
                                .value.text,
                            employeeLastName: controller.lastNameController.value
                                .text,
                            employeePhone: controller.phoneController.value.text,
                            employeeEmail: controller.emailController.value.text,
                            employeeaddress: "");
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          controller.fetchClinitionLoginDetails();
                            showSucessDialog(
                                context: context,
                                message: 'Profile updated successfully',
                                title: 'Successfully');
                            controller.fetchRecordType();
                          //Get.to(() => HomeScreen());
                        }else{
                          showDocErrorDialog(context: context,
                              message: response.message,
                              title: "Error");
                          print('Validation failed');
                        }
                      }

                    }
                  },
                  label: "Save",
                  padding: EdgeInsets.zero,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 13.sp),
                  buttonColor: AppColors.saveButtonBlue,
                  height: _saveButtonHeight.h,
                  width: 60.w,
                  borderRadius: 6,
                ),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 15.h,
                  bottom: 8.h,
                ),
              )),
              Divider(),
              customHeight(30.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Obx(() {
                                ImageProvider imageProvider;

                                if (controller.selectedImage.value != null) {
                                  imageProvider = FileImage(controller.selectedImage.value!);
                                } else if (controller.employeeImage.isNotEmpty) {
                                  imageProvider = NetworkImage(controller.employeeImage.value);
                                } else {
                                  imageProvider =
                                  const AssetImage('assets/png/profilepic.png');
                                }

                                return CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: imageProvider,
                                );
                              }),
                              Padding(
                                padding: EdgeInsets.only(top: 70.h, left: 60.w),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onTap: (){
                                    controller.pickImage();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 12,
                                    child: Center(
                                      child: Icon(
                                        Icons.mode_edit_outlined,
                                        size: 15,
                                        color: AppColors.defaultTxtGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        customHeight(20.h),
                        Text("Your Information", style: AppTextStyle.bold14style),
                        customHeight(17.h),
                        PrimaryTextField(
                          controller: controller.firstNameController.value,
                          filledColor: AppColors.textFieldBackGColor,
                          hintText: "First Name",
                            validator: (value) => Validators.validateText()

                        ),
                        customHeight(23.h),
                        PrimaryTextField(
                          controller: controller.lastNameController.value,
                          filledColor: AppColors.textFieldBackGColor,
                          hintText: "Last Name",
                          validator: (value) => Validators.validateText(),
                        ),
                        customHeight(23.h),
                        PrimaryTextField(
                          isUsPhone: true,
                          validator: (value) {
                            if (value == null || value.length != 14) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                          controller: controller.phoneController.value,
                          filledColor: AppColors.textFieldBackGColor,
                          hintText: "Phone Number",
                        ),
                        customHeight(23.h),
                        PrimaryTextField(
                          controller: controller.emailController.value,
                          filledColor: AppColors.textFieldBackGColor,
                          hintText: "Email Address",
                          validator: (value) => Validators.validateEmail(value)
                        ),
                        customHeight(23.h),
                      ],
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
