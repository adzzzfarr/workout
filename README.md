# workout

Workout Logging App built using Flutter, Hive, and Firebase.

I created the app with a local-first software paradigm in mind; Hive Database to first handles all minor changes and saves them locally, before the final data is pushed to the Firebase Firestore cloud database tagged to a user's FirebaseAuth credentials.

Functionality includes:
- Log in and Sign up, including with a Google account
- A dashboard which displays:
  - a bar chart showing weekly workouts over the past 4 weeks
  - a pie chart showing the number of sets targetting each body part in all workouts performed over the current week
- Custom exercises that can be added by the user (alongside a list of default exercises)
  - All instances of a particular exercise (including past set data) can be viewed at a glance
- Custom workouts that can be customised according to the user's preferences
  - Users can time their rests
  - Dynamically change set data such as weight used and reps performed as you perform the workout
- A list view of all past completed workouts, along with a calendar that reflects all of them over time.
