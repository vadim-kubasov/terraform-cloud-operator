#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


CHART_DIR="charts/terraform-cloud-operator"
CHART_FILE="Chart.yaml"

# Update the 'Chart.yaml' file with a new version of the Operator image tag.
function update_chart_file {
  C_VERSION=`yq '.appVersion' $CHART_DIR/$CHART_FILE`
  C_CHART_VERSION=`yq '.version' $CHART_DIR/$CHART_FILE`

  if [[ $C_VERSION == $TFC_OPERATOR_RELEASE_VERSION && $C_CHART_VERSION == $TFC_OPERATOR_RELEASE_VERSION ]]; then
    echo "No changes in the $CHART_FILE file."
    return 0
  fi

  echo "Updating the $CHART_FILE file."

  yq \
    --inplace \
    '.appVersion = strenv(TFC_OPERATOR_RELEASE_VERSION) | .version = strenv(TFC_OPERATOR_RELEASE_VERSION)' $CHART_DIR/$CHART_FILE
}

function main {
  if [[ -z "${TFC_OPERATOR_RELEASE_VERSION}" ]]; then
    echo "The environment variable TFC_OPERATOR_RELEASE_VERSION is not set."
    exit 1
  fi

  GIT_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e 's/^release\/v//'`

  if [[ "$TFC_OPERATOR_RELEASE_VERSION" != "$GIT_BRANCH" ]]; then
    echo "The version in the git branch name '${GIT_BRANCH}' does not match with the release version '${TFC_OPERATOR_RELEASE_VERSION}'."
    echo "Exiting!"
    exit 1
  fi

  echo "Version: ${TFC_OPERATOR_RELEASE_VERSION}"

  update_chart_file
}

main
