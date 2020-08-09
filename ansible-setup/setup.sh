yum -y install ansible
useradd admin ; echo redhat | passwd --stdin admin
echo  "admin   ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/admin

ssh servera 'useradd admin ; echo redhat | passwd --stdin admin'
ssh serverb 'useradd admin ; echo redhat | passwd --stdin admin'

scp /etc/sudoers.d/admin servera:/etc/sudoers.d/admin
scp /etc/sudoers.d/admin serverb:/etc/sudoers.d/admin

mkdir /home/admin/project

cat <<EOT>> /home/admin/.vimrc
set ai
set ts=2
set et
set cursorcolumn
EOT
chown admin:admin /home/admin/.vimrc

chown admin:admin /home/admin/project
echo "cd /home/admin/project" >> /home/admin/.bashrc

cat <<EOT>> /home/admin/project/ssh-setup.sh
ssh-keygen
ssh-copy-id servera.lab.example.com
ssh-copy-id serverb.lab.example.com
ansible servers -m ping

EOT
chown admin:admin /home/admin/project/ssh-setup.sh
cat <<EOT>> /home/admin/project/ansible.cfg

[defaults]
inventory=./inventory
remote_user=admin
ask_pass=false

[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False

EOT

cat <<EOT>> /home/admin/project/inventory
[webservers]
servera.lab.example.com

[dbservers]
serverb.lab.example.com

EOT

chown admin:admin /home/admin/project/inventory
chown admin:admin /home/admin/project/ansible.cfg
su - admin
