# Lesson 6: Environment Management

## Overview
Learn how to manage application configuration in Docker Compose without hard-coding settings or exposing credentials.

## Learning objectives
- Pass configuration through environment variables.
- Use a project `.env` file for Compose variable substitution.
- Use `env_file` to pass variables into a service container.
- Understand the difference between `environment`, `env_file`, and `.env`.
- Use override files for different environments.
- Understand Compose secrets and their limitations.
- Keep real credentials out of Git.

## Topics
1. Environment variables
2. `environment`
3. `env_file`
4. Project `.env` and variable substitution
5. Environment-specific override files
6. Compose secrets
7. `.gitignore` and `.env.example`
8. Safe credential handling

## Practical lab
Create a Compose project that uses PostgreSQL, a project `.env` file, `env_file`, `.gitignore`, `.env.example`, and a development override file. Validate the configuration and check that real environment files are excluded from Git.

## Security reminder
A `.env` file is plain text, not encrypted. Never commit real passwords, API keys, access tokens, or other credentials.

## Lab checklist
- [ ] Study the lesson notes.
- [ ] Complete the practical lab.
- [ ] Check that real environment files are ignored by Git.
- [ ] Record what you learned in `NOTES.md`.
