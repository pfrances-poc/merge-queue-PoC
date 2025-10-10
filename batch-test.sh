#!/bin/bash

# Script pour tester le batching de la merge queue avec des CI longs (30 min)
# Simule ton environnement de travail

echo "🚀 Testing merge queue batching behavior"
echo "📊 Creating multiple PRs rapidly to trigger grouping"

# Créer 3 PR rapidement (économique mais suffisant pour voir le batching)
for i in {1..3}; do
  BRANCH="batch-test-$(date +%s)-$i"
  
  echo "📝 Creating PR $i/3 - Branch: $BRANCH"
  
  # Créer une branche
  git checkout -b "$BRANCH"
  
  # Ajouter un fichier unique
  echo "Batch test $i - $(date)" > "test/batch-test-$i"
  git add "test/batch-test-$i"
  git commit -m "Batch test $i: Add test file for merge queue batching"
  
  # Push et créer PR
  git push -u origin "$BRANCH"
  gh pr create \
    --base main \
    --head "$BRANCH" \
    --title "🧪 Batch Test $i - Long CI simulation" \
    --body "This PR tests merge queue batching with 2min CI (simulates 30min).

🎯 **Test Goal**: See if multiple PRs get batched together  
⏱️ **CI Duration**: 2 minutes (represents 30min work CI)
📊 **Batch**: PR $i of 3 created rapidly
💰 **Budget-friendly**: 2min instead of 30min for demo"
  
  # Activer auto-merge pour que ça entre dans la queue
  gh pr merge --auto --delete-branch "$BRANCH"
  
  # Retourner sur main et nettoyer
  git checkout -f main
  git branch -D "$BRANCH"
  
  echo "✅ PR $i created and queued"
  
  # Attendre juste 10 secondes entre chaque PR pour rester dans la fenêtre
  if [ $i -lt 3 ]; then
    echo "⏸️  Waiting 10 seconds before next PR..."
    sleep 10
  fi
done

echo ""
echo "🎉 All 3 PRs created and queued!"
echo "📈 Now watch the merge queue behavior:"
echo "   - Check if PRs get grouped together"  
echo "   - Monitor CI runs vs number of PRs"
echo "   - Observe batching with 2min CI (represents your 30min work CI)"
echo "💰 Budget-friendly demo: 6min total instead of 90min!"
echo ""
echo "🔗 Monitor with:"
echo "   gh run list --repo pfrances-poc/merge-queue-PoC --workflow=queue.yml"
echo "   gh pr list --repo pfrances-poc/merge-queue-PoC"