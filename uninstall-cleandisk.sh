#!/bin/sh
sudo systemctl stop cleanDisk.timer
sudo systemctl disable cleanDisk.timer
sudo systemctl daemon-reload
sudo systemctl status cleanDisk.timer
sudo rm /opt/cleanDisk.sh /etc/systemd/system/cleanDisk.service /etc/systemd/system/cleanDisk.timer
sudo systemctl status cleanDisk.timer

echo -e "UNINSTALL\v SUCCESSFULLY\v COMPLETED!!"
