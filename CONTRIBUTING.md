# Contributing to MoveMate

Thank you for your interest in contributing to MoveMate! 🎉  
This document explains the workflow for collaborators.

---

## Getting Started

1. **Accept the invitation** – The repository owner will send you a collaborator invitation via GitHub. Accept it from your email or from [github.com/notifications](https://github.com/notifications).

2. **Clone the repository**
   ```bash
   git clone https://github.com/Milk448/MoveMate.git
   cd MoveMate
   ```

3. **Install Flutter** – Follow the official guide at [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install).

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

---

## Branching Strategy

> **Do not push directly to `main`.** The `main` branch is protected and only the repository owner (@Milk448) can merge pull requests into it.

### Branch naming convention

| Type        | Pattern                         | Example                          |
|-------------|---------------------------------|----------------------------------|
| Feature     | `feature/<short-description>`   | `feature/user-authentication`    |
| Bug fix     | `fix/<short-description>`       | `fix/login-crash`                |
| Improvement | `improvement/<short-description>`| `improvement/home-screen-ui`    |
| Docs        | `docs/<short-description>`      | `docs/update-readme`             |

### How to create a branch

```bash
# Always branch off of main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
```

---

## Making Changes

1. Make your changes on your feature branch.
2. Keep commits small and focused. Write clear commit messages:
   ```
   feat: add ride booking screen
   fix: resolve null pointer on login
   docs: update contribution guide
   ```
3. Run `flutter analyze` and `flutter test` before pushing:
   ```bash
   flutter analyze
   flutter test
   ```

---

## Opening a Pull Request

1. Push your branch to GitHub:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Go to [github.com/Milk448/MoveMate](https://github.com/Milk448/MoveMate) and click **"Compare & pull request"**.
3. Fill in the pull request template completely.
4. Wait for the repository owner (@Milk448) to review and merge your PR.

> **Note:** Only @Milk448 can approve and merge pull requests into `main`. You will be notified via GitHub when your PR is reviewed.

---

## Code Style

- Run `flutter analyze` – all analyzer warnings must be resolved before submitting a PR.
- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Prefer widgets in separate files under `lib/`.

---

## Need Help?

Open an issue using the **Bug Report** or **Feature Request** template and @Milk448 will respond.
