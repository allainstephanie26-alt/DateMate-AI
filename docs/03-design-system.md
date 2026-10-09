# Design system

![Design system](assets/design-system.JPG)

[Design system (PDF)](assets/design-system.pdf)

## Palette

The color palette uses burgundy, pink, white, and soft neutral tones to create a warm and cohesive interface.

| Color | Hex Code | Usage |
|---|---|---|
| Primary | `#781A39` | Main buttons and headings |
| Gradient End | `#D92F70` | Gradient buttons and highlights |
| On Primary | `#FFFFFF` | Text on primary backgrounds |
| Secondary | `#F8DCE5` | Soft pink accents and selected states |
| Background | `#FFF9F7` | Main screen background |
| Surface | `#FFFFFF` | Cards and text fields |
| On Surface | `#302126` | Main text |
| Tertiary | `#F4B9C8` | Suggestion cards and accents |
| Success | `#8FBEA1` | Saved states and positive indicators |
| Error | `#B3261E` | Error messages |
| Border | `#E8D5DC` | Card outlines and dividers |

## Type Scale

| Text Style | Suggested Size | Usage |
|---|---|---|
| App Title | 28–32 px | DateMate-AI branding |
| Screen Heading | 22–24 px | Main screen titles |
| Section Heading | 16–18 px | Section titles and card headings |
| Body Text | 14–16 px | Descriptions and instructions |
| Supporting Text | 12–13 px | Locations and additional details |
| Small Labels | 10–11 px | Badges and navigation labels |

## Spacing

| Token | Value | Usage |
|---|---|---|
| `xs` | 4 px | Small gaps between icons and labels |
| `sm` | 8 px | Chip spacing and compact content |
| `md` | 12 px | Card padding and component gaps |
| `lg` | 16 px | Screen padding and section spacing |
| `xl` | 24 px | Larger gaps between sections |
| `xxl` | 32 px | Major section separation |

## Gradients

| Gradient | Usage |
|---|---|
| Primary Gradient | Main action buttons |
| Hero Card Gradient | Featured content and highlighted cards |
| Photo Overlay Gradient | Improving text readability over images |

## Components

| Component | File | Purpose | Screens Used |
|---|---|---|---|
| Primary Gradient Button | `primary_gradient_button.dart` | Displays primary actions | Login, Preferences, Recommendations |
| Selectable Chip | `selectable_chip.dart` | Displays selectable options | Couple Preferences |
| Date Suggestion Card | `date_suggestion_card.dart` | Displays recommended places and save actions | AI Recommendation |
| Bucket List Tile | `bucket_list_tile.dart` | Displays saved date ideas | Bucket List |
| Avatar Badge | `avatar_badge.dart` | Displays an avatar or profile indicator | Home Dashboard |
| Shortcut Tile | `shortcut_tile.dart` | Provides shortcuts to app features | Home Dashboard |
| Bottom Navigation Bar | `app_bottom_nav_bar.dart` | Provides navigation between main sections | Main App Screens |
| Text Fields | Flutter input widgets | Accepts user input and displays validation | Login |

## Interface Styling

- **Buttons:** Rounded shapes with clear labels and burgundy or pink gradient styling.
- **Chips:** Pill-shaped controls with distinct selected and unselected states.
- **Cards:** Rounded containers with subtle borders and consistent spacing.
- **Text Fields:** Rounded input areas with clear labels and visible input states.
- **Navigation:** Icon-based navigation with labels and a distinct active state.
- **Suggestion Cards:** Display place images, titles, locations, and date information.
- **Status Indicators:** Use distinct colors for saved items and other status states.

## Changes since the Last Version

- **Seot.24, 2026** – Documented the palette, typography, spacing, gradients, and reusable components based on the DateMate-AI design system.
- **October 4, 2026** – Organized the component reference around the five app screens to support consistent styling during implementation.