import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/condition_check_box_widget.dart';
import 'package:sixam_mart/features/auth/widgets/social_login_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  const OtpLoginWidget(
      {super.key,
      required this.phoneController,
      required this.phoneFocus,
      required this.passwordFocus,
      required this.onCountryChanged,
      required this.countryDialCode,
      required this.onClickLoginButton,
      this.socialEnable = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text('get_otp'.tr,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge)),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomTextField(
            onCountryChanged: (countryCode) =>
                authController.countryDialCode = countryCode.dialCode!,
            countryDialCode: authController.isNumberLogin
                ? authController.countryDialCode
                : null,
            labelText: 'email_or_phone'.tr,
            titleText: 'enter_email_or_phone'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            nextFocus: passwordFocus,
            inputType: TextInputType.emailAddress,
            prefixImage:
                authController.isNumberLogin ? null : Images.emailWithPhoneIcon,
            onChanged: (String text) {
              final numberRegExp = RegExp(r'^[+]?[0-9]+$');

              if (text.isEmpty && authController.isNumberLogin) {
                authController.toggleIsNumberLogin();
              }
              if (text.startsWith(numberRegExp) &&
                  !authController.isNumberLogin) {
                authController.toggleIsNumberLogin();
                phoneController.text = text.replaceAll("+", "");
              }
              final emailRegExp = RegExp(r'@');
              if (text.contains(emailRegExp) && authController.isNumberLogin) {
                authController.toggleIsNumberLogin();
              }
            },
            validator: (String? value) {
              if (authController.isNumberLogin &&
                  ValidateCheck.getValidPhone(
                          authController.countryDialCode + value!) ==
                      "") {
                return "enter_valid_phone_number".tr;
              }
              return (GetUtils.isPhoneNumber(
                          authController.countryDialCode + value!.tr) ||
                      GetUtils.isEmail(value.tr))
                  ? null
                  : 'enter_email_address_or_phone_number'.tr;
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => authController.toggleRememberMe(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      side: BorderSide(color: Theme.of(context).hintColor),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMe,
                      onChanged: (bool? isChecked) =>
                          authController.toggleRememberMe(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text('remember_me'.tr, style: robotoRegular),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          const ConditionCheckBoxWidget(forSignUp: true),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButton(
            buttonText: 'login'.tr,
            radius: Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: onClickLoginButton,
            fontSize: isDesktop
                ? Dimensions.fontSizeSmall
                : Dimensions.fontSizeDefault,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          socialEnable
              ? const SocialLoginWidget(onlySocialLogin: false)
              : const SizedBox(),
          socialEnable && isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),
          !socialEnable ? const SizedBox(height: 100) : const SizedBox(),
        ]),
      );
    });
  }
}
