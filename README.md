# HeyMigrolino Picking App

Android mobile app for drivers picking products in migrolino.

## Project

Tracking of the progress of tasks is done in [POC: Stork Project](https://github.com/orgs/sparrow-ventures/projects/1)

IaC part of the project is covered in [StorkGCPTerraform repo](https://github.com/sparrow-ventures/StorkGCPTerraform)

## Run dev & prod

```sh
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor dev_gooods -t lib/main_dev_gooods.dart
flutter run --flavor prod -t lib/main_prod.dart
flutter run --flavor prod_gooods -t lib/main_prod_gooods.dart
```

## Build apk image dev environments

```sh
flutter build apk --release --flavor dev -t lib/main_dev.dart --split-per-abi
flutter build apk --release --flavor dev_gooods -t lib/main_dev_gooods.dart --split-per-abi
```

## Build apk image prod environments
```sh
flutter build apk --release --flavor prod -t lib/main_prod.dart --split-per-abi
flutter build apk --release --flavor prod_gooods -t lib/main_prod_gooods.dart --split-per-abi
```

## CI/CD pipeline

Build and deployment of artifacts is performed by `picking-app-dev` and `picking-app-prod` pipelines.

`picking-app-dev` pipeline is being triggered each time new tag is added to the repository.

`picking-app-prod` pipeline is being triggered manually through Actions, to trigger deployment you need to provide full tag name.

## Further reading

This application was written using Flutter, here are some additinal resourses where you can find more info:

- [Flutter Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Flutter Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Flutter online documentation](https://flutter.dev/docs)
