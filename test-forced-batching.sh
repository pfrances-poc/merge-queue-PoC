#!/bin/bash

echo "🎯 TEST BATCHING FORCÉ - Le vrai comportement de groupe !"
echo "======================================================="
echo ""
echo "📋 PRÉREQUIS:"
echo "Sur GitHub Settings → Branches → main → Merge queue:"
echo "• Min Group Size: 3 (au lieu de 1)"
echo "• Wait Time: 1 minute (au lieu de 5)"
echo "• Build Concurrency: 1 (garde comme ça)"
echo ""
read -p "🔧 As-tu fait ces changements ? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Va d'abord modifier les settings sur GitHub !"
    exit 1
fi

echo ""
echo "🚀 Lancement du test - Création de 4 PR rapidement..."
echo "Avec Min Group Size = 3, elles DOIVENT attendre d'être groupées !"
echo ""

# Créer 4 PR rapidement
for i in {1..4}; do
  BRANCH="forced-batch-$(date +%s)-$i"

  echo "📝 Création PR $i/4 - Branch: $BRANCH"

  git checkout -b "$BRANCH"
  echo "Forced batch test $i - $(date)" > "test/forced-batch-$i"
  git add "test/forced-batch-$i"
  git commit -m "🧪 Forced batch test $i: Test minimum group size behavior"

  git push -u origin "$BRANCH"
  gh pr create \
    --base main \
    --head "$BRANCH" \
    --title "🧪 Forced Batch $i - Min Group Size Test" \
    --body "Test PR for forced batching with Min Group Size = 3

🎯 **Expected behavior**:
- This PR should WAIT until 3 PRs are accumulated
- Then all 3+ PRs should be tested together in one CI run
- The 4th PR should either join the group or wait for the next batch

🔬 **What to observe**:
- PRs accumulating without immediate CI runs
- One CI run testing multiple PRs together
- Grouped merge commits"

  gh pr merge --auto --delete-branch "$BRANCH"
  git checkout -f main
  git branch -D "$BRANCH"

  echo "✅ PR $i created and queued"

  # Attendre juste 5 secondes entre chaque PR
  if [ $i -lt 4 ]; then
    echo "⏸️  Waiting 5 seconds..."
    sleep 5
  fi
done

echo ""
echo "🎉 4 PRs created with Min Group Size = 3!"
echo ""
echo "🔍 WHAT TO EXPECT:"
echo "• PRs should accumulate and NOT start CI immediately"
echo "• After 1 minute wait time, first group of 3 should start"
echo "• One CI run should test multiple PRs together"
echo "• Look for merge commits that combine multiple PRs"
echo ""
echo "📊 Monitor with: ./monitor.sh"
echo "🔍 Or manually: gh pr list && gh run list"
