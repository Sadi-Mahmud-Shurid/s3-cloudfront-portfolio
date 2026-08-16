# S3 + CloudFront Portfolio Site

A static portfolio site deployed on AWS, served via CloudFront (CDN) in front of a private S3 bucket, secured with Origin Access Control (OAC). Built entirely via the AWS CLI. No console clicking, no third-party hosting.

**Live site:** https://dmn35l6sg0bps.cloudfront.net

## Why this project

Built as the first project in my hands-on cloud engineering learning path, focused on
core AWS fundamentals (IAM, S3, CDN/CloudFront) before layering on more advanced topics in later projects.

## Architecture

See [docs/architecture.md](./docs/architecture.md) for the full breakdown and diagram.

Short version: Browser -> CloudFront (HTTPS, caching) -> private S3 bucket (OAC-only access).

## AWS services used

| Service | Role |
|---|---|
| S3 | Stores and versions the static site files |
| CloudFront | CDN, HTTPS termination, edge caching |
| IAM | Scoped user for CLI access (no root credentials used) |

## Deployment

Prerequisites: AWS CLI configured with credentials that have S3 + CloudFront permissions.

```bash
./scripts/deploy.sh
```

This creates the S3 bucket (if it doesn't already exist), enables versioning, and syncs `site/` content to it. CloudFront distribution setup is a one-time manual step; see [docs/architecture.md](./docs/architecture.md) for why.
