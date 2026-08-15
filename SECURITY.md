# Security Policy

## Supported versions

Rijn is pre-1.0 software. Only the latest released version is supported. Please upgrade to the latest version before reporting an issue.

## Reporting a vulnerability

Do not open a public GitHub issue for a security vulnerability.

Instead, report it privately using [GitHub's private vulnerability reporting](https://github.com/matthew-moritz/rijn/security/advisories/new). If that is not available, email matthew@moritz.tech.

Include:

- A description of the vulnerability.
- Steps to reproduce it.
- The version of Rijn affected.

This is a small, independently maintained project. There is no fixed response-time guarantee, but reports will be acknowledged and addressed as soon as possible.

## Scope

Rijn provides encryption and decryption. It does not manage key storage, key rotation, key distribution, or access control. A vulnerability in how your application manages or stores keys is outside the scope of this project — see the [Security](README.md#security) and [Key management](README.md#key-management) sections of the README.
