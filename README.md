<!--
  This is your project's front page. Replace every placeholder below.
  It is the first thing your instructor and any future employer will read, and
  the live link in it is how your project gets opened for grading.

  New here? Read START-HERE.md first. Delete this comment when you are done.
-->

# DateMate AI

> DateMate AI is a mobile-friendly date planning application that helps couples discover date ideas, manage their preferences, and save activities to a shared date bucket list.

**Live demo:** https://allainstephanie26-alt.github.io/DateMate-AI/ <!-- GitHub Pages is set up already; replace if you host elsewhere -->
**Demo video:** `docs/demo.mp4` https://drive.google.com/file/d/1F0AOerwApI-A3Kt_fmHVDIr9IDVQScZX/view?usp=sharing
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

<img width="356" height="621" alt="image" src="https://github.com/user-attachments/assets/5d679aa5-0fb3-4d6c-9809-840d2c67574b" />

### Couple Preferences

<img width="386" height="618" alt="image" src="https://github.com/user-attachments/assets/45a89c51-f597-4380-937e-3e1f79f62cf7" />

### Home Dashboard

<img width="389" height="619" alt="image" src="https://github.com/user-attachments/assets/d46bfceb-7edd-412e-b6b6-2d3d09a6db5a" />

### AI Date Recommendation

<img width="355" height="621" alt="image" src="https://github.com/user-attachments/assets/2362bb63-4a53-4e7d-b18b-245036d6eb41" />

<img width="341" height="617" alt="image" src="https://github.com/user-attachments/assets/4e0ce666-85d6-495a-91d3-9e3bf4388d89" />

### Date Bucket List

<img width="391" height="620" alt="image" src="https://github.com/user-attachments/assets/89c51d2b-e9f1-4211-8865-080addb414ad" />

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
| Cloud Database | Supabase (PostgreSQL + Row Level Security + Realtime) |
| Authentication | Supabase Auth (email + password, email confirmation) |
| Device Preview | `device_preview` |
| Other Packages | `supabase_flutter`, `hive_flutter`, `crypto`, `cupertino_icons` |
 
## Running it yourself
 
```bash
flutter pub get
cp .env.example .env      # only if your app needs keys, see below
flutter run -d web-server --web-port 8080
```
 
Then open http://localhost:8080. Requires Flutter (run `flutter --version` and
put yours here).
 
### Environment variables
 
Supabase powers authentication and cloud sync. The project URL and publishable
key have working defaults in `lib/services/cloud_sync_service.dart`, so a plain
`flutter run` works. To point the app at another Supabase project, override
them with `--dart-define` (or repository secrets for the deploy workflow).
| Variable | What it is | Where to get one |
| --- | --- | --- |
| `https://mmsvqcmqmfjfndchivpa.supabase.co` | Your Supabase project URL | Supabase Dashboard → Project Settings → API |
| `sb_publishable_2lzJ9PeGlnC5ryj3GR-SWAQ_glWyz5Qy` | Public client key (safe to ship; RLS protects the data) | Supabase Dashboard → Project Settings → API Keys |
| `https://allainstephanie26-alt.github.io/DateMate-AI/` (optional) | Where confirmation / reset emails return to | Your deployed URL; also add it to Authentication → URL Configuration |
 
Never put the `service_role` / secret key or a Gemini key in the app.
 
### Setting up the Supabase backend
 
1. Run `supabase/migrations/0001_init.sql` in the Supabase SQL editor.
2. Run the checks in `supabase/verify_setup.sql` (all tables, the
   `on_auth_user_created` trigger, and the policies must exist).
3. Authentication → Providers → Email: enabled.
4. Authentication → URL Configuration: set the Site URL and add your Redirect
   URLs (the GitHub Pages URL and `http://localhost:8080/**`).
5. Optional AI chat: `supabase secrets set GEMINI_API_KEY=...` then
   `supabase functions deploy datemate-chat`.

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
Claude is used as assistants for troubleshooting code errors
during the development of DateMate AI. It is only mainly used to help identify
and resolve Flutter and Dart errors encountered during development.

## Licence

MIT, see [LICENSE](LICENSE). Change it if you want different terms.
