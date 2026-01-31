import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:libriflow/features/auth/presentation/views/login_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  User? _lastUser;

  void _initializeControllers(User user) {
    _nameController ??= TextEditingController(text: user.name);
    _emailController ??= TextEditingController(text: user.email);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image != null && mounted) {
      setState(() {
        _selectedImage = image;
        _isUploading = true;
      });
      context.read<ProfileBloc>().add(UploadProfileImageEvent(image.path));
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final authBox = await Hive.openBox('auth');
    await authBox.clear();
    ApiClient().setToken('');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(GetProfileEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded || state is ProfileUpdated) {
            final user = (state is ProfileLoaded) ? state.user : (state as ProfileUpdated).user;

            setState(() {
              _lastUser = user;
              _isUploading = false;
              // Keep _selectedImage if backend URL not ready
            });

            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Update Successful')),
              );
              // Refresh profile from backend
              context.read<ProfileBloc>().add(GetProfileEvent());
            }
          } else if (state is ProfileError) {
            setState(() => _isUploading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          User? user = _lastUser;
          if (state is ProfileLoaded || state is ProfileUpdated) {
            user = (state is ProfileLoaded) ? state.user : (state as ProfileUpdated).user;
            _initializeControllers(user);
            _lastUser = user;
          }

          if (user == null) {
            return const Center(child: Text('Error loading profile'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (_selectedImage != null)
                            ? FileImage(File(_selectedImage!.path))
                            : (user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty)
                                ? NetworkImage(user.avatarUrl!)
                                : const AssetImage('assets/images/Logo.png')
                                    as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            onPressed: _showImageSourceActionSheet,
                          ),
                        ),
                      ),
                      if (_isUploading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Username')),
                  TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const Divider(height: 40),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(UpdateProfileEvent(
                            name: _nameController!.text,
                            email: _emailController!.text,
                            password: _passwordController.text.isEmpty
                                ? null
                                : _passwordController.text,
                            confirmPassword:
                                _confirmPasswordController.text.isEmpty
                                    ? null
                                    : _confirmPasswordController.text,
                          ));
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
