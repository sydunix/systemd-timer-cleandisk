#!/bin/sh

echo "Creating cleanDisk Shell Script"
#creating cleanDisk Script /opt directory
cat <<EOF | sudo tee -a /opt/cleanDisk.sh
#!/bin/bash
echo "CLOSE ALL SNAPS BEFORE RUNNING THIS"
# CLOSE ALL SNAPS BEFORE RUNNING THIS

echo "Setting logs to be jettisoned if older than 3days"
#logs to be jettisoned if older than 3days
journalctl --disk-usage
sudo journalctl --vacuum-time=3d

echo "Removing old install files, kernels, thumbnails"
# Cleaning apt cache
apt-get autoremove
du -sh /var/cache/apt
apt-get autoclean -y
apt-get clean -y
echo "Cleaned apt cache!"

echo "List files in trash and clear trash bin"
# Clear out trash bin 
ls ~/.local/share/Trash/files/
rm ~/.local/share/Trash/files/*

echo "Disk space occupied by thumbnails(if available!)"
# Show disk space occupied by thumbnails 
du -sh ~/.cache/thumbnails

echo "Freeing space occupied by thumbnails"
# Delete the thumbnails
rm -rf ~/.cache/thumbnails/*


echo "Disk space occupied by snaps"
# Disk space containing snaps
du -h /var/lib/snapd/snaps

echo "Removing old revisions of snaps"
# List disabled snaps and delete
set -eu
LANG=C snap list --all | awk '/disabled/{print \$1, \$3}' |
    while read snapname revision; do
        snap remove "\$snapname" --revision="\$revision"
    done

EOF

echo "Making cleanDisk Shell Script executable"
#Make script executable
sudo chmod +x /opt/cleanDisk.sh


echo "Creating the cleanDisk SYSTEMD Service"
#Creating cleanDisk Service in /etc/systemd/system directory
cat <<EOF | sudo tee -a /etc/systemd/system/cleanDisk.service

[Unit]
Description=Retrieve disk space taken up by logs and old installs 

[Service]
ExecStart=/bin/bash /opt/cleanDisk.sh

EOF

echo "Creating the cleanDisk SYSTEMD Timer"
#Creating cleanDisk Service in /etc/systemd/system directory
cat <<EOF | sudo tee -a /etc/systemd/system/cleanDisk.timer
[Unit]
Description=Timer to run cleanDisk.service

[Timer]
Unit=cleanDisk.service
OnCalendar=Wed 2022-11,12-* 17:37:00

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cleanDisk.timer && sudo systemctl start cleanDisk.timer
sudo systemctl daemon-reload
systemctl list-timers

# journalctl -f -u cleanDisk.service

echo -e "SETUP\v SUCCESSFULLY\v COMPLETED!!"