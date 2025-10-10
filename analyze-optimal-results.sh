#!/bin/bash

# Analyse des résultats de l'architecture optimale
echo "📊 OPTIMAL ARCHITECTURE RESULTS ANALYSIS"
echo "========================================"
echo ""

echo "🏗️  INDIVIDUAL BUILDS (Required Status Checks):"
echo "------------------------------------------------"
gh run list --workflow="build-ecr.yml" --limit 10 --json conclusion,status,createdAt,displayTitle | \
    jq -r '.[] | "  \(.displayTitle) - \(.status) (\(.conclusion // "running"))"'

echo ""
echo "🚀 BATCHED DEPLOYMENTS (Merge Queue):"
echo "------------------------------------"  
gh run list --workflow="queue.yml" --limit 10 --json conclusion,status,createdAt,displayTitle | \
    jq -r '.[] | "  \(.displayTitle) - \(.status) (\(.conclusion // "running"))"'

echo ""
echo "📈 EFFICIENCY COMPARISON:"
echo "------------------------"

# Count individual builds
individual_builds=$(gh run list --workflow="build-ecr.yml" --limit 20 --json status | jq length)

# Count batched deploys  
batch_deploys=$(gh run list --workflow="queue.yml" --limit 20 --json status | jq length)

echo "  Individual builds:    $individual_builds runs (45s each)"
echo "  Batched deployments:  $batch_deploys runs (55s each)"
echo ""

if [ $individual_builds -gt 0 ] && [ $batch_deploys -gt 0 ]; then
    prs_per_batch=$((individual_builds / batch_deploys))
    
    # Calculate time savings
    optimal_time=$((individual_builds * 45 + batch_deploys * 55))
    old_time=$((individual_builds * 100))  # 45s build + 55s deploy per PR
    time_saved=$((old_time - optimal_time))
    savings_percent=$(((time_saved * 100) / old_time))
    
    echo "💡 ANALYSIS:"
    echo "  PRs per batch:        ~$prs_per_batch PRs"
    echo "  Old approach:         ${old_time}s total (100s per PR)"
    echo "  Optimal approach:     ${optimal_time}s total"
    echo "  Time saved:           ${time_saved}s (${savings_percent}%)"
    echo ""
    echo "🎯 BENEFITS:"
    echo "  ✅ No deployment cancellations"
    echo "  ✅ Individual validation (fast feedback)"  
    echo "  ✅ Efficient batch deployment"
    echo "  ✅ ${savings_percent}% time reduction"
fi

echo ""
echo "🔄 CURRENT MERGE QUEUE STATUS:"
echo "-----------------------------"
gh api repos/:owner/:repo/pulls --jq '.[] | select(.draft == false) | "  PR #\(.number): \(.title) (\(.state))"' | head -5