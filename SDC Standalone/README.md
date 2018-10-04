# Cloudera Docker VM Version
Note that this template specifically uses wget to fetch a specific version of StreamSets Data Collector (SDC) 3.5 to run on an Oracle Linux 7.2 instance.

# Usage Guide
  
Note that this installation is a stand-alone instance running the SDC via RPM package. Access is performed via web browser.

## PREREQUISITES

Installation has a dependency on Terraform being installed and configured for the user tenancy.   As such an "env-vars" file is included with this package which contains all the necessary environment variables.  This file should be updated with the appropriate values prior to installation.  To source this file prior to installation, either reference it in your .rc file for your shell or run the following:

        source env-vars

## Deployment

Deploy using standard terraform commands

        terraform init && terraform plan && terraform apply

## Post Deployment

All post deployment for the Sandbox instance is done in remote-exec as part of the Terraform apply process.  You will see output on the screen as part of this process.  Once complete, URLs for access to the Sandbox will be displayed.
