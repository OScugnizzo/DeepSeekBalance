import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_loader.dart';

/// API key input with show/hide toggle and an animated save action.
class ApiKeyField extends StatefulWidget {
  const ApiKeyField({
    super.key,
    required this.controller,
    required this.onSave,
    required this.isLoading,
    this.hasSavedKey = false,
  });

  final TextEditingController controller;

  /// Returns `true` when the key was accepted, which triggers the saved
  /// checkmark micro-interaction.
  final Future<bool> Function(String value) onSave;
  final bool isLoading;
  final bool hasSavedKey;

  @override
  State<ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<ApiKeyField> {
  bool _obscure = true;
  bool _justSaved = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    final ok = await widget.onSave(widget.controller.text);
    if (!mounted || !ok) return;
    lightImpact();
    setState(() => _justSaved = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _justSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.isLoading && widget.controller.text.trim().isNotEmpty;

    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleSave(),
      style: const TextStyle(letterSpacing: 0.4),
      decoration: InputDecoration(
        hintText: 'sk-••••••••••••••••••••••••',
        prefixIcon: const Icon(Icons.key_rounded, size: 20),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: _obscure ? 'Show key' : 'Hide key',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  key: ValueKey(_obscure),
                  size: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SaveButton(
                enabled: enabled,
                isLoading: widget.isLoading,
                saved: _justSaved,
                onPressed: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.isLoading,
    required this.saved,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final bool saved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = enabled || isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: saved
            ? AppColors.offPeak
            : active
            ? AppColors.brand
            : (isDark ? const Color(0xFF252B38) : const Color(0xFFEDEFF6)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: active && !saved
            ? [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 20,
                      height: 20,
                      child: BrandLoader(size: 20),
                    )
                  : Icon(
                      saved
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      key: ValueKey(saved),
                      size: 20,
                      color: active
                          ? Colors.white
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
