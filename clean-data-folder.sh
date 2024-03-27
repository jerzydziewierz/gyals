#!/bin/bash
# ask for confirmation:
read -p "Are you sure you want to delete all data? [y/N] " -n 1 -r
# if not confirmed, exit:
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo
    echo "Aborted."
    exit 1
fi
echo
echo "Deleting all data..."
rm -r data
echo "Done."
