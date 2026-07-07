ENVNAME=
PROJECT=aicoe
PROJECT_NAME=aicoedev
REGION=europe-west1
TFSTATE_BUCKET=$(PROJECT_NAME)-bucket-tf-state
TFSTATE_DIR=tfstate-static
TFPLAN_FILE=../../$(PROJECT_NAME)-static-$(PROJECT)$(ENVNAME)-$(REGION)-tf.plan
TF_EXEC=terraform
TF_EXTRA_OPTS=
LAYER=static
all: plan
clean:
  @rm -rf .terraform
get:
  $(TF_EXEC) -chdir=$(PWD) get
  $(TF_EXEC) fmt
init: layer_safety_check clean get
  $(TF_EXEC) init \
    -backend-config 'bucket=$(TFSTATE_BUCKET)' \
    -backend-config 'prefix=$(TFSTATE_DIR)'
plan: init
  $(TF_EXEC) -chdir=$(PWD) plan $(TF_EXTRA_OPTS) -refresh=true -out=$(TFPLAN_FILE) -var-file=params.tfvars
init_backend:
  $(TF_EXEC) init \
    -backend-config 'bucket=$(TFSTATE_BUCKET)' \
    -backend-config 'prefix=$(TFSTATE_DIR)'
apply: layer_safety_check
  @test -f $(TFPLAN_FILE) || (echo "ERROR: plan file missing: $(TFPLAN_FILE)" && ls -la ../.. && exit 1)
  @$(MAKE) init_backend
  $(TF_EXEC) -chdir=$(PWD) apply -input=false $(TFPLAN_FILE) && rm -f $(TFPLAN_FILE)
destroy: init
  $(TF_EXEC) -chdir=$(PWD) plan -destroy -var-file=params.tfvars
  $(TF_EXEC) -chdir=$(PWD) destroy -var-file=params.tfvars
show: init
  $(TF_EXEC) -chdir=$(PWD) show
layer_safety_check:
ifeq ($(SKIP_INTERACTIVE_SAFETY_PROMPT), true)
  @echo "SKIP_INTERACTIVE_SAFETY_PROMPT set to true, continuing without interactive safety check prompt."
else
  @echo -n "\nWARNING: $(LAYER) layer for project $(PROJECT_NAME)"
  @echo -n "\n[type 'UNDERSTOOD' then <enter> to continue] " && read ans && [ $${ans:-N} = UNDERSTOOD ]
endif