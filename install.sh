#!/bin/bash
cp -rf nvidia-fan-daemon.sh /usr/bin
cp -rf nvidia-fan-daemon-mapping.cfg /usr/bin
chmod +x /usr/bin/nvidia-fan-daemon.sh

cat > /etc/systemd/system/nvidia-fan-daemon.service << 'END'
[Unit]
Description=NVIDIA Fan Daemon
After=syslog.target network.target multi-user.target

[Service]
ExecStart=/usr/bin/nvidia-fan-daemon.sh
Restart=always
RestartSec=10
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/run/user/1000/gdm/Xauthority"

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl stop nvidia-fan-daemon
systemctl start nvidia-fan-daemon
systemctl enable nvidia-fan-daemon
