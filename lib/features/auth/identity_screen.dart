import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/crypto/identity_service.dart';
import '../../core/theme/app_colors.dart';
import '../chats/chats_list_screen.dart';

class IdentityScreen extends StatefulWidget {
  final bool isLogin;
  const IdentityScreen({super.key, required this.isLogin});

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  final _passwordController = TextEditingController();
  final _recoveryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _publicId;
  String? _recoveryString;
  String? _error;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final result = await IdentityService.createAccount(password: _passwordController.text.trim());
      setState(() {
        _publicId = result.publicId;
        _recoveryString = result.recoveryString;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = 'Ошибка: $e'; _isLoading = false; });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final result = await IdentityService.loginWithRecovery(
        recoveryString: _recoveryController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (result == null) {
        setState(() { _error = 'Неверный ключ или пароль'; _isLoading = false; });
        return;
      }
      setState(() {
        _publicId = result.publicId;
        _recoveryString = result.recoveryString;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = 'Ошибка: $e'; _isLoading = false; });
    }
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label скопирован')));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _recoveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_publicId != null) return _buildSuccess();

    return Scaffold(
      appBar: AppBar(title: Text(widget.isLogin ? 'Войти' : 'Создать аккаунт')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isLogin ? 'Вставь ключ восстановления и пароль' : 'Придумай надёжный пароль',
                  style: GoogleFonts.roboto(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (widget.isLogin) ...[
                  TextFormField(
                    controller: _recoveryController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Ключ восстановления'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Вставь ключ' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Введи пароль';
                    if (!widget.isLogin && v.trim().length < 6) return 'Минимум 6 символов';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (widget.isLogin ? _login : _createAccount),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(widget.isLogin ? 'Войти' : 'Создать'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      appBar: AppBar(title: const Text('Твой ключ'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Ключ для друзей', style: GoogleFonts.roboto(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(data: _publicId!, version: QrVersions.auto, size: 200, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(child: Text(_publicId!, style: GoogleFonts.robotoMono(fontSize: 14, color: AppColors.primary))),
                    IconButton(icon: const Icon(Icons.copy, color: AppColors.primary), onPressed: () => _copy(_publicId!, 'Ключ')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text('Секретный ключ восстановления', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, color: AppColors.warning)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Сохрани его. Без него нельзя восстановить аккаунт.', style: GoogleFonts.roboto(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(child: Text(_recoveryString ?? '', style: GoogleFonts.robotoMono(fontSize: 11, color: AppColors.textPrimary))),
                          IconButton(icon: const Icon(Icons.copy, size: 20), onPressed: () => _copy(_recoveryString ?? '', 'Ключ восстановления')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatsListScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Продолжить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}