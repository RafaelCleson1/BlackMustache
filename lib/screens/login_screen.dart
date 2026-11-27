import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/error_messages.dart';
import '../providers/app_providers.dart';
import '../widgets/buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() {
        _errorMessage =
            'Configure SUPABASE_URL e SUPABASE_ANON_KEY no arquivo .env.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        final response = await client.auth.signUp(
          email: email,
          password: password,
        );
        if (!mounted || response.session != null) return;
        setState(() {
          _isSignUp = false;
          _confirmPasswordController.clear();
          _successMessage = 'Conta criada! Confirme seu e-mail para entrar.';
        });
      } else {
        await client.auth.signInWithPassword(email: email, password: password);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeAuthError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _successMessage = null;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _clearMessages() {
    if (_errorMessage == null && _successMessage == null) return;
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final configured = ref.watch(isSupabaseConfiguredProvider);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandHeader(),
                          const SizedBox(height: 42),
                          Text(
                            _isSignUp ? 'Crie sua conta' : 'Bem-vindo de volta',
                            style: AppTextStyles.display(
                              size: 27,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSignUp
                                ? 'Use seu e-mail e crie uma senha para '
                                      'agendar seus horários.'
                                : 'Entre com sua conta para acompanhar e '
                                      'gerenciar seus agendamentos.',
                            style: AppTextStyles.body(
                              size: 13,
                              color: AppColors.textSecondary,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            onChanged: (_) => _clearMessages(),
                            onFieldSubmitted: (_) =>
                                _passwordFocus.requestFocus(),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Informe seu e-mail.';
                              if (!email.contains('@') ||
                                  !email.contains('.')) {
                                return 'Digite um e-mail válido.';
                              }
                              return null;
                            },
                            decoration: _fieldDecoration(
                              label: 'E-mail',
                              hint: 'voce@exemplo.com',
                              icon: Icons.alternate_email_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            onChanged: (_) => _clearMessages(),
                            onFieldSubmitted: (_) => _isSignUp
                                ? _confirmPasswordFocus.requestFocus()
                                : _submit(),
                            obscureText: _obscurePassword,
                            textInputAction: _isSignUp
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe sua senha.';
                              }
                              if (_isSignUp && value.length < 6) {
                                return 'Use ao menos 6 caracteres.';
                              }
                              return null;
                            },
                            decoration:
                                _fieldDecoration(
                                  label: 'Senha',
                                  hint: 'Sua senha',
                                  icon: Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 19,
                                      color: AppColors.textSecondary,
                                    ),
                                    tooltip: _obscurePassword
                                        ? 'Mostrar senha'
                                        : 'Ocultar senha',
                                  ),
                                ),
                          ),
                          if (_isSignUp) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              onChanged: (_) => _clearMessages(),
                              onFieldSubmitted: (_) => _submit(),
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirme sua senha.';
                                }
                                if (value != _passwordController.text) {
                                  return 'As senhas não coincidem.';
                                }
                                return null;
                              },
                              decoration:
                                  _fieldDecoration(
                                    label: 'Confirmar senha',
                                    hint: 'Repita sua senha',
                                    icon: Icons.lock_outline_rounded,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      ),
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 19,
                                        color: AppColors.textSecondary,
                                      ),
                                      tooltip: _obscureConfirmPassword
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                    ),
                                  ),
                            ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 18),
                            _AuthBanner(message: _errorMessage!, isError: true),
                          ],
                          if (_successMessage != null) ...[
                            const SizedBox(height: 18),
                            _AuthBanner(
                              message: _successMessage!,
                              isError: false,
                            ),
                          ],
                          const SizedBox(height: 26),
                          GoldButton(
                            label: _isSignUp ? 'Criar conta' : 'Entrar',
                            icon: _isSignUp
                                ? Icons.person_add_rounded
                                : Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp
                                    ? 'Já tem uma conta?'
                                    : 'Ainda não tem conta?',
                                style: AppTextStyles.body(
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading ? null : _toggleMode,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: Text(
                                  _isSignUp ? 'Entrar' : 'Cadastre-se',
                                  style: AppTextStyles.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!configured) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Credenciais do Supabase não configuradas. '
                              'Edite o arquivo .env na raiz do projeto.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(
                                size: 11,
                                color: AppColors.goldSoft,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          Text(
                            _isSignUp
                                ? 'Cadastro rápido e seus dados protegidos '
                                      'pelo Supabase Auth.'
                                : 'Acesso exclusivo para clientes cadastrados '
                                      'pela Black Mustache.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(
                              size: 11,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.border),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 19, color: AppColors.gold),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.gold),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.danger),
      ),
      labelStyle: AppTextStyles.body(size: 13, color: AppColors.textSecondary),
      floatingLabelStyle: AppTextStyles.body(size: 12, color: AppColors.gold),
      hintStyle: AppTextStyles.body(size: 13, color: AppColors.textMuted),
      errorStyle: AppTextStyles.body(size: 11, color: AppColors.danger),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
          ),
          child: const Icon(
            Icons.content_cut_rounded,
            size: 32,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'BLACK MUSTACHE',
          style: AppTextStyles.label(size: 11, letterSpacing: 3.4),
        ),
      ],
    );
  }
}

class _AuthBanner extends StatelessWidget {
  const _AuthBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.danger : AppColors.gold;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body(size: 12, color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
