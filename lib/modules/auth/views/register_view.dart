import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watibot/core/theme/app_theme.dart';
import 'package:watibot/core/validators/app_validators.dart';
import 'package:watibot/core/widgets/auth_button.dart';
import 'package:watibot/core/widgets/auth_checkbox.dart';
import 'package:watibot/core/widgets/auth_textfield.dart';
import 'package:watibot/modules/auth/controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // Light green tint at top
              Color(0xFFF6F7FB), // Grey base
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32, // 32 is total vertical padding
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildCard(context),
                          const SizedBox(height: 24),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'WatiBot',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF006633), // Dark green text based on image
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Intelligent automation starts here.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF475569), // Slate 600
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Create Account',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AuthTextField(
              label: 'Full Name',
              hint: 'John Doe',
              leadingIcon: Icons.person_outline,
              controller: controller.nameController,
              focusNode: controller.nameFocus,
              keyboardType: TextInputType.name,
              validator: AppValidators.validateName,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Email Address',
              hint: 'john@company.com',
              leadingIcon: Icons.mail_outline,
              controller: controller.emailController,
              focusNode: controller.emailFocus,
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.validateEmail,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Company Name',
              optionalLabel: 'Optional',
              hint: 'Acme Corp',
              leadingIcon: Icons.business_outlined,
              controller: controller.companyController,
              focusNode: controller.companyFocus,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            Obx(() => AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  leadingIcon: Icons.lock_outline,
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocus,
                  isPassword: controller.hidePassword.value,
                  validator: AppValidators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.hidePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: controller.togglePassword,
                  ),
                )),
            const SizedBox(height: 20),
            Text(
              'Verification Method',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.setVerificationMethod('email'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: controller.verificationMethod.value == 'email'
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                              width: controller.verificationMethod.value == 'email' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: controller.verificationMethod.value == 'email'
                                ? AppTheme.primaryColor.withOpacity(0.05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: controller.verificationMethod.value == 'email'
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Email',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: controller.verificationMethod.value == 'email'
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.setVerificationMethod('phone'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: controller.verificationMethod.value == 'phone'
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                              width: controller.verificationMethod.value == 'phone' ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: controller.verificationMethod.value == 'phone'
                                ? AppTheme.primaryColor.withOpacity(0.05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_outlined, // WhatsApp like
                                color: controller.verificationMethod.value == 'phone'
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'WhatsApp',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: controller.verificationMethod.value == 'phone'
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            Obx(() => controller.verificationMethod.value == 'phone'
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: AuthTextField(
                      label: 'Phone Number (WhatsApp)',
                      hint: '+1 234 567 8900',
                      leadingIcon: Icons.phone_outlined,
                      controller: controller.phoneController,
                      focusNode: controller.phoneFocus,
                      keyboardType: TextInputType.phone,
                    ),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 20),
            Obx(() => AuthCheckbox(
                  value: controller.agreeTerms.value,
                  onChanged: controller.toggleTerms,
                )),
            const SizedBox(height: 24),
            Obx(() => AuthButton(
                  title: 'Create Account',
                  onPressed: controller.register,
                  loading: controller.isLoading.value,
                  enabled: controller.agreeTerms.value,
                )),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      '© 2024 WatiBot Enterprise Solutions.',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 12,
        color: const Color(0xFF64748B),
      ),
    );
  }
}
