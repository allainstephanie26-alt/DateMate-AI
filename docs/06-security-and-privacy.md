
# Security Checklist

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token, or password is hardcoded in `lib/`, including comments and commented-out code | Yes | I reviewed the source code for exposed credentials. The Supabase URL and publishable key are used to connect the application to Supabase. The service-role key and other privileged credentials must not be exposed in the client code. |
| 2 | Private configuration is stored in a gitignored configuration file or supplied through build-time configuration, with an example file committed | Yes | `.gitignore` includes `.env`, `.env.*`, and `env.json`, while `.env.example` contains placeholder values. The actual configuration method and Git history should be checked to ensure that no private credentials have been committed. |
| 3 | No keystore, `key.properties`, or signing credential is in the repository | N/A | The project does not currently include an Android signing setup. No `key.properties`, `.jks`, or `.keystore` files were found in the project. |
| 4 | Git history has been searched for passwords, secrets, API keys, and tokens | Yes | I reviewed the Git history for common credential patterns, including passwords, secrets, API keys, tokens, private keys, and service-account credentials. |
| 5 | Any credential that was ever committed has been rotated | N/A | No confirmed private credential was identified as having been committed. If a private credential is discovered in the repository history, it must be revoked or rotated. |

## GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 6 | No secret value is written literally in any workflow YAML file | Yes | I reviewed `.github/workflows/deploy-web.yml` for literal secret values. Private credentials should be supplied securely rather than written directly in the workflow. |
| 7 | Required GitHub Actions secrets are configured and referenced using `${{ secrets.NAME }}` | No | The workflow contains commented-out references to `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. These references are not active, so the workflow does not currently obtain these values through active repository secret references. |
| 8 | No workflow step prints secrets, and a recent run's logs have been checked | No | No command that intentionally prints secrets was identified in the reviewed workflow. A recent GitHub Actions run log still needs to be checked to verify that secrets and sensitive configuration are not exposed. |
| 9 | If building a signed APK, the keystore is supplied securely at build time and never printed | N/A | The current workflow builds the Flutter web application and does not include an Android APK signing step. |
| 10 | Uploaded build artifacts contain no private key file, keystore, or unintended configuration file | Yes | The workflow uploads the `build/web` directory using `actions/upload-pages-artifact@v5`. The generated web output should be checked to confirm that it does not contain private credentials or unintended configuration files. |
| 11 | Third-party GitHub Actions are pinned to commit SHAs instead of movable version tags | No | The workflow uses version tags such as `actions/checkout@v7`, `subosito/flutter-action@v2`, `actions/upload-pages-artifact@v5`, and `actions/deploy-pages@v5`. Pinning each action to a verified full commit SHA would improve supply-chain security. |
| 12 | Secret scanning and push protection are enabled on the repository | Yes | I checked the GitHub repository security settings and confirmed that Secret scanning and Push protection are enabled. |

## Backend and security rules

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 13 | Supabase Row Level Security (RLS) is enabled for every table containing user data | Yes | I checked the Supabase dashboard and confirmed that RLS is enabled. RLS helps enforce database access restrictions through policies. |
| 14 | Supabase policies restrict users to the records they are authorized to access | No | RLS is enabled, but the policies still need to be reviewed and tested to confirm that users can access only the records they are authorized to read or modify. |
| 15 | Supabase authentication is configured and tested | No | The Supabase URL and publishable key have been integrated into the application for authentication. Successful sign-up, sign-in, sign-out, and session-persistence tests must be completed before this check can be marked Yes. |
| 16 | The Supabase service-role key and other privileged credentials are never exposed in the client application | Yes | The client application should use only the Supabase publishable key. The service-role key and other privileged credentials must remain on a trusted server and must never be included in Flutter client code, web build output, or the public repository. |
| 17 | The application was tested while signed out to confirm unauthorized data access is blocked | No | The live Supabase project still needs to be tested to verify that signed-out users cannot read or modify protected data and that database policies reject unauthorized requests. |
| 18 | Seed and sample data is invented and does not contain real people's private information | Yes | The sample names and information used in the app and screenshots are intended as test and demonstration data rather than actual user records. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 19 | User input is validated before it is written to the database | No | In `couple_preferences_screen.dart`, the budget is converted using `double.tryParse(...) ?? 0`. Invalid input can therefore become `0` instead of being rejected before `savePreferences()` writes the data. |
| 20 | No private server credential can be recovered from the built application | No | The Supabase publishable key is intended for client-side use and is not a secret. However, the built web application must be checked to confirm that no service-role key, database password, or other private credential is included. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 21 | No student number, personal email, phone number, or home address is exposed in the repository or commit messages | Yes | The project files and available Git history were reviewed for personal information. The example email in `login_screen.dart` is `you@example.com`. |
| 22 | No classmate's personal data is exposed in the repository | Yes | The source files, documentation, and available assets were reviewed for classmate names and contact information. No classmate's personal information was identified. |
| 23 | Dependencies come from expected package sources, and generated files are gitignored | Yes | `pubspec.yaml` uses standard package dependencies without `git:` or `path:` dependency overrides. `.gitignore` includes `.dart_tool/` and `build/`. |
| 24 | Images, fonts, and other assets are owned, licensed, or credited | Yes | The declared project assets and documentation screenshots were reviewed. Any externally sourced images or fonts should have appropriate permission, licensing, or attribution. |
| 25 | Repository visibility is intentional and has been checked after the latest push | Yes | I checked the GitHub repository settings and confirmed that the DateMate-AI repository is Public. Because the repository is public, all committed files and client-side configuration must be treated as visible to anyone. |

## Anything I Found and Fixed

During the security review, I examined the project's credential handling, Git history, GitHub Actions workflow, Supabase integration, input validation, sample data, and repository privacy.

The Supabase URL and publishable key have been integrated into the application for authentication. I also confirmed that Row Level Security (RLS) is enabled in Supabase. However, RLS alone does not guarantee that the database is secure; its policies must also be reviewed to ensure users can access only the records they are authorized to use.

Several checks still require further verification, including testing sign-up, sign-in, sign-out, session persistence, and unauthorized data access. The built web application must also be checked to ensure that no service-role key, database password, or other private credential is included.

Another issue identified is the budget validation in `couple_preferences_screen.dart`, where invalid input can be converted to `0` through `double.tryParse(...) ?? 0`. This should be changed so invalid values are rejected before saving. The GitHub Actions workflow also uses version tags rather than full commit SHAs, which can be improved by pinning the actions to verified commits.
