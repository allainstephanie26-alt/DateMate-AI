<!--
  This is your project's front page. Replace every placeholder below.
  It is the first thing your instructor and any future employer will read, and
  the live link in it is how your project gets opened for grading.

  New here? Read START-HERE.md first. Delete this comment when you are done.
-->

# DateMate AI

> DateMate AI is a mobile-friendly date planning application that helps couples discover date ideas, manage their preferences, and save activities to a shared date bucket list.

**Live demo:** https://allainstephanie26-alt.github.io/DateMate-AI/ <!-- GitHub Pages is set up already; replace if you host elsewhere -->
**Demo video:** `docs/demo.mp4` (link it here once it exists)
**Course:** Applications Development and Emerging Technologies (6ADET), Holy Angel University
**Author:** Marimla, Allain Stephanie S.

This repository lives in the author's own GitHub account and is public on
purpose. There is no `student.json` here and there should not be one: see
`docs/06-security-and-privacy.md` for what a public repo means for secrets and
personal data.

---

## Screenshots

Put two or three real screenshots at phone size in `docs/assets/`, then replace
this paragraph with them:

### Login / Sign Up

![Login / Sign Up](docs/assets/login.png)

### Couple Preferences

![Couple Preferences](docs/assets/preferences.png)

### Home Dashboard

![Home Dashboard](docs/assets/home.png)

### AI Date Recommendation

![AI Date Recommendation](docs/assets/ai_recommendation.png)

### Date Bucket List

![Date Bucket List](docs/assets/bucket_list.png)

A repo without screenshots reads as abandoned, whatever the code says.

## What it does

DateMate AI provides a simple way for couples to plan and keep track of date activities.

- Allows users to create an account and log in to the application.
- Lets couples enter and manage their date preferences, including moods, food, activities, and locations.
- Provides date recommendations based on the selected preferences.
- Allows users to save date ideas to a personal date bucket list.
- Lets users track saved and completed date activities through the dashboard.
- Provides a mobile-style interface that can be accessed through the web using Device Preview.

## Built with

| Technology | Purpose |
| --- | --- |
| Framework | Flutter |
| Programming Language | Dart |
| State Management | `ChangeNotifier` and `setState` |
| Local Storage | Hive |
| Cloud Database | Firebase Cloud Firestore |
| Authentication | Firebase Authentication |
| Device Preview | `device_preview` |
| Other Packages | `firebase_core`, `firebase_auth`, `cloud_firestore`, `hive_flutter`, `crypto`, `cupertino_icons` |

## Running it yourself

```bash
flutter pub get
cp .env.example .env      # only if your app needs keys, see below
flutter run -d web-server --web-port 8080
```

Then open http://localhost:8080. Requires Flutter (run `flutter --version` and
put yours here).

### Environment variables

This project does not use a `.env` file. Firebase is used for authentication
and cloud synchronization through the application's Firebase configuration.
Firebase configuration values are generated and managed through the FlutterFire
configuration for the project.

| Variable | What it is | Where to get one |
| --- | --- | --- |
| `FIREBASE_API_KEY` | Identifies the Firebase project used by the application | Firebase Console → Project settings → Apps |
| `FIREBASE_PROJECT_ID` | Identifies the Firebase project connected to DateMate AI | Firebase Console → Project settings |
| `FIREBASE_APP_ID` | Identifies the registered Firebase application | Firebase Console → Project settings → Apps |

## Privacy and secrets

DateMate AI stores account information, couple preferences, date ideas, and
bucket-list activities. Local data is stored using Hive, while account and
cloud-related data are handled through Firebase Authentication and Cloud
Firestore.

The repository is public, so passwords, private keys, service-account files,
and other sensitive information should not be committed. The sample data,
screenshots, and demo video use test information and do not contain real
personal information.
## Project documentation

| Document | |
| --- | --- |
| [Proposal](docs/01-proposal.md) | the problem, the users, the scope |
| [Mockup and wireframes](docs/02-mockup.md) | what it looks like, and the screen flow |
| [Design system](docs/03-design-system.md) | colors, type, spacing, components |
| [Weekly reports](docs/04-weekly-reports.md) | what happened each week |
| [Demo video](docs/05-demo-video.md) | the recording and what it shows |
| [Start here](START-HERE.md) | how this repo works (delete once you have read it) |
| [Security and privacy](docs/06-security-and-privacy.md) | the checklist, filled in |

## Status and what is next

### Current status

The five main screens of DateMate AI are implemented: Login / Sign Up, Couple
Preferences, Home Dashboard, AI Date Recommendation, and Date Bucket List.
The application can be run locally and the web version is available through
GitHub Pages. Firebase Authentication, Cloud Firestore, and Hive are also
integrated into the project.

### Known issues

- Firebase authentication and cloud synchronization still need more testing
  on the deployed web version.
- Date recommendations can still be improved to make the results more
  personalized.
- Some user flows and data synchronization need additional testing on
  different screen sizes and devices.
- Final UI and usability testing is still needed before final submission.

### Next steps

- Finish testing the five main screens and their interactions.
- Test Firebase authentication and cloud synchronization on the live version.
- Improve the date recommendation results based on couple preferences.
- Complete the final documentation and demo video.
- Fix any remaining issues found during final testing.
  
## Credits

- Flutter and Dart — application framework and programming language
- Firebase — authentication and cloud database services
- Hive — local data storage
- Device Preview — mobile-device preview during development
- Other packages — see `pubspec.yaml` for the complete list
- UI design, application structure, and project implementation — developed for
  the DateMate AI project
- AI assistance — used for development support, debugging, and code review.

## AI use
ChatGPT and Claude were used as assistants for troubleshooting code errors
during the development of DateMate AI. They were mainly used to help identify
and resolve Flutter and Dart errors encountered during development.

## Licence

MIT, see [LICENSE](LICENSE). Change it if you want different terms.
