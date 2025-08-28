# TaskList Flutter App

*Github Repository url: (https://github.com/acidleo/TaskApp)*


# *Overview*

TaskList is a Flutter app that allows users to create, view, update, and share tasks. Each task is tied to the authenticated user in Firebase Firestore. The app supports offline caching for previously loaded tasks and provides PDF export functionality for task sharing.


# *How to run the Application*

Login / Signup:
    Users need to sign up or log in using their email and password.
    Once a user logs in, their session persists across app restarts and they remain logged in until manually logging out; no automatic logout occurs on app closure or inactivity.

Home Screen / Dashboard:
    Displays count summary of the tasks (Total, Completed, Pending).
    Provides navigation to the task list page.

Add Tasks:
    Tap the + button in the tasklist page to add a new task.
    Enter title, description, and status (Pending/Completed).

View Task List:
    Tasks are displayed in a list.
    Offline support shows previously fetched tasks (from memory) when no internet is available.

Task Details:
    Tap a task to see detailed information.
    You can edit or update tasks using the edit button.

Share Tasks:
    Use the Share icon on the list or detail screen to generate a PDF of tasks and share it via other apps.

Offline Limitation:
    Only tasks fetched during the current session are cached in memory. Closing the app will clear the cache.


# *Libraries / Tools Used*

Flutter SDK – UI development
Firebase Auth – user authentication
Cloud Firestore – cloud database for storing tasks
Provider – state management
PDF & Printing – exporting tasks as PDF


# *Trade-offs / Assumptions*

The app displays tasks only for the logged-in user; cross-user task sharing is not implemented.
Offline support is limited to tasks fetched during the current session; tasks are cached in memory and not persisted across app restarts.
PDF export is basic and only includes task ID, title, description, and status.

*Demo User*
 Demo User 1
    Mail ID: harilalthampy@gmail.com
    Password: Harilal@123
 Demo User 2
    Mail ID: harilalgle@gmail.com
    Password: Hari2002

