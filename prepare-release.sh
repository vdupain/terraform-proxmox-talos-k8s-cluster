#!/bin/sh

terraform fmt -recursive
terraform-docs markdown table --recursive --output-file README.md --output-mode inject .