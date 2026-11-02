# Environment Management Notes

## Important distinction
Compose's project `.env` file is commonly used for variable substitution in the Compose configuration. `env_file` passes variables from a file into a service container. They are related but not identical mechanisms.

## Security
Never commit real credentials. Use a safe `.env.example` with placeholder values and keep the real `.env` out of Git.

## My notes
- Variables used:
- How configuration was passed:
- How secrets were kept out of Git:
