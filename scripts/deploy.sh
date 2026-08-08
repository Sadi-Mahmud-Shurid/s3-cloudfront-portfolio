#!/usr/bin/env bash
set -euo pipefail
# --- Config ---
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
BUCKET_NAME="shurid-portfolio-${ACCOUNT_ID}"
REGION="eu-central-1"
echo "Deploying to bucket: $BUCKET_NAME in $REGION"
# --- S3 bucket (skip creation if it already exists) ---
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
 aws s3api create-bucket \
   --bucket "$BUCKET_NAME" \
   --region "$REGION" \
   --create-bucket-configuration LocationConstraint="$REGION"
 aws s3api put-bucket-versioning \
   --bucket "$BUCKET_NAME" \
   --versioning-configuration Status=Enabled
else
 echo "Bucket already exists, skipping creation."
fi
# --- Upload site content ---
aws s3 sync site/ "s3://${BUCKET_NAME}/" --delete

# --- Origin Access Control (reuse if it already exists) ---
OAC_ID=$(aws cloudfront list-origin-access-controls \
  --query "OriginAccessControlList.Items[?Name=='shurid-portfolio-oac'].Id | [0]" \
  --output te

if [ "$OAC_ID" == "None" ] || [ -z "$OAC_ID" ]; then
  OAC_ID=$(aws cloudfront create-origin-access-control \
    --origin-access-control-config \
    Name="shurid-portfolio-oac",SigningProtocol=sigv4,SigningBehavior=always,OriginAccessControlOriginType=s3 \
    --query "OriginAccessControl.Id" --output text)
  echo "Created new OAC: $OAC_ID"
else
  echo "Reusing existing OAC: $OAC_ID"
fi

echo "Deploy script complete. CloudFront distribution creation is a one-time manual/documented step — see docs/architecture.md."
