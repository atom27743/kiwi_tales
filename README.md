# KiWiTales

KiWiTales is an innovative iOS application that brings the magic of storytelling to life through AI-powered story generation. Built from the ground up using SwiftUI, it offers a seamless and engaging experience for users to create, read, and share personalized stories.

## Features

### 🎨 Story Generation
- Gemini-powered story creation with customizable themes and prompts
- Interactive story generation process
- Beautiful illustrations for each story

### 📚 Story Library
- Personal library to store and manage generated stories
- Explore section to discover stories from other users
- Detailed book view with easy navigation controls

### 👤 User Authentication
- Secure sign-in with multiple authentication methods
- User profile management
- Personal dashboard

### 🎯 Core Technologies
- SwiftUI for modern, responsive UI
- Firebase for backend services and authentication
- Custom navigation and UI components
- Generative AI integration

## Requirements
- iOS 15.0 or later
- Xcode 13.0 or later
- Firebase account for backend services

## Installation
1. Clone the repository
2. Install dependencies
3. Set up configuration files:
   - Copy `Development.xcconfig.template` to `Development.xcconfig`
   - Copy `GenerativeAI-Info.template.plist` to `GenerativeAI-Info.plist`
   - Copy `GoogleService-Info.template.plist` to `GoogleService-Info.plist`
4. Configure API keys and credentials:
   - In `Development.xcconfig`:
     - Add your Google Gemini API key
     - Add your Stability AI API key
     - Add your HuggingFace tokens
   - In `GenerativeAI-Info.plist`:
     - Add your Google Gemini API key
   - In `GoogleService-Info.plist`:
     - Replace with your Firebase configuration file from Firebase Console
5. Build and run the project

## Required API Keys
To run KiWiTales, you'll need the following API keys:

### Google Gemini AI
- Sign up at [Google AI Studio](https://ai.google.dev/)
- Create an API key for Gemini Pro

### Stability AI
- Sign up at [Stability AI](https://platform.stability.ai/)
- Create an API key for image generation

### Firebase
- Create a project in [Firebase Console](https://console.firebase.google.com/)
- Add an iOS app to your project
- Download the `GoogleService-Info.plist` configuration file

### HuggingFace (Optional)
- Sign up at [HuggingFace](https://huggingface.co/)
- Create an API token

## Architecture
The app follows a clean MVVM (Model-View-ViewModel) architecture with:
- Views: SwiftUI views for UI components
- ViewModels: Business logic and data management
- Models: Data structures and entities
- Components: Reusable UI elements

## Contact
For any questions or feedback, please reach out to the development team.
