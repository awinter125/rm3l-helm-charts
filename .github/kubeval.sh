#!/bin/bash
set -euo pipefail

BASE_BRANCH=$(echo $GITHUB_REF | sed -n 's|^refs/heads/||p')
CHART_DIRS="$(git diff --find-renames --name-only "$BASE_BRANCH" -- charts | grep '[cC]hart.yaml' | sed -e 's#/[cC]hart.yaml##g')"
KUBEVAL_VERSION="0.16.1"
SCHEMA_LOCATION="https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/"

echo "BASE_BRANCH: $BASE_BRANCH"
echo "CHART_DIRS: $CHART_DIRS"

# install kubeval
curl --silent --show-error --fail --location --output /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/"${KUBEVAL_VERSION}"/kubeval-linux-amd64.tar.gz
tar -xf /tmp/kubeval.tar.gz kubeval

echo "Kubeval version:"
./kubeval --version

# validate charts
for CHART_DIR in ${CHART_DIRS}; do
  echo "Validating chart in directory: $CHART_DIR"
  helm template "${CHART_DIR}" | ./kubeval --strict --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
done
