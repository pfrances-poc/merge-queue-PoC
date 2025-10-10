#!/bin/bash

# Script de monitoring pour observer le comportement de la merge queue

echo "📊 MERGE QUEUE MONITORING DASHBOARD"
echo "=================================="
echo ""

while true; do
  clear
  echo "📊 MERGE QUEUE MONITORING - $(date)"
  echo "=================================="
  echo ""
  
  echo "🔄 ACTIVE WORKFLOW RUNS:"
  echo "------------------------"
  gh run list --repo pfrances-poc/merge-queue-PoC --workflow=queue.yml --limit 10 --json status,conclusion,displayTitle,createdAt,runNumber | jq -r '.[] | "\(.runNumber): \(.status) | \(.createdAt) | \(.displayTitle)"'
  echo ""
  
  echo "📋 PENDING PULL REQUESTS:"
  echo "-------------------------"
  gh pr list --repo pfrances-poc/merge-queue-PoC --json number,title,createdAt,mergeable | jq -r '.[] | "#\(.number): \(.title) | Created: \(.createdAt) | Mergeable: \(.mergeable)"'
  echo ""
  
  echo "🎯 MERGE QUEUE STATUS:"
  echo "---------------------"
  # Compter les runs actifs
  ACTIVE_RUNS=$(gh run list --repo pfrances-poc/merge-queue-PoC --workflow=queue.yml --status=in_progress --json status | jq length)
  PENDING_PRS=$(gh pr list --repo pfrances-poc/merge-queue-PoC --json number | jq length)
  
  echo "Active CI runs: $ACTIVE_RUNS"
  echo "Pending PRs: $PENDING_PRS"
  echo ""
  
  echo "💡 ANALYSIS:"
  echo "------------"
  if [ "$ACTIVE_RUNS" -gt 0 ] && [ "$PENDING_PRS" -gt 1 ]; then
    echo "🎯 Batching in progress! Multiple PRs may be grouped."
  elif [ "$ACTIVE_RUNS" -gt 0 ]; then
    echo "⚡ CI running - check if it's processing multiple PRs"
  elif [ "$PENDING_PRS" -gt 0 ]; then
    echo "⏳ PRs waiting for merge queue processing"
  else
    echo "✅ Queue is empty"
  fi
  
  echo ""
  echo "🔄 Refreshing in 10 seconds... (Ctrl+C to stop)"
  sleep 10
done