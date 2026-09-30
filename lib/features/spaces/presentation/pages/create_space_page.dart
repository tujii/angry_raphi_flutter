import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../../domain/usecases/create_space.dart';
import '../cubit/create_space_cubit.dart';
import '../widgets/signed_in_builder.dart';

/// Form to create a new space (`/spaces/new`); the creator becomes its owner.
class CreateSpacePage extends StatelessWidget {
  const CreateSpacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignedInBuilder(
      builder: (context, user) => BlocProvider(
        create: (context) =>
            CreateSpaceCubit(CreateSpace(context.read<SpacesRepository>())),
        child: _CreateSpaceForm(user: user),
      ),
    );
  }
}

class _CreateSpaceForm extends StatefulWidget {
  final UserEntity user;

  const _CreateSpaceForm({required this.user});

  @override
  State<_CreateSpaceForm> createState() => _CreateSpaceFormState();
}

class _CreateSpaceFormState extends State<_CreateSpaceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = widget.user;
    context.read<CreateSpaceCubit>().submit(CreateSpaceParams(
          name: _nameController.text,
          description: _descriptionController.text,
          ownerUid: user.id,
          ownerDisplayName: user.displayName,
          ownerEmail: user.email,
          ownerPhotoUrl: user.photoURL,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<CreateSpaceCubit, CreateSpaceState>(
      listener: (context, state) {
        if (state is CreateSpaceSuccess) {
          context.go(AppRouter.space(state.spaceId));
        } else if (state is CreateSpaceFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
        }
      },
      builder: (context, state) {
        final submitting = state is CreateSpaceSubmitting;
        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          appBar: AppBar(
            title: Text(l10n?.createSpace ?? 'Bereich anlegen'),
          ),
          body: ResponsiveHelper.wrapWithMaxWidth(
            context: context,
            maxWidth: 600,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !submitting,
                    autofocus: true,
                    maxLength: CreateSpace.maxNameLength,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n?.spaceNameLabel ?? 'Name des Bereichs',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? (l10n?.spaceNameRequired ??
                            'Bitte gib einen Namen ein')
                        : null,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !submitting,
                    maxLength: CreateSpace.maxDescriptionLength,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n?.spaceDescriptionLabel ??
                          'Beschreibung (optional)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n?.createSpace ?? 'Bereich anlegen'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
