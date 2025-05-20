# 🛠️ Flutter Project Improvement Plan

## 📋 Overview

This document outlines the planned enhancements for the Flutter project. The changes aim to improve UI design, add new features, and enhance user experience, **without altering or removing the core logic or main components**.

All updates must include **comments with the update date and purpose**.

---

## ✅ Enhancement Tasks

### 1. Code Design Upgrade
- Improve the overall UI/UX based on a custom design that will be provided.
- Follow modern design principles (proper padding, alignment, color usage).
- Use reusable components where possible for consistency.

### 2. Offline Sign-In Page
- Create an **offline sign-in screen** using **iOS-style (Cupertino) widgets**.
- Save user input such as body stats locally (e.g., using `shared_preferences` or local storage).
- Display this stored data on the **Profile Page** in a user-friendly format.

### 3. Export to Excel – Save Location
- Update the Excel export feature to allow the user to **choose the save location** using a platform-aware file picker.

### 4. History Screen Redesign
- Restructure the History screen to group workout logs **by exercise name** (not by date).
- For each exercise, show:
  - Dates it was performed
  - Weight used
  - Number of reps
  - An indicator if it was hard (e.g., emoji or text like "🔥 Hard")

### 5. Light and Dark Mode Enhancement
- Review and polish the UI for both light and dark themes.
- Ensure proper text contrast, icon color, and background styling in each mode.

---

## 🧾 Development Rules

- ❌ **Do not delete** or heavily modify existing components or logic.
- ✅ **Add** new features and enhance UI without disrupting the core architecture.
- 🗓️ Add **code comments** noting the **date** and a brief **description of changes** (e.g., `// Updated 2025-05-20: Added offline sign-in feature`).

---

Let me know when you’re ready to provide the design reference or if you’d like this file exported.
