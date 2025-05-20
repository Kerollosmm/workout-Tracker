---
trigger: always_on
---

# 📜 Flutter Project Development Rules

This file defines the coding standards and contribution rules for the project. Follow these guidelines strictly to maintain consistency and stability.

---

## ✅ General Guidelines

1. **Preserve Core Logic**
   - Do **not remove or refactor** the main architecture or existing components unless specifically required.
   - All current features must continue working after updates.

2. **Add, Don’t Replace**
   - New features or UI improvements must be **added** in a way that does **not interfere** with existing code.
   - Wrap or extend components instead of modifying them directly, when possible.

3. **Use Comments with Dates**
   - Every update must include a comment with:
     - 📅 The date of change
     - 📝 A short explanation  
     Example:
     ```dart
     // Updated 2025-05-20: Added file picker to allow save location for Excel export
     ```

---

## 🎨 UI & Design Rules

1. **Custom Design Integration**
   - When enhancing the UI, follow the design reference provided (e.g., layout, spacing, style).
   - Use Cupertino widgets when mimicking iOS designs.

2. **Dark and Light Mode**
   - Ensure **complete support** for both light and dark modes.
   - Text, icons, and widgets must remain visible and aesthetically pleasing in both themes.

3. **Reusable Components**
   - Create modular and reusable widgets (e.g., custom cards, buttons) to reduce repetition and improve maintainability.

---

## 💾 Feature-Specific Rules

1. **Offline Sign-In Page**
   - Use local storage (`shared_preferences`, SQLite, etc.) to store user body data.
   - Display the data clearly in the Profile screen.

2. **Excel Export**
   - Integrate a file picker to allow users to **select save location**.
   - Ensure platform compatibility.

3. **History Screen**
   - Display workout history grouped by **exercise**, not date.
   - Show:
     - Weight lifted
     - Reps
     - Date performed
     - Difficulty tag (e.g., "easy", "hard", emoji)

---

## 🧪 Testing and Stability

1. **Test All Updates**
   - Manually test all new features before finalizing.
   - Ensure updates don’t break existing functionality.

2. **Responsive Design**
   - All screens must adapt well to different screen sizes (phones, tablets).

---

## 📁 File Structure and Naming

1. **Organized Folder Structure**
   - Use clear folder names: `widgets`, `screens`, `models`, `services`, etc.

2. **File Naming**
   - Use lowercase_with_underscores for file names (`sign_in_screen.dart`).

---

## 🔒 Commit & Versioning

1. **Descriptive Commits**
   - Write clear commit messages:
     - `feat: added offline sign-in`
     - `fix: corrected light mode bug on history screen`

2. **Backup Before Major Changes**
   - Always back up the project before introducing large updates or restructuring.

---

## 🚀 Final Note

Always prioritize:
- **Clarity**
- **Maintainability**
- **User experience**

Follow these rules to ensure smooth collaboration and future-proof development.

