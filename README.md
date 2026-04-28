# Support Mobile

Flutter prototype repo for the support feature.

## Current Setup

- Flutter app package: `support_mobile`
- Platforms: Android and iOS
- UI foundation: Material 3 with light/dark tokens from `Theme/`
- Typeface: Google Sans Flex registered from `Font/static`
- Starter surface: support overview, quick-help categories, recent activity, and bottom navigation

## Project Structure

```text
lib/
  app/
    support_mobile_app.dart
  features/
    support/
      domain/
      presentation/
  theme/
    app_theme.dart
    support_tokens.dart
```

The `Theme/` folder is treated as the design-token source. The app currently
maps the light/dark color roles, shape radii, and type scale into
`lib/theme/support_tokens.dart`.

## Common Commands

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

The generated counter app has been removed so the next pass can focus directly
on the Material 3 theming and supplied support screens.
