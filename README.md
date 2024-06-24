# Traffic Sign Recognition and Navigation App

This project showcases a mobile application built with Flutter that integrates traffic sign recognition with audio feedback in the user's preferred local dialect. Additionally, it includes navigation features using Google Maps with spoken directions also in the local dialect selected by the user.

## Features

- **Traffic Sign Recognition:** Users can upload images of traffic signs from their gallery or capture them using the device's camera. The images are processed by a Flask backend to predict the meaning of the traffic signs. The prediction results are then provided to the user as audio feedback in their selected local dialect.

- **Google Maps Integration:** The app utilizes Google Maps for navigation, providing turn-by-turn directions. The spoken directions are localized to the user's selected dialect, enhancing accessibility and usability.

- **Language Preferences:** Users can choose their preferred local dialect for both traffic sign predictions and navigation directions within the app settings.

- **User Interface:** Designed with a user-friendly interface, the app offers seamless navigation between different functionalities, including image upload, audio playback of predictions, and navigation instructions.

## Technologies Used

- **Flutter:** A cross-platform UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.

- **Flask:** A lightweight WSGI web application framework in Python, used for hosting a REST API endpoint for traffic sign recognition.

- **Google Maps API:** Integrated for navigation features, providing real-time directions and spoken instructions localized to the user's preferred dialect.

- **flutter_tts:** A Flutter plugin for text-to-speech, utilized to convert text-based predictions and navigation directions into spoken audio feedback.

## Getting Started

To run this project locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/lonebhen/driving-guide-flutter
   ```

2. Set up the Flutter development environment. Refer to the [Flutter documentation](https://flutter.dev/docs/get-started/install) for installation instructions.

3. Run the Flutter app on a simulator or physical device:
   ```bash
   flutter run
   ```

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your proposed changes. For major changes, please open an issue first to discuss what you would like to contribute.

## Acknowledgments

- This project was developed as a demonstration of integrating Flutter with Flask for traffic sign recognition and Google Maps for navigation with localized audio feedback.

