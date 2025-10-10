#!/bin/bash

echo "🔧 CONFIGURATION DU TEST D'ÉCHEC"
echo "================================"
echo ""
echo "Pour tester les échecs, on va temporairement modifier le workflow"
echo "pour qu'il détecte le fichier 'fail-test' et échoue."
echo ""
read -p "Veux-tu activer le mode 'échec détectable' ? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Test d'échec annulé"
    exit 1
fi

echo "🔧 Modification temporaire du workflow..."

# Sauvegarder l'original
cp .github/workflows/queue.yml .github/workflows/queue.yml.backup

# Modifier le workflow pour détecter les échecs
cat > .github/workflows/queue.yml << 'EOF'
name: Validate code in the merge queue

on:
  merge_group:

jobs:
  validate-pr:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Check for intentional failure
        run: |
          if [ -f "test/fail-test" ]; then
            echo "💥 INTENTIONAL FAILURE DETECTED!"
            echo "This run should fail to test merge queue error handling"
            exit 1
          fi
          echo "✅ No failure trigger found, continuing..."

      - name: Simulate longer CI (just enough to see batching)
        run: |
          echo "🚀 Simulating your work repo's 30-minute CI (but only 2 minutes for demo)"
          echo "⏱️  In real life: build, tests, security scans, etc."

          # Just enough time to see merge queue batching behavior
          echo "📦 Phase 1/4: Building... (normally 7.5min, demo: 30s)"
          sleep 30

          echo "🧪 Phase 2/4: Unit tests... (normally 7.5min, demo: 30s)"
          sleep 30

          echo "🔍 Phase 3/4: Integration... (normally 7.5min, demo: 30s)"
          sleep 30

          echo "🛡️  Phase 4/4: Security... (normally 7.5min, demo: 30s)"
          sleep 30

          echo "✅ Demo complete! (2min instead of 30min - your wallet is safe 💰)"

      - name: Final merge queue validation
        run: echo "✅ Ready to merge - CI passed after 2 minutes"
EOF

echo "✅ Workflow modifié pour détecter les échecs!"
echo ""
echo "🚀 Maintenant, crée une PR avec un fichier 'test/fail-test' pour déclencher l'échec"
echo ""
echo "🔄 Pour restaurer l'original plus tard:"
echo "   mv .github/workflows/queue.yml.backup .github/workflows/queue.yml"
