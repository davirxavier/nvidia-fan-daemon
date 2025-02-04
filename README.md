# NVIDIA Fan Daemon

Extremely simple shell script to dynamically control a NVIDIA GPU fan speed based on temperature.

## How to use

Adjust the fan speed curve in the ```nvidia-fan-daemon-mapping.cfg``` file to your liking. The format is temperature in degrees celsius in the left, one ":", the fan speed in percentages (eg 50 for 50%) for that temperature, a new line and the next entry (if any).

Example config file:

````
30:40
70:100
````

In this example the fan speed will be 40% when the GPU's temperature is 30ºC, 100% for 70ºC and a calculated value for the curve in the in-between temperatures (~90% for 65ºC or ~50% for 40ºC, for example).

After configuring your fan speed, run the ```install.sh``` script as sudo, this script will install and enable a system-wide service that will run on the background on startup using systemd (nvidia-fan-daemon.service). You can run the install script anytime you change the fan curve, but you will need to run ```sudo systemctl daemon-reload``` ```sudo systemctl restart nvidia-fan-daemon``` or restart your computer for the changes to apply.
