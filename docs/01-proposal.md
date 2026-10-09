# Proposal

## The problem, in one sentence
Couples sometimes struggle to decide where to eat, where to go, or what activities to do together because choosing a date that matches both of their preferences, budget, and location can take time.
## Who it is for
DateMate-AI is designed for couples who want an easier way to plan dates together. It is suitable for couples who want to discover places to visit, find food options, organize activities, and save date ideas for future plans.
## Core features
- User accounts: Users can create accounts and sign in to access their saved information.
- Couple connection: Users can connect with their partners through a couple code to synchronize their date-planning information.
- Couple preferences: Users can select their preferred food categories, activities, locations, and budget.
- Date recommendations: The app provides date suggestions based on the couple's selected preferences, including places in the Philippines.
- DateMate AI chat: Users can interact with an AI chat assistant for date-planning ideas and suggestions.
- Bucket list: Users can save date suggestions and manage their planned or future date activities.
- Cloud synchronization: Supabase stores and synchronizes supported account and couple data across devices, while local storage supports app data access.
## Out of scope, and why
- Online reservations and purchases: The app helps couples discover and plan dates but does not directly book restaurants, purchase tickets, or process payments.
- Real-time location tracking: The app does not continuously track users because it is not necessary for its main date-planning functions.
- Automatic scheduling and calendar integration: The app focuses on discovering and saving date ideas rather than managing complete calendar schedules.
- Guaranteed AI accuracy: AI-generated suggestions may require users to verify details such as availability, prices, and operating hours before visiting.
- Locations outside the Philippines: Recommendations are focused on Philippine destinations to keep the suggestions relevant to the intended users.
## Data the app remembers, and where it is saved
- Account information: Account details and authentication are managed through Supabase Authentication.
- User and couple profiles: Profile information and couple connections are stored in the Supabase database.
- Preferences: Selected food categories, activities, location preferences, and budget are saved so recommendations can reflect the users' choices.
- Bucket list and saved dates: Saved date ideas and related information are stored locally and synchronized through Supabase where supported.
- AI chat: Chat interactions may be processed by the configured AI service. Persistent storage depends on the app's implemented chat-saving functionality.
- Local app data: Local storage helps retain supported information on the user's device and improve access to saved content.

Sensitive credentials, such as Supabase service-role keys, should not be stored in the client application.
## Risks
- Incorrect or outdated place information: Some recommended locations may have outdated prices, operating hours, or availability. Users should verify details before visiting.
- Internet connectivity: Cloud synchronization, account authentication, and AI chat may require a working internet connection.
- Account and data security: Improper access controls could expose personal or couple information. Authentication, appropriate database permissions, and Row Level Security (RLS) are important safeguards.
- AI-generated errors: AI responses may be inaccurate or unsuitable for the selected preferences, so suggestions should be treated as planning assistance rather than guaranteed information.
- Synchronization issues: Network interruptions or database errors may delay updates between connected accounts or devices.
## Changes since the last version
Sept.27, 2026: Refined the app's interface and user experience to make the five main screens more consistent and easier to navigate.
Sept.29, 2026: Improved preference-based recommendations so suggested places and activities better match the couple's selected options.
Oct.4, 2026: Refined account, couple-connection, and cloud synchronization functionality to support shared date-planning information.
Oct.4, 2026: Improved the bucket list and saved-date workflow so users can organize ideas for future dates more easily.

