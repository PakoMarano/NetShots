# NetShots - Mobile Sports Tracker

**NetShots** is a full-stack Flutter application developed for the "Mobile Applicaition and Cloud Computing" course at **Sapienza University of Rome**. It allows users to track their sports matches (Padel), share them in a social feed, and monitor their performance evolution.

## 🚀 Architecture Overview

The project follows a clean separation of concerns:

-   **Frontend:** Flutter (Dart)
    
-   **Backend:** Custom REST API (Flask) hosted on **PythonAnywhere**.
    
-   **Database:** Relational SQLite managed via SQLAlchemy.
    
-   **Cloud Services:** Firebase Authentication and Firebase Storage.

## ✅ Requirement Satisfaction

This project satisfies all the requirements as follows:

**1 Public API**

Flask backend calls the **OpenWeatherMap API** to enrich match data with temperature and weather conditions based on coordinates.

**2 Multi-user**

Full Auth flow (Login/Register/Logout) using **Firebase Authentication**.

**3 2D Graphics**

A custom **Cumulative Score Graph** implemented using the `CustomPainter` and `Canvas` API to visualize user progress.

**4 Sensors**

**Shake Detection** implemented via raw `UserAccelerometer` stream processing to trigger the "Add Match" workflow.

**5 GPS**

Use of `geolocator` to capture match coordinates; integrated with `url_launcher` to open the location in Google/Apple Maps.

**6 Image Processing**

Automated resizing and JPEG compression of match photos using the `image` package.

**7 Concurrency**

Heavy image processing tasks are offloaded to a background **Isolate**.

**8 Cloud Feature**

Storage of profile and match pictures using **Firebase Storage**.

**9 REST API**

A custom **Flask** server provides endpoints for feed management, user relationships (follow/unfollow), and data persistence.

**10 Custom Storage**

Relational data (Users, Matches, Followers) is stored in an **SQLite** database on the server.

## 📦 Installation & Setup

### **Frontend**

1.  Navigate to the `app` folder.
    
2.  Run `flutter pub get`.
    
3.  Run `flutter run`.
    

### **Backend**

-   The backend is live at: `https://pakomarano.pythonanywhere.com`
    
-   The source code is located in the `backend` directory.
