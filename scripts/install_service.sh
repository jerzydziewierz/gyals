#!/bin/bash
echo "install_service.sh: starting..."
sudo cp yals.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable yals.service
sudo systemctl start yals.service
sudo systemctl status yals.service
echo "install_service.sh: showing log. ctrl-c to exit"
sudo journalctl -f -r yals.service
echo "install_service.sh: clean exit"