#!/bin/bash

echo "🧪 TESTS AVANCÉS POUR MERGE QUEUE"
echo "================================="
echo ""
echo "Choisis un test à exécuter :"
echo ""

echo "1️⃣  TEST BATCHING FORCÉ (Min Group Size = 3)"
echo "   └─ Modifie les settings: Min Group Size = 3, Wait Time = 1min"
echo "   └─ Crée 4 PR rapidement pour voir le vrai batching"
echo ""

echo "2️⃣  TEST ÉCHEC DE CI (que se passe-t-il si une PR échoue ?)"
echo "   └─ Crée une PR qui fait planter les tests"
echo "   └─ Observe comment la queue gère l'échec"
echo ""

echo "3️⃣  TEST CHARGE ÉLEVÉE (beaucoup de PR simultanées)"
echo "   └─ Crée 8 PR d'un coup"
echo "   └─ Observe la stratégie de traitement"
echo ""

echo "4️⃣  TEST TIMING (PR qui arrivent pendant la formation d'un groupe)"
echo "   └─ Teste les timings et l'ordre de traitement"
echo ""

echo "5️⃣  COMPARAISON CONCURRENCY 1 vs 5"
echo "   └─ Compare les deux stratégies côte à côte"
echo ""

echo "Tape le numéro de ton choix (1-5) :"
