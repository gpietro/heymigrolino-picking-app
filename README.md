# demo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Run dev & prod
`flutter run --flavor dev -t lib/main.dart`
`flutter run --flavor dev_gooods -t lib/main_dev_gooods.dart`
`flutter run --flavor prod -t lib/main_prod.dart`
`flutter run --flavor prod_gooods -t lib/main_prod_gooods.dart`

## Build apk image dev environments
`flutter build apk --release --flavor dev -t lib/main.dart --split-per-abi`
`flutter build apk --release --flavor dev_gooods -t lib/main_dev_gooods.dart --split-per-abi`
## Build apk image prod environments
`flutter build apk --release --flavor prod -t lib/main_prod.dart --split-per-abi`
`flutter build apk --release --flavor prod_gooods -t lib/main_prod_gooods.dart --split-per-abi`