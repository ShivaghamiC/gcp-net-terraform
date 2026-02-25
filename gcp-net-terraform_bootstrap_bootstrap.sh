
#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID=${1:?project id required}
REGION=${2:?region required}

# Enable APIs
APIS=(
  compute.googleapis.com
  cloudbuild.googleapis.com
  sourcerepo.googleapis.com
  dns.googleapis.com
  iam.googleapis.com
  iamcredentials.googleapis.com
  serviceusage.googleapis.com
  cloudkms.googleapis.com
  logging.googleapis.com
)
for api in "${APIS[@]}"; do
  gcloud services enable $api --project "$PROJECT_ID"
done

# KMS for state bucket
KEYRING=tf-state
KEY=state-key
LOCATION=global
if ! gcloud kms keyrings describe $KEYRING --location=$LOCATION --project=$PROJECT_ID >/dev/null 2>&1; then
  gcloud kms keyrings create $KEYRING --location=$LOCATION --project=$PROJECT_ID
fi
if ! gcloud kms keys describe $KEY --location=$LOCATION --keyring=$KEYRING --project=$PROJECT_ID >/dev/null 2>&1; then
  gcloud kms keys create $KEY --location=$LOCATION --keyring=$KEYRING --purpose=encryption --project=$PROJECT_ID
fi
KMS_KEY="projects/$PROJECT_ID/locations/$LOCATION/keyRings/$KEYRING/cryptoKeys/$KEY"

# GCS bucket for Terraform state (UBLA + versioning + CMEK)
BUCKET=tfstate-$PROJECT_ID
if ! gsutil ls -p $PROJECT_ID gs://$BUCKET >/dev/null 2>&1; then
  gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET
fi
# Uniform bucket-level access
gsutil uniformbucketlevelaccess set on gs://$BUCKET
# Versioning
gsutil versioning set on gs://$BUCKET
# Default KMS key
gsutil kms encryption -k $KMS_KEY gs://$BUCKET

# Deploy service account
DEPLOY_SA=tf-deployer
DEPLOY_SA_EMAIL="$DEPLOY_SA@$PROJECT_ID.iam.gserviceaccount.com"
if ! gcloud iam service-accounts describe $DEPLOY_SA_EMAIL --project $PROJECT_ID >/dev/null 2>&1; then
  gcloud iam service-accounts create $DEPLOY_SA --display-name "Terraform Deployer" --project $PROJECT_ID
fi

# Least-privilege roles for deployer
ROLES=(
  roles/compute.networkAdmin
  roles/compute.securityAdmin
  roles/dns.admin
  roles/iam.serviceAccountUser
  roles/logging.configWriter
)
for r in "${ROLES[@]}"; do
  gcloud projects add-iam-policy-binding $PROJECT_ID     --member serviceAccount:$DEPLOY_SA_EMAIL     --role $r >/dev/null
done
# Storage perms only on state bucket
gsutil iam ch serviceAccount:$DEPLOY_SA_EMAIL:objectAdmin gs://$BUCKET
# KMS encrypt/decrypt on the state key
gcloud kms keys add-iam-policy-binding $KEY --location=$LOCATION --keyring=$KEYRING   --member serviceAccount:$DEPLOY_SA_EMAIL --role roles/cloudkms.cryptoKeyEncrypterDecrypter --project $PROJECT_ID >/dev/null

# Allow Cloud Build SA to impersonate deployer
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
CB_SA="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"
gcloud iam service-accounts add-iam-policy-binding $DEPLOY_SA_EMAIL   --member serviceAccount:$CB_SA   --role roles/iam.serviceAccountTokenCreator --project $PROJECT_ID >/dev/null

echo "
Bootstrap complete. State bucket: gs://$BUCKET, Deploy SA: $DEPLOY_SA_EMAIL"
echo "Remember to set deploy_sa_email in envs/*/terraform.tfvars to $DEPLOY_SA_EMAIL"
