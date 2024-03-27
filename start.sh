#!/bin/bash
# Start the server in screen:
screen -dmS "yals" bash -c "conda activate yals && python3 go_yals.py"
echo "started yals in screen"
echo "to attach to screen, run: screen -x yals"
echo "to detach from screen WITHOUT STOPPING THE PROCESS, press Ctrl+A then Ctrl+D"
echo "to stop the process, attach to the screen and press Ctrl+C"

