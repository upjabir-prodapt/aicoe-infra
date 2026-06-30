ENVNAME=
PROJECT=pricing-agent
PROJECT_NAME=pricing-agent
REGION=europe-west1
TFSTATE_BUCKET=$(PROJECT)$(ENVNAME)-bucket-tf-state
TFSTATE_DIR=$(PROJECT_NAME)/tfstate-static
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

apply: layer_safety_check init
	$(TF_EXEC) apply $(TFPLAN_FILE) && rm $(TFPLAN_FILE)

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
ifeq ($(ENVNAME), prod)
	@echo -n "\nLIVE SELECTED - ARE YOU SURE?"
	@echo -n "\n[type '$(PROJECT)$(ENVNAME)' then <enter> to continue] " && read ans && [ $${ans:-N} = $(PROJECT)$(ENVNAME) ]
endif
endif
