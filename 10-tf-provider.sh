#!/bin/bash
set -e

  echo "Downloading aws provider version: $version"
  wget -q https://releases.hashicorp.com/terraform-provider-aws/4.15.1/terraform-provider-aws_4.15.1_linux_amd64.zip
  unzip  terraform-provider-aws_4.15.1_linux_amd64.zip -d ${TF_PLUGIN_CACHE_DIR}/linux_amd64
  rm terraform-provider-aws_4.15.1_linux_amd64.zip
