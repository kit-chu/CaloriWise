import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';

class AppDialogs {

  // ================== Confirmation Dialog ==================
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: icon != null
            ? Icon(
          icon,
          size: 48,
          color: isDangerous
              ? Colors.red
              : confirmColor ?? AppTheme.primaryPurple,
        )
            : null,
        title: Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: AppTextStyle.bodyMedium(context).copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: Text(
              cancelText,
              style: AppTextStyle.labelLarge(context),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous
                  ? Colors.red
                  : confirmColor ?? AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: AppTextStyle.labelLarge(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== Info Dialog ==================
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'ตกลง',
    IconData? icon,
    Color? iconColor,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon != null
            ? Icon(
          icon,
          size: 48,
          color: iconColor ?? AppTheme.primaryPurple,
        )
            : null,
        title: Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: AppTextStyle.bodyMedium(context).copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: AppTextStyle.labelLarge(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== Error Dialog ==================
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'ตกลง',
    VoidCallback? onRetry,
    String retryText = 'ลองใหม่',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.red,
        ),
        title: Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: AppTextStyle.bodyMedium(context).copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          if (onRetry != null) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
              ),
              child: Text(
                retryText,
                style: AppTextStyle.labelLarge(context).copyWith(
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: AppTextStyle.labelLarge(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== Success Dialog ==================
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'ยอดเยี่ยม',
    VoidCallback? onContinue,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          size: 48,
          color: Colors.green,
        ),
        title: Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: AppTextStyle.bodyMedium(context).copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: AppTextStyle.labelLarge(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== Loading Dialog ==================
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'กำลังดำเนินการ...',
    bool barrierDismissible = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: AppTextStyle.bodyMedium(context).copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================== Custom Input Dialog ==================
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    String? initialValue,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message != null) ...[
                Text(
                  message,
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 16),
              ],
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLength: maxLength,
                obscureText: obscureText,
                autofocus: true,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: Text(
              cancelText,
              style: AppTextStyle.labelLarge(context),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: AppTextStyle.labelLarge(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== Selection Dialog ==================
  static Future<T?> showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    T? selectedItem,
    String cancelText = 'ยกเลิก',
  }) async {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTextStyle.titleLarge(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == selectedItem;

              return ListTile(
                title: Text(
                  itemLabel(item),
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : AppTheme.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                leading: isSelected
                    ? Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryPurple,
                )
                    : Icon(
                  Icons.radio_button_unchecked,
                  color: AppTheme.textSecondary,
                ),
                onTap: () => Navigator.of(context).pop(item),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: Text(
              cancelText,
              style: AppTextStyle.labelLarge(context),
            ),
          ),
        ],
      ),
    );
  }

  // ================== Helper Methods ==================

  // ปิด Loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show Bottom Sheet Dialog
  static Future<T?> showBottomSheetDialog<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}