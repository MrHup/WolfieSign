# WolfieSign

<img src="https://i.imgur.com/TOdz9Oz.gif" alt="Manage agreements" style="max-width: 70%; height: auto;"><br>
      Manage agreements with ease.

## Frontend Dashboard


A Flutter web application that provides a modern interface for managing document signing workflows through DocuSign.

### Features 🚀

- 📝 Create and preview HTML documents in real-time
- 👥 Manage signing groups and members
- 🤖 AI-powered document editing with GPT-4
- 📊 Track document statuses and signatures
- 🔄 Real-time updates with Firebase
- 🎨 Responsive design for all screen sizes

### Prerequisites 📋

- Flutter SDK
- Firebase project
- DocuSign developer account
- OpenAI API key

### Installation Steps 🛠️

1. Clone the repository
2. Run `flutter pub get`

3. Firebase Setup:
   ```bash
   flutter pub add firebase_core
   flutterfire configure
4. Create `secrets.dart` in the lib folder:

```dart
const OPENAI_KEY = 'your-openai-key';
```

5. Configure backend connection in `envelope_service.dart`:

```dart
static const String baseUrl = 'http://localhost:5000';

```

6. Run the application:

```bash
flutter run -d chrome
```

## Backend Service

A Flask-based backend service that integrates with DocuSign API to handle document signing workflows.

### Features

- Create single and batch envelopes for document signing
- Retrieve envelope status information
- Handle multiple signers in batch operations
- Automatic consent URL generation when required

### Prerequisites

- Python 3.x
- DocuSign developer account
- JWT configuration file with required credentials

### Configuration

Create a `jwt_config.py` file with your DocuSign credentials:
```python
DS_JWT = {
    "ds_client_id": "your_client_id",
    "ds_impersonated_user_id": "your_user_id", 
    "private_key_file": "private.key",
    "authorization_server": "account-d.docusign.com"
}