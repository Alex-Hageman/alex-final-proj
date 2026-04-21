# MacroLog

A manual, high-precision macronutrient tracker for meal preppers and fitness enthusiasts.

## Project Overview

MacroLog provides a "calculator-like" interface for intentional macro tracking, prioritizing nutritional awareness and consistency over automated estimates.

## Tech Stack

- **Frontend:** Vanilla HTML5 + CSS3 (no frameworks)
- **Server:** Python 3 built-in HTTP server
- **Fonts:** Inter (headings) + Roboto Mono (numeric data) via Google Fonts

## Project Structure

```
index.html    — Main application (dashboard, log form, history)
style.css     — All styles following STANDARDS.md design tokens
base.html     — Empty base template (placeholder)
STANDARDS.md  — Technical and design standards reference
PRD.md        — Product Requirements Document
README.md     — Project introduction
```

## Running the App

The app is served via Python's built-in HTTP server:

```
python3 -m http.server 5000 --bind 0.0.0.0
```

Access at port 5000.

## Design Standards (from STANDARDS.md)

- **Colors:** Primary #2E7D32 (green), Background #F5F5F5, Protein #1976D2, Carbs #FBC02D, Fats #D32F2F
- **Typography:** Inter for headings, Roboto Mono for numeric values
- **Layout:** Mobile-first, fixed nav bar, circular progress rings for macros
- **Accessibility:** WCAG AA contrast, labeled inputs, alt text on all images
