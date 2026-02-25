
# GCP Network Services with Terraform (CSR + Cloud Build)

This repo provisions a full GCP networking lab with production-grade practices:

- Custom VPCs, subnets (with Flow Logs), least-privilege firewalls
- Explicit routes, Cloud NAT for private-only VMs
- VPC Peering, HA VPN (to a simulated on-prem VPC)
- External HTTPS LB (MIG backend) + Internal TCP LB
- Cloud DNS (public + private zones)
- CI/CD via Cloud Build (no secrets), SA impersonation, tfsec security scan
- Remote Terraform state on GCS with CMEK

## Prerequisites
- Project: `terraform-488518`
- Region: `asia-south1`
- gcloud SDK installed and authenticated with Owner/Org Admin (once for bootstrap)

## 1) Bootstrap once (enable APIs, create deploy SA, KMS+CMEK, state bucket, IAM)

```bash
PROJECT_ID=terraform-488518
REGION=asia-south1
./bootstrap/bootstrap.sh "$PROJECT_ID" "$REGION"
```

This will:
- Enable required services (Compute, Cloud Build, KMS, DNS, CSR, etc.)
- Create KMS keyring/key and GCS bucket `tfstate-$PROJECT_ID` (UBLA + versioning + CMEK)
- Create deploy SA `tf-deployer@$PROJECT_ID.iam.gserviceaccount.com`
- Grant least privilege to the deploy SA
- Allow Cloud Build SA to impersonate the deploy SA (no JSON keys)
- Create Cloud Source Repository `gcp-net-terraform`

## 2) Push this repo to Cloud Source Repositories

```bash
gcloud config set project terraform-488518
REPO=gcp-net-terraform

# If not already inside a git repo, initialize and commit
git init
git add .
git commit -m "Initial commit: networking lab with Terraform"

gcloud source repos create $REPO || true
git remote add google "https://source.developers.google.com/p/terraform-488518/r/$REPO" || true
git push --all google
```

## 3) Create a Cloud Build trigger (on push to `main`)

```bash
TRIGGER_NAME=terraform-net-deploy

gcloud beta builds triggers create cloud-source-repositories   --project=terraform-488518   --repo=$REPO   --branch-pattern=^main$   --build-config=cloudbuild.yaml   --substitutions=_TF_STATE_BUCKET=tfstate-terraform-488518,_TF_STATE_PREFIX=network/dev,_ENV_DIR=envs/dev
```

> Adjust substitutions for other environments (e.g., prod) as needed.

## 4) Configure variables and run via Cloud Build

Edit `envs/dev/terraform.tfvars` with your desired values (project, region, domain names, etc.). Push to `main` to trigger the pipeline.

## Notes
- The External **HTTPS** LB requires a domain you control. Point an `A` record to the LB IP. The managed cert will become **ACTIVE** afterward.
- To test performance, SSH via IAP into `vm-a`/`vm-b` and run `iperf3`.
- See `policies/` (optional) for policy-as-code; `tfsec` runs in CI.
