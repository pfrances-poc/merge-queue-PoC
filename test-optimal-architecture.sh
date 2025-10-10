#!/bin/bash

# Test de l'ARCHITECTURE OPTIMALE
# Build+ECR (required) individuel + ECS Deploy (batchable) groupé

echo "🎯 TESTING OPTIMAL ARCHITECTURE: BUILD+ECR (required) + ECS DEPLOY (batchable)"
echo "=========================================================================="
echo ""

# Configuration
BATCH_SIZE=3
TOTAL_PRS=6
BASE_BRANCH="main"

echo "📋 Configuration:"
echo "  - Build+ECR: Required status check (individual, 45s)"
echo "  - ECS Deploy: Batchable workflow (group, 55s)"
echo "  - Batch size: $BATCH_SIZE PRs"
echo "  - Total PRs: $TOTAL_PRS"
echo ""

# Check if we're on the correct branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "$BASE_BRANCH" ]; then
    echo "⚠️  Switching to $BASE_BRANCH branch..."
    git checkout $BASE_BRANCH
    git pull
fi

echo "🚀 Creating $TOTAL_PRS test PRs rapidly..."
echo ""

for i in $(seq 1 $TOTAL_PRS); do
    BRANCH_NAME="optimal-test-$i"
    
    # Create and switch to new branch
    git checkout -b $BRANCH_NAME $BASE_BRANCH >/dev/null 2>&1
    
    # Make a small change
    echo "Optimal architecture test $i - $(date)" >> test/optimal-test-$i
    git add test/optimal-test-$i
    git commit -m "✨ Optimal test $i: Build+ECR individual, ECS Deploy batched" >/dev/null 2>&1
    
    # Push branch
    git push -u origin $BRANCH_NAME >/dev/null 2>&1
    
    # Create PR
    gh pr create \
        --title "🎯 Optimal Test $i: Separate Build+ECR from ECS Deploy" \
        --body "Test $i of optimal architecture:
        
**Individual phase** (required status check):
- ✅ Build & Push ECR (45s) 

**Batch phase** (merge queue):
- 🔄 ECS Blue/Green Deploy (55s)
- ⚡ Multiple PRs deploy together = No cancellations!

Expected behavior:
1. Build+ECR runs immediately on PR
2. ECS Deploy waits for batch of $BATCH_SIZE PRs
3. All PRs in batch deploy together" \
        --base $BASE_BRANCH \
        --head $BRANCH_NAME >/dev/null 2>&1
    
    echo "  ✅ Created PR #$i: optimal-test-$i"
    
    # Go back to main for next iteration
    git checkout $BASE_BRANCH >/dev/null 2>&1
    
    # Small delay to avoid rate limiting
    sleep 2
done

echo ""
echo "🎯 OPTIMAL ARCHITECTURE TEST SETUP COMPLETE!"
echo ""
echo "Expected behavior:"
echo "1. 📦 Build+ECR workflows run immediately on each PR (6 individual runs)"
echo "2. ⏳ PRs wait for batch of $BATCH_SIZE to form"
echo "3. 🚀 ECS Deploy runs once per batch (2 batched runs for 6 PRs)"
echo "4. 💰 SAVINGS: 6 individual builds + 2 batched deploys vs 6 full pipelines"
echo ""
echo "🔗 Monitor progress:"
echo "gh pr list --limit 10"
echo "./monitor.sh"
echo ""
echo "To add PRs to merge queue:"
echo "gh pr merge --merge --auto PR_NUMBER"