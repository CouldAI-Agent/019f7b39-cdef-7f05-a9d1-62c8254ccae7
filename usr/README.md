# AI YouTube Script Generator

A modern, mobile-friendly Flutter web application designed to help creators generate viral YouTube scripts, titles, descriptions, and metadata. Built with Flutter and Supabase, featuring user authentication, script history, and a sleek black, white, and gold UI.

## Features

- **User Authentication:** Sign up and log in using Supabase Auth (with configurable email redirect URLs).
- **Custom Script Generation:** Enter a topic and customize the output:
  - **Niches:** Motivation, Prayer, Business, Health, Finance, Technology, Lifestyle.
  - **Video Length:** 1, 3, 5, 10, or 15 minutes.
  - **Tone:** Inspirational, Professional, Friendly, Emotional, Storytelling.
- **Comprehensive Output:** Generates a viral title, complete script, 15-second hook, CTA, SEO description, 20 hashtags, and thumbnail ideas. (Currently mocked generation, ready for AI API integration).
- **History:** Save generated scripts to your Supabase account and view past creations in the History tab.
- **Modern UI:** A beautiful dashboard utilizing a black, white, and gold color scheme that looks great on mobile, tablet, and desktop.
- **Subscription Ready:** The UI and data model are prepared for future subscription tiers (Free vs Premium).

## Tech Stack

- **Frontend:** Flutter (Web/Mobile/Desktop support)
- **Backend/BaaS:** Supabase (PostgreSQL, Authentication)
- **Styling:** Custom Material 3 theme (Black, White, Gold)

## Setup & Run

1. **Clone the repository**
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Supabase Configuration:**
   - Ensure your Supabase project is linked and migrations are applied.
   - The app uses `lib/integrations/supabase.dart` for connection parameters. Ensure your environment is configured if running outside the managed preview.
4. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

## Next Steps / Future Work

- Integrate with an LLM (like OpenAI GPT-4 or Claude 3) via a Supabase Edge Function to replace the mocked script generation.
- Implement Stripe or another payment provider to enforce free vs premium generation limits.

---

## About CouldAI
This application was generated with [CouldAI](https://could.ai), an AI app builder for cross-platform apps that turns prompts into real native iOS, Android, Web, and Desktop apps with autonomous AI agents that architect, build, test, deploy, and iterate production-ready applications.
