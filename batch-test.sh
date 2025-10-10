#!/bin/bash

# Script pour tester le batching de la merge queue avec des CI longs (30 min)
# Simule ton environnement de travail

echo "🚀 Testing merge queue batching behavior"
echo "📊 Creating multiple PRs rapidly to trigger grouping"

# Créer 5 PR rapidement (dans la fenêtre de 5 minutes de wait time)
for i in {1..5}; do
  BRANCH="batch-test-$(date +%s)-$i"
  
  echo "📝 Creating PR $i/5 - Branch: $BRANCH"
  
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
    --body "This PR tests merge queue batching with 30min CI simulation.

🎯 **Test Goal**: See if multiple PRs get batched together
⏱️ **CI Duration**: 30 minutes (simulated)
📊 **Batch**: PR $i of 5 created rapidly"
  
  # Activer auto-merge pour que ça entre dans la queue
  gh pr merge --auto --delete-branch "$BRANCH"
  
  # Retourner sur main et nettoyer
  git checkout -f main
  git branch -D "$BRANCH"
  
  echo "✅ PR $i created and queued"
  
  # Attendre juste 30 secondes entre chaque PR pour rester dans la fenêtre
  if [ $i -lt 5 ]; then
    echo "⏸️  Waiting 30 seconds before next PR..."
    sleep 30
  fi
done

echo ""
echo "🎉 All 5 PRs created and queued!"
echo "📈 Now watch the merge queue behavior:"
echo "   - Check if PRs get grouped together"
echo "   - Monitor CI runs vs number of PRs"
echo "   - Observe batching with 30min CI simulation"
echo ""
echo "🔗 Monitor with:"
echo "   gh run list --repo pfrances-poc/merge-queue-PoC --workflow=queue.yml"
echo "   gh pr list --repo pfrances-poc/merge-queue-PoC"