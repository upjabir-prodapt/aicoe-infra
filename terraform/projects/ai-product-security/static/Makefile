ENVNAME=
PROJECT=ai-product-security
REGION=europe-west1
TFSTATE_BUCKET=$(PROJECT)-$(ENVNAME)-bucket-tf-state
TFSTATE_DIR=tfstate-static
#TFPLAN_FILE=../static-$(PROJECT)-$(ENVNAME)-$(REGION)-tf.plan
TFPLAN_FILE=../../$(PROJECT_NAME)-static-$(PROJECT)$(ENVNAME)-$(REGION)-tf.plan
TF_EXEC=terraform
TF_EXTRA_OPTS=
# CREDS_FILE=../$(PROJECT)$(ENVNAME).json

all: plan

clean:
	@rm -rf .terraform

get:
	# terraform get - download and update modules mentioned in the root module. (https://www.terraform.io/docs/commands/get.html)
	$(TF_EXEC) -chdir=$(PWD) get 
	# terraform fmt - rewrite Terraform configuration files to a canonical format and style (https://www.terraform.io/docs/commands/fmt.html)
	$(TF_EXEC) fmt

init: static_safety_check clean get
    # For GCP Bucket state
	$(TF_EXEC) init \
		-backend-config 'bucket=$(TFSTATE_BUCKET)' \
 		-backend-config 'prefix=$(TFSTATE_DIR)'
    # For Hashicorp hosted state
	#$(TF_EXEC) init \
	#	-backend-config 'workspace{name=$(PROJECT)-$(ENVNAME)}'

plan: init
	$(TF_EXEC) -chdir=$(PWD) plan $(TF_EXTRA_OPTS) -refresh=true -out=$(TFPLAN_FILE) -var-file=params.tfvars

landscape: init
	$(TF_EXEC) -chdir=$(PWD) plan $(TF_EXTRA_OPTS) -refresh=true -out=$(TFPLAN_FILE) -var-file=params.tfvars | landscape
apply: static_safety_check init
	$(TF_EXEC) apply $(TFPLAN_FILE) && rm $(TFPLAN_FILE)

destroy: init
	$(TF_EXEC) -chdir=$(PWD) plan -destroy -var-file=params.tfvars
	$(TF_EXEC) -chdir=$(PWD) destroy -var-file=params.tfvars

show: init
	$(TF_EXEC) -chdir=$(PWD) show

refresh: init
	$(TF_EXEC) -chdir=$(PWD) refresh -var-file=params.tfvars

#importresource: init
	#$(TF_EXEC) import -var-file=params.tfvars aws_iam_user.ses resource_name


static_safety_check:
ifeq ($(SKIP_INTERACTIVE_SAFETY_PROMPT), true)
	@echo "SKIP_INTERACTIVE_SAFETY_PROMPT set to true, continuing without interactive safety check prompt."
else
	@echo -n "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo -n "\nSTATIC LAYER SELECTED - YOU MUST DOUBLE CHECK THE PLAN FOR ANY UNINTENDED CHANGES (SUCH AS RESERVED IPS CHANGING)"
	@echo -n "\n[type 'UNDERSTOOD' then <enter> to continue] " && read ans && [ $${ans:-N} = UNDERSTOOD ]
ifeq ($(ENVNAME), prod)
	@echo -n "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo -n "\nLIVE SELECTED - ARE YOU SURE YOU WANT TO CONTINUE?"
	@echo -n "\n[type '$(PROJECT)-$(ENVNAME)' then <enter> to continue] " && read ans && [ $${ans:-N} = $(PROJECT)-$(ENVNAME) ]
else
	@echo "non-live selected, continuing without safety check prompt."
endif
endif