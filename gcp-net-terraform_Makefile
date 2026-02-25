
TF_DIR ?= envs/dev

fmt:
	terraform -chdir=$(TF_DIR) fmt

validate:
	terraform -chdir=$(TF_DIR) init -backend=false
	terraform -chdir=$(TF_DIR) validate

plan:
	terraform -chdir=$(TF_DIR) init
	terraform -chdir=$(TF_DIR) plan -out tfplan

apply:
	terraform -chdir=$(TF_DIR) apply -auto-approve tfplan

clean:
	rm -f $(TF_DIR)/tfplan
