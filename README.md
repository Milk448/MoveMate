# MoveMate

A Flutter application built collaboratively.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (≥ 3.10.0)
- Dart SDK (≥ 3.0.0)

### Installation

```bash
git clone https://github.com/Milk448/MoveMate.git
cd MoveMate
flutter pub get
flutter run
```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

---

## Collaboration

This project uses a **pull-request workflow**:

- Collaborators are invited by the repository owner (@Milk448).
- Each collaborator creates their own branch (e.g. `feature/my-feature`) and opens a pull request.
- **Only @Milk448 reviews and merges pull requests into `main`.**

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the full branching guide, commit message conventions, and PR checklist.

### Inviting a Collaborator (for @Milk448)

1. Go to **Settings → Collaborators** on GitHub.
2. Click **"Add people"** and enter the collaborator's GitHub username or email.
3. They will receive an invitation email — once accepted they can clone the repo and create branches.

### Branch Protection (recommended settings for @Milk448)

To enforce the review-before-merge rule, enable branch protection on `main`:

1. Go to **Settings → Branches → Add branch protection rule**.
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (set to **1**)
   - ✅ Require review from Code Owners
   - ✅ Do not allow bypassing the above settings

This ensures no one (not even collaborators) can push directly to `main` without your approval.

---

## CI / CD

Every push and pull request targeting `main` runs the Flutter CI workflow (`.github/workflows/flutter_ci.yml`):

- `flutter analyze` – static analysis
- `flutter test` – unit & widget tests

The status check must pass before a PR can be merged.