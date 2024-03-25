# Photo Manager App in Flutter

In this project I created a photo manger app using the Flutter framework. This app allows you to access all the photos that are saved on your device and filter through them using their respective albums. You can also add photos to your gallery using your camera and delete photos from your device.

## Table of Contents

- [Installation](#installation)
- [Project Structure](#project-structure)
- [Contact](#contact)

## Installation

1. Make sure all Flutter and Dart dependencies are installed on your device.
2. Clone the repository.
3. Navigate to the project directory.
4. Enter 'flutter run' in the terminal to run the application.
5. Choose the desired emulator if any.

## Project Structure

- lib/: Main source code directory
- main.dart: Entry point of the Flutter app.
- pages/: Stores the pages used in the Flutter app.
- media_picker.dart: The app's main page which loads all the photos from the user's device and displayes them in a grid filtered by album. Also holds implemetations for camera and delete functionalities.
- picture_page: Page that displayes a photo if a user presses on it.
- services/: Stores the services used for implementing the app.
- media_service: service which uses the 'photo_manager' flutter package to load the albums and picture from the device's storage.

## Contact

  If you have any questions or feedback, feel free to contact me at karimkamel23@gmail.com
