# Contributing to TKK EyeGuard

Thanks for your interest in improving TKK EyeGuard! 💙

## Getting started

1. Fork and clone the repo.
2. Follow [`docs/BUILD.md`](docs/BUILD.md) to scaffold native folders and run.
3. Create a branch: `git checkout -b feat/my-change`.

## Before you open a PR

Run the full quality gate locally:

```bash
dart format .
flutter analyze
flutter test
```

All three must pass — CI enforces them.

## Guidelines

- Follow the existing **Clean Architecture / MVVM** structure (see
  [`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md)).
- Keep the app **lightweight**: no polling, no heavy dependencies, no
  unnecessary background work or network calls.
- Add tests for new logic.
- Use [Conventional Commits](https://www.conventionalcommits.org/) for messages
  (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Update `CHANGELOG.md` under **Unreleased**.

## Code of Conduct

By participating you agree to uphold our
[Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting bugs / requesting features

Use the GitHub issue templates. For security issues, see
[`SECURITY.md`](SECURITY.md) — please do **not** open a public issue.
