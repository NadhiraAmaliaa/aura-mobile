// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'university_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Universities available in the login dropdown (login-eligible interns only).
///
/// Auto-disposed so the list is refetched each time the login screen opens.
/// Surfaces failures as an `AsyncError` so the UI can offer a retry.

@ProviderFor(universities)
final universitiesProvider = UniversitiesProvider._();

/// Universities available in the login dropdown (login-eligible interns only).
///
/// Auto-disposed so the list is refetched each time the login screen opens.
/// Surfaces failures as an `AsyncError` so the UI can offer a retry.

final class UniversitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<University>>,
          List<University>,
          FutureOr<List<University>>
        >
    with $FutureModifier<List<University>>, $FutureProvider<List<University>> {
  /// Universities available in the login dropdown (login-eligible interns only).
  ///
  /// Auto-disposed so the list is refetched each time the login screen opens.
  /// Surfaces failures as an `AsyncError` so the UI can offer a retry.
  UniversitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'universitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$universitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<University>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<University>> create(Ref ref) {
    return universities(ref);
  }
}

String _$universitiesHash() => r'9052222e44d472cfa5423a6f101557068675cd08';
