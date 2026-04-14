// lib/features/wallet/screens/withdraw_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/utils/ui_helpers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/wallet_controller.dart';

class WithdrawRequestScreen extends ConsumerStatefulWidget {
  const WithdrawRequestScreen({super.key});

  @override
  ConsumerState<WithdrawRequestScreen> createState() =>
      _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends ConsumerState<WithdrawRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _targetAccountCtrl = TextEditingController();
  String _selectedMethod = 'GoPay';

  final List<String> _methods = [
    'GoPay',
    'OVO',
    'DANA',
    'ShopeePay',
    'Bank Transfer'
  ];

  final _format =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static const int _minWithdraw = 50000;
  static const int _fee = 2500;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _targetAccountCtrl.dispose();
    super.dispose();
  }

  int get _parsedAmount =>
      int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  int get _netAmount => _parsedAmount - _fee;

  void _onSubmit() {
    UiHelpers.hideKeyboard(context);
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(walletControllerProvider.notifier)
        .requestWithdrawal(
          amount: _parsedAmount,
          destination: '$_selectedMethod - ${_targetAccountCtrl.text.trim()}',
        )
        .then((_) {
      UiHelpers.showSuccessSnackBar(
          context, 'Permintaan penarikan berhasil diajukan!');
      if (context.mounted) context.pop();
    }).catchError((e) {
      UiHelpers.showErrorSnackBar(context, e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    final walletState = ref.watch(walletControllerProvider);
    final isLoading = walletState.isLoading;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Tarik Dana'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Saldo Info ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Aktif',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          _format.format(user.saldoActive),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.primary, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Form Card ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jumlah
                    const Text('Jumlah Penarikan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: 'Minimal ${_format.format(_minWithdraw)}',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        final amount =
                            int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ??
                                0;
                        if (amount < _minWithdraw) {
                          return 'Minimal penarikan ${_format.format(_minWithdraw)}';
                        }
                        if (amount > user.saldoActive) {
                          return 'Saldo tidak mencukupi';
                        }
                        return null;
                      },
                    ),

                    // Preview net amount
                    if (_parsedAmount >= _minWithdraw) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Biaya layanan: ${_format.format(_fee)}',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                            Text(
                              'Diterima: ${_format.format(_netAmount)}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Metode
                    const Text('Metode Pencairan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      items: _methods
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nomor rekening
                    const Text('Nomor Rekening / E-Wallet',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetAccountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 08123456789',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Catatan ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Penarikan dikenakan biaya layanan ${_format.format(_fee)} dan diproses 1x24 jam kerja.',
                        style: TextStyle(
                            color: Colors.orange.shade700, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ─── Submit ───────────────────────────────────────────
              CustomButton(
                text: 'Ajukan Penarikan',
                isLoading: isLoading,
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
