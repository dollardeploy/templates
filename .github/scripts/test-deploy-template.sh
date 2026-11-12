#!/usr/bin/env bash
# Test-deploy one DollarDeploy template on the test host, then remove it.
#
# Usage: test-deploy-template.sh <template-id>
#
# Env:
#   DOLLARDEPLOY_API_KEY         required, API key for ddc
#   DOLLARDEPLOY_TEST_HOST_ID    required, id of the prepared test host (`ddc host list`)
#   DOLLARDEPLOY_BASE_URL        optional, API base URL (read by ddc itself)
#   DOLLARDEPLOY_SCREENSHOT_URL  optional, screenshot service; POST {"url": "<app url>"}
#   DEPLOY_TIMEOUT_MS            optional, per-task timeout passed to ddc (default 30 min)
#
# Exits non-zero when the launch, build or deploy fails. ddc prints the error
# to stderr, so it lands in the job log as-is. Every app created on the test
# host during this run is removed on exit, on success and on failure.
set -euo pipefail

template_id="${1:-}"
if [ -z "$template_id" ]; then
  echo "::error::Usage: $0 <template-id>"
  exit 2
fi

if [ -z "${DOLLARDEPLOY_API_KEY:-}" ]; then
  echo "::error::DOLLARDEPLOY_API_KEY is not set. Add it as a repository secret."
  exit 2
fi

if [ -z "${DOLLARDEPLOY_TEST_HOST_ID:-}" ]; then
  echo "::error::DOLLARDEPLOY_TEST_HOST_ID is not set. Add the test host id (from \`ddc host list\`) as a repository secret: gh secret set DOLLARDEPLOY_TEST_HOST_ID --body <host-id>"
  exit 2
fi

host_id="$DOLLARDEPLOY_TEST_HOST_ID"
timeout_ms="${DEPLOY_TIMEOUT_MS:-1800000}"

list_host_app_ids() {
  ddc app list --json | jq -r --arg host "$host_id" '.[] | select(.hostId == $host) | .id' | sort
}

apps_before="$(list_host_app_ids)"

cleanup() {
  local exit_code=$?
  local apps_after new_apps app_id

  # The CLI does not return the app id when the launch fails, so diff the
  # host's apps against the snapshot. Safe because the workflow runs in a
  # single concurrency group.
  if ! apps_after="$(list_host_app_ids)"; then
    echo "::warning::Could not list apps on host $host_id; test app for $template_id may need manual removal."
    exit "$exit_code"
  fi

  new_apps="$(comm -13 <(echo "$apps_before") <(echo "$apps_after"))"
  for app_id in $new_apps; do
    echo "Removing test app $app_id ($template_id)..."
    if ! ddc app remove "$app_id" --yes --timeout "$timeout_ms"; then
      echo "::warning::Failed to remove test app $app_id ($template_id) from host $host_id. Remove it manually."
    fi
  done

  exit "$exit_code"
}
trap cleanup EXIT

echo "Deploying template $template_id to host $host_id..."
result="$(ddc app deploy --template "$template_id" --hostId "$host_id" --timeout "$timeout_ms" --verbose --json)"
echo "$result"

app_url="$(echo "$result" | jq -r '.url // empty')"
echo "Template $template_id deployed: $app_url"

if [ -z "${DOLLARDEPLOY_SCREENSHOT_URL:-}" ] || [ -z "$app_url" ]; then
  exit 0
fi

echo "Taking screenshot of $app_url..."
payload="$(jq -n --arg url "$app_url" '{url: $url}')"
if ! screenshot="$(curl --fail --silent --show-error --max-time 300 \
  -X POST -H "Content-Type: application/json" \
  --data "$payload" "$DOLLARDEPLOY_SCREENSHOT_URL")"; then
  echo "::warning::Screenshot of $app_url ($template_id) failed."
  exit 0
fi

screenshot_url="$(echo "$screenshot" | jq -r '.screenshotUrl // empty' 2>/dev/null || true)"
if [ -z "$screenshot_url" ]; then
  echo "::warning::Screenshot service returned no screenshotUrl for $app_url ($template_id)."
  exit 0
fi

echo "Screenshot: $screenshot_url"
