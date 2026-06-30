# Security Policy

## Supported versions

The latest released version receives security updates.

| Version | Supported |
|---------|-----------|
| 1.0.x   | ✅        |

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Report vulnerabilities privately via GitHub's
[Security Advisories](https://github.com/techiekrishnakayaking/tkk-eyeguard/security/advisories/new),
or contact the maintainer through the channels listed in the README.

We aim to acknowledge reports within 72 hours and to ship a fix as quickly as
the severity warrants.

## Security posture

- **Offline-first.** The app makes no network calls; all data stays on-device in
  local Hive storage.
- **No secrets in the repo.** Signing keys and certificates are supplied at build
  time via GitHub Secrets.
- **Least privilege.** Only the minimum OS permissions are requested
  (notifications; microphone *state*, not audio capture).
- **Dependency hygiene.** Dependabot and CodeQL run on every change.
- We follow the [OWASP](https://owasp.org/) and Flutter security best practices.
