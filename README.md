# ChatApp
simple messenger for messaging. You can add friends, view their profile and exchange messages

# How to install?

* Install CocoaPods
* Open Terminal and run pod install directly.
* In order for Firebase to work, create a new project for your application.
* Download GoogleService-Info.plist from your newly created Firebase project and replace it with the old one.
* Enable Email/Password authentication method
* Create Realtime Database
* Set Realtime Database rules to:
```
{
  "rules": {
     ".read": true,
     ".write": true     
  }
}
```
* Enable your Firebase Storage
