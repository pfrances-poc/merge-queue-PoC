#!/bin/bash

COUNT=$1
if [ -z "$COUNT" ]; then
  echo "Usage: $0 <count>"
  exit 1
fi

for i in $(seq 1 $COUNT); do
  git checkout -b "test-$i"
  echo $(openssl rand -base64 12) > test/test-$i
  git add test/test-$i
  git commit -m "Add test file test/test-$i"
  git push -u origin "test-$i"
  gh pr create --base main --head "test-$i" --title "Merge Queue test-$i" --body "This is a test PR for test-$i"
  gh pr merge --auto --delete-branch "test-$i"
  git checkout -f main
  git branch -D "test-$i"
done
