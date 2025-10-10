#!/bin/bash

echo "💥 TEST ÉCHEC DE CI - Comment la merge queue gère les erreurs"
echo "============================================================="
echo ""
echo "🎯 Ce test va:"
echo "1. Créer une PR qui fait échouer les tests"
echo "2. Créer 2 PR normales"
echo "3. Observer comment la queue gère l'échec du groupe"
echo ""

# Créer d'abord une PR qui va échouer
FAIL_BRANCH="fail-test-$(date +%s)"
echo "💣 Création d'une PR qui va ÉCHOUER..."

git checkout -b "$FAIL_BRANCH"

# Modifier le workflow pour qu'il échoue avec cette PR
echo "💥 FAIL TEST - This will make CI fail" > "test/fail-test"
git add "test/fail-test"
git commit -m "💥 Fail test: This PR should make CI fail"

git push -u origin "$FAIL_BRANCH"
gh pr create \
  --base main \
  --head "$FAIL_BRANCH" \
  --title "💥 FAIL TEST - This should fail CI" \
  --body "This PR is designed to fail CI and test merge queue error handling.

🎯 **Expected behavior**: 
- This PR should fail during CI
- If grouped with other PRs, it should cause the group to fail
- The queue should then retry other PRs individually
- Other PRs should eventually merge successfully

🔬 **What to observe**:
- Failed CI runs
- Queue retry behavior
- Individual PR processing after group failure"

gh pr merge --auto --delete-branch "$FAIL_BRANCH"
git checkout -f main
git branch -D "$FAIL_BRANCH"

echo "💥 Failing PR created!"
echo ""

# Attendre un peu puis créer 2 PR normales
echo "⏳ Waiting 10 seconds before creating normal PRs..."
sleep 10

echo "✅ Creating 2 normal PRs that should succeed..."

for i in {1..2}; do
  BRANCH="normal-test-$(date +%s)-$i"
  
  echo "📝 Creating normal PR $i/2 - Branch: $BRANCH"
  
  git checkout -b "$BRANCH"
  echo "Normal test $i - $(date)" > "test/normal-test-$i"
  git add "test/normal-test-$i"
  git commit -m "✅ Normal test $i: Should succeed after fail test"
  
  git push -u origin "$BRANCH"
  gh pr create \
    --base main \
    --head "$BRANCH" \
    --title "✅ Normal Test $i - Should succeed" \
    --body "Normal PR that should succeed, created after a failing PR.

🎯 **Expected behavior**: 
- Should eventually merge successfully
- Might be affected by the failing PR if grouped together
- Should demonstrate queue recovery behavior"
  
  gh pr merge --auto --delete-branch "$BRANCH"
  git checkout -f main
  git branch -D "$BRANCH"
  
  echo "✅ Normal PR $i created"
  sleep 5
done

echo ""
echo "🎭 SCENARIO CREATED:"
echo "• 1 PR that will FAIL CI"
echo "• 2 PRs that should SUCCEED"
echo ""
echo "🔍 WHAT TO OBSERVE:"
echo "• How does the queue handle the failing PR?"
echo "• Do the good PRs get blocked by the bad one?"
echo "• Does the queue retry them individually?"
echo "• What's the final merge behavior?"
echo ""
echo "📊 Monitor the drama with: ./monitor.sh"