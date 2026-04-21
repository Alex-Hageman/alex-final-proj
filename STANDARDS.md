# STANDARDS.md: Technical & Design Standards

## 01 — Project Overview
* **Project Name:** MacroLog
* **Core Purpose:** A manual, high-precision macronutrient tracker designed to build nutritional awareness and consistency through a "calculator-like" interface.
* **Primary User:** Meal preppers and fitness enthusiasts focused on performance and habit-building who prefer intentional data entry over automated estimates.

## 02 — Technical Standards
* **Language:** Use semantic HTML5 and CSS3 only (no external JavaScript frameworks unless explicitly requested).
* **Responsiveness:** The application must be "Mobile-First." Use Flexbox or CSS Grid to ensure the dashboard and entry forms scale correctly from mobile screens to desktop monitors.
* **Code Quality:** Use clear, descriptive class names (e.g., `.macro-card`, `.entry-form`) and include brief comments in the CSS to organize sections.

## 03 — Design Standards
* **Color Palette:**
    * **Primary Action:** #2E7D32 (Deep Green - representing "Log Completion" and health).
    * **Background:** #F5F5F5 (Light Grey - clean, clinical feel for data accuracy).
    * **Accents:**
        * Protein: #1976D2 (Blue)
        * Carbs: #FBC02D (Yellow/Gold)
        * Fats: #D32F2F (Red)
* **Typography:**
    * **Headings:** Sans-serif (e.g., 'Inter' or 'Roboto') for a modern, tech-focused look.
    * **Body/Data:** Monospace (e.g., 'Roboto Mono') for numeric values in the calculator and history table to ensure alignment and readability.
* **Layout:**
    * **Navigation:** A fixed global navigation bar at the top or side to prevent "dead-ends" identified in usability testing.
    * **Dashboard:** Use circular progress rings for macros, ensuring each has an explicit label (P, C, F) and unit (g).

## 04 — Accessibility & Performance
* **Labels:** Every input field (Protein, Carbs, Fats, Calories) must have a `<label>` tag for screen readers.
* **Alt Text:** All icons and images must include descriptive `alt` attributes.
* **Contrast:** Ensure text-to-background contrast ratios meet WCAG AA standards (at least 4.5:1) for readability.

## 05 — Writing Voice & Tone
* **Tone:** Efficient, clinical, and encouraging.
* **Language:** Avoid flowery marketing speak. Focus on data-centric terms like "Log Completion," "Macro Targets," and "Nutritional Awareness".