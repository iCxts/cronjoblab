## Lab Setup 

```bash
# 1. Clone the repository
git clone https://github.com/iCxts/cronjoblab.git
cd cronjoblab

# 2. Run the setup script
sudo ./setup_cron.sh

# 3. Add the student user to the 'students' group
sudo usermod -aG students <student-username>
