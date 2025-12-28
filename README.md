# Born2beroot

_This project has been created as part of the 42 curriculum by dnovikov._

## Description

Born2beroot is a system administration project that focuses on setting up a secure server environment using virtualization. The goal is to create a minimal, hardened Linux server with strict security policies, encrypted partitions, and comprehensive monitoring capabilities.

This project teaches fundamental concepts of system administration including:

-   Virtual machine configuration and management
-   User and group management with strict password policies
-   Firewall configuration and SSH hardening
-   Sudo configuration with comprehensive logging
-   Automated system monitoring
-   Service management and security best practices

The final setup includes a functional Debian server with encrypted LVM partitions, SSH access on a custom port, UFW firewall protection, AppArmor security profiles, and an automated monitoring system that broadcasts system metrics every 10 minutes.

## Project Description

### Operating System Choice: Debian

**Debian** was chosen for this project over Rocky Linux for the following reasons:

**Pros:**

-   More beginner-friendly with extensive documentation
-   Larger community and more readily available support
-   APT package manager is intuitive and well-documented
-   Better suited for learning fundamental Linux concepts
-   Lighter resource requirements for virtual environments
-   Longer release cycle means more stability
-   AppArmor is simpler to understand than SELinux

**Cons:**

-   Less commonly used in enterprise environments compared to RHEL-based systems
-   Potentially older packages in stable releases
-   Less optimized for specific enterprise use cases

**Rocky Linux Alternative:**

-   More suitable for enterprise environments (RHEL-compatible)
-   Better for those planning to work with CentOS/RHEL systems
-   Uses SELinux which is more powerful but complex
-   Yum/DNF package managers (different learning curve)

### Design Choices

#### Partitioning Scheme

The system uses **LVM (Logical Volume Manager)** with **encrypted partitions** providing:

-   Flexible disk management and easy resizing
-   Full disk encryption for data security
-   Separate logical volumes for different system areas
-   Protection against unauthorized physical access

#### Security Policies

**Password Policy:**

-   Maximum password age: 30 days
-   Minimum days between changes: 2 days
-   Warning before expiration: 7 days
-   Strong password requirements using libpam-pwquality:
    -   Minimum length enforcement
    -   Complexity requirements (uppercase, lowercase, digits, special characters)
    -   Dictionary word prevention
    -   Username substring checks

**Sudo Configuration:**

-   Limited authentication attempts (3 tries)
-   Custom error messages for failed attempts
-   Comprehensive logging to `/var/log/sudo/`
-   Input/output logging for audit trails
-   TTY requirement for security
-   Restricted path for security

#### User Management

-   Users assigned to appropriate groups (sudo, user42)
-   Strict password policies enforced via PAM
-   Regular password expiration requirements
-   Clear separation between regular users and administrators

#### Services Installed

-   **SSH Server** (OpenSSH): Remote access on port 4242
-   **UFW Firewall**: Simple firewall management
-   **Lighttpd**: Lightweight web server
-   **MariaDB**: Database server
-   **WordPress**: CMS platform
-   **Prometheus Node Exporter**: System metrics monitoring on port 9100

### Technical Comparisons

#### Debian vs Rocky Linux

| Aspect               | Debian             | Rocky Linux                |
| -------------------- | ------------------ | -------------------------- |
| **Base**             | Independent        | RHEL-based                 |
| **Package Manager**  | APT (apt, dpkg)    | DNF/YUM (dnf, rpm)         |
| **Release Cycle**    | ~2 years (stable)  | ~6 months (following RHEL) |
| **Enterprise Focus** | General purpose    | Enterprise-oriented        |
| **Community**        | Larger, older      | Growing, RHEL-focused      |
| **Default Security** | AppArmor           | SELinux                    |
| **Use Case**         | Great for learning | Better for enterprise prep |

#### AppArmor vs SELinux

| Feature                 | AppArmor (Debian)         | SELinux (Rocky)            |
| ----------------------- | ------------------------- | -------------------------- |
| **Approach**            | Path-based access control | Label-based access control |
| **Complexity**          | Simpler, easier to learn  | More complex, powerful     |
| **Configuration**       | Human-readable profiles   | Policy languages, contexts |
| **Default Policies**    | Fewer, targeted           | Comprehensive, strict      |
| **Debugging**           | Easier                    | More challenging           |
| **Enterprise Adoption** | Moderate                  | High (RHEL standard)       |
| **Protection Level**    | Good                      | Excellent                  |

**Choice:** AppArmor was used in this project due to its simpler learning curve and sufficient security for the project requirements.

#### UFW vs firewalld

| Feature            | UFW (Used)                  | firewalld                    |
| ------------------ | --------------------------- | ---------------------------- |
| **Design**         | Simple frontend to iptables | Dynamic firewall manager     |
| **Complexity**     | Very simple                 | More complex                 |
| **Syntax**         | Human-readable              | XML + rich language          |
| **Zones**          | Not supported               | Full zone support            |
| **Dynamic Rules**  | Requires reload             | Runtime changes              |
| **Learning Curve** | Minimal                     | Moderate                     |
| **Default On**     | Debian/Ubuntu               | RHEL/CentOS/Rocky            |
| **Use Case**       | Simple servers, learning    | Complex networks, enterprise |

**Choice:** UFW provides straightforward firewall management perfect for learning fundamentals without unnecessary complexity.

#### VirtualBox vs UTM

| Feature                | VirtualBox                                | UTM                                  |
| ---------------------- | ----------------------------------------- | ------------------------------------ |
| **Platform**           | Cross-platform (Windows, macOS, Linux)    | macOS only (Apple Silicon optimized) |
| **Performance**        | Good on Intel, emulation on Apple Silicon | Native on Apple Silicon              |
| **Ease of Use**        | Very mature, extensive docs               | Modern, simpler interface            |
| **Networking**         | Highly configurable                       | Simpler options                      |
| **Guest Additions**    | Excellent support                         | Limited                              |
| **Snapshots**          | Full support                              | Supported                            |
| **Learning Resources** | Extensive                                 | Growing                              |
| **Apple Silicon**      | Emulation (slower)                        | Native (faster)                      |

**Choice:** VirtualBox was likely used for its maturity, cross-platform support.

## Instructions

### Prerequisites

-   VirtualBox installed on your host machine
-   Debian ISO image (latest stable version recommended)
-   At least 8GB disk space and 1GB RAM for the VM

### Installation

1. **Create Virtual Machine**

    ```bash
    # In VirtualBox:
    # - Create new VM with at least 8GB disk
    # - Allocate 1GB+ RAM
    # - Attach Debian ISO
    # - Start VM and follow installation
    ```

2. **Partition Setup**

    - Use manual partitioning during installation
    - Set up encrypted LVM
    - Create appropriate logical volumes for root, home, var, etc.

3. **Base System Configuration**

    ```bash
    # Update system
    apt update && apt upgrade

    # Install sudo
    apt install sudo

    # Add user to sudo group
    adduser <username> sudo

    # Create user42 group and add user
    addgroup user42
    adduser <username> user42
    ```

4. **SSH Configuration**

    ```bash
    # Install OpenSSH
    apt install openssh-server

    # Configure SSH (edit /etc/ssh/sshd_config)
    # - Change port to 4242
    # - Disable root login
    # - Enable public key authentication

    # Restart SSH service
    systemctl restart ssh
    ```

5. **Firewall Setup**

    ```bash
    # Install UFW
    apt install ufw

    # Enable and configure
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 4242/tcp
    ufw allow 80/tcp    # For web server
    ufw allow 9100/tcp  # For monitoring
    ufw status
    ```

6. **Password Policy**

    ```bash
    # Install password quality library
    apt install libpam-pwquality

    # Edit /etc/login.defs for password aging
    # Edit /etc/pam.d/common-password for quality requirements
    # Edit /etc/security/pwquality.conf for detailed rules
    ```

7. **Sudo Configuration**

    ```bash
    # Create sudo log directory
    mkdir /var/log/sudo

    # Configure sudo (use visudo)
    visudo -f /etc/sudoers.d/sudo_config

    # Add security settings and logging rules
    ```

8. **Monitoring Script**

    ```bash
    # Copy monitoring script to system directory
    cp monitoring.sh /usr/local/bin/
    chmod +x /usr/local/bin/monitoring.sh

    # Add to root's crontab
    crontab -e
    # Add: */10 * * * * /usr/local/bin/monitoring.sh
    ```

9. **Additional Services (Bonus)**

    ```bash
    # Web server
    apt install lighttpd

    # Database
    apt install mariadb-server
    mariadb-secure-installation

    # PHP
    apt install php-cgi php-mysql

    # Monitoring exporter
    apt install prometheus-node-exporter
    systemctl enable --now prometheus-node-exporter
    ```

### Running the System

1. **Start the Virtual Machine**

    ```bash
    # Boot the VM through VirtualBox
    ```

2. **Connect via SSH**

    ```bash
    ssh <username>@<hostname> -p 4242
    # Or from host:
    ssh <username>@localhost -p 4242
    ```

3. **Monitor System**

    ```bash
    # Check monitoring broadcasts (logged-in users will see them every 10 minutes)

    # Manually run monitoring script
    sudo /usr/local/bin/monitoring.sh
    ```

4. **Verify Configuration**

    ```bash
    # Check hostname
    hostname

    # Check users and groups
    getent group sudo
    getent group user42

    # Check partitions
    lsblk

    # Check SSH configuration
    sudo grep Port /etc/ssh/sshd_config

    # Check firewall
    sudo ufw status

    # Check AppArmor
    sudo aa-status

    # Check sudo logs
    sudo cat /var/log/sudo/sudo.log
    ```

## Resources

-   [Debian Documentation](https://www.debian.org/doc/) - Official Debian manuals and guides
-   [Debian Administrator's Handbook](https://debian-handbook.info/) - Comprehensive system administration guide
-   [SSH Manual](https://man.openbsd.org/ssh) - OpenSSH documentation
-   [UFW Documentation](https://help.ubuntu.com/community/UFW) - Ubuntu firewall guide
-   [AppArmor Wiki](https://gitlab.com/apparmor/apparmor/-/wikis/home) - AppArmor security profiles
-   [LVM HOWTO](https://tldp.org/HOWTO/LVM-HOWTO/) - Logical Volume Manager guide
-   [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials) - System administration guides
-   [CIS Debian Benchmark](https://www.cisecurity.org/benchmark/debian_linux) - Security configuration guidelines
-   [Prometheus Documentation](https://prometheus.io/docs/) - Monitoring system docs
-   [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line) - Command-line proficiency

## AI Assistance

This README.md file was created with the assistance of ChatGPT. The AI provided help in structuring the content, suggesting commands, and ensuring clarity in explanations.

---

## Command Reference Cheatsheet

Quick reference for all important commands.

---

## System Information

### OS and Kernel

```bash
# Display kernel and system info
uname -a
uname -r        # Kernel version only

# OS information
cat /etc/os-release
cat /etc/debian_version
lsb_release -a
```

### Hostname

```bash
# Check hostname
hostname
hostnamectl

# Change hostname
sudo hostnamectl set-hostname new-hostname
sudo vim /etc/hosts  # Update here too
```

## User Management

### User Information

```bash
# List all users
cat /etc/passwd

# ---
# This command uses `cut` to extract the first field from each line of the `/etc/passwd` file, using the colon (`:`) as the field delimiter.
# `-d:` specifies the delimiter character as a colon.
# `-f1` selects the first field (typically the username in `/etc/passwd`).
cut -d: -f1 /etc/passwd

# Current user
whoami
id

# User details
id username
finger username

# Check user groups
groups username
id -Gn username
```

### User Operations

```bash
# Create user
sudo adduser username
sudo useradd -m -s /bin/bash username

# Delete user
sudo userdel username
sudo userdel -r username  # Remove home directory too

# Modify user
sudo usermod -l new_name old_name  # Change login name
sudo usermod -aG groupname username  # Add to group
sudo usermod -g groupname username   # Change primary group

# Lock/Unlock user
sudo passwd -l username  # Lock
sudo passwd -u username  # Unlock

# Change user password
sudo passwd username
passwd  # Change own password
```

### Group Management

```bash
# List all groups
cat /etc/group
getent group

# Specific group members
getent group groupname

# Create group
sudo groupadd groupname

# Delete group
sudo groupdel groupname

# Add user to group
sudo usermod -aG groupname username
sudo gpasswd -a username groupname

# Remove user from group
sudo gpasswd -d username groupname

# Change group password
sudo gpasswd groupname
```

### Sudo Group

```bash
# Check sudo group members
getent group sudo

# Add user to sudo group
sudo usermod -aG sudo username

# Check sudo permissions
sudo -l
sudo -ll  # Detailed

# Test sudo access
sudo -v
sudo whoami  # Should return 'root'
```

## Password Policy

### Check Password Aging

```bash
# Check password aging for user
sudo chage -l username

# Change password aging
sudo chage -M 30 username   # Max days
sudo chage -m 2 username    # Min days
sudo chage -W 7 username    # Warning days
sudo chage -I 10 username   # Inactive days
sudo chage -E 2025-12-31 username  # Expiration date
```

### Password Policy Files

```bash
# Password aging policy
cat /etc/login.defs | grep PASS

# Password quality policy
cat /etc/pam.d/common-password
cat /etc/security/pwquality.conf
```

### Force Password Change

```bash
# Force user to change password on next login
sudo passwd -e username

# Change own password
passwd
```

## Partition and Storage

### Disk Information

```bash
# List block devices
lsblk
lsblk -f  # With filesystem info

# Disk usage
df -h
df -Th  # With filesystem type

# Disk partitions
sudo fdisk -l
sudo parted -l
```

### LVM Commands

```bash
# Physical Volumes
sudo pvs          # List PVs
sudo pvdisplay    # Detailed PV info
sudo pvcreate /dev/sdX  # Create PV

# Volume Groups
sudo vgs          # List VGs
sudo vgdisplay    # Detailed VG info
sudo vgcreate name /dev/sdX  # Create VG

# Logical Volumes
sudo lvs          # List LVs
sudo lvdisplay    # Detailed LV info
sudo lvcreate -L 5G -n name vgname  # Create LV

# Extend LV
sudo lvextend -L +5G /dev/vgname/lvname
sudo resize2fs /dev/vgname/lvname
```

### Encryption

```bash
# Check encrypted partitions
lsblk -f
sudo dmsetup ls
sudo cryptsetup status /dev/mapper/encrypted_name
```

## Network

### Network Information

```bash
# IP address
hostname -I
ip addr show
ip a

# Network interfaces
ifconfig
ip link show

# MAC address
ip link show
cat /sys/class/net/*/address

# Routing table
ip route
route -n
netstat -rn
```

### Port and Connections

```bash
# Active connections
ss -tunlp
ss -tunlp | grep LISTEN
netstat -tunlp

# Specific port
sudo ss -tunlp | grep :4242
sudo lsof -i :4242
```

## SSH

### SSH Service

```bash
# Check SSH status
sudo systemctl status ssh
sudo service ssh status

# Start/Stop/Restart SSH
sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh

# Enable/Disable at boot
sudo systemctl enable ssh
sudo systemctl disable ssh

# Check SSH port
sudo ss -tunlp | grep ssh
sudo grep Port /etc/ssh/sshd_config
```

### SSH Configuration

```bash
# View SSH config
cat /etc/ssh/sshd_config
sudo grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'

# Important settings
sudo grep Port /etc/ssh/sshd_config
sudo grep PermitRootLogin /etc/ssh/sshd_config
sudo grep PasswordAuthentication /etc/ssh/sshd_config
```

### SSH Connection

```bash
# Connect to SSH
ssh username@hostname -p 4242
ssh username@localhost -p 4242  # From host to VM

# Generate SSH key
ssh-keygen -t rsa -b 4096

# Copy SSH key
ssh-copy-id -p 4242 username@hostname
```

## Firewall (UFW)

### UFW Status

```bash
# Check status
sudo ufw status
sudo ufw status verbose
sudo ufw status numbered

# Enable/Disable
sudo ufw enable
sudo ufw disable
```

### UFW Rules

```bash
# Allow port
sudo ufw allow 4242
sudo ufw allow 4242/tcp

# Deny port
sudo ufw deny 80

# Delete rule by number
sudo ufw status numbered
sudo ufw delete NUMBER

# Delete rule by specification
sudo ufw delete allow 4242

# Reset UFW (delete all rules)
sudo ufw reset
```

### UFW Defaults

```bash
# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Reload UFW
sudo ufw reload
```

## Sudo

### Sudo Configuration

```bash
# Edit sudoers file (safe way)
sudo visudo
sudo visudo -f /etc/sudoers.d/sudo_config

# View sudo configuration
cat /etc/sudoers
cat /etc/sudoers.d/*
```

### Sudo Logs

```bash
# View sudo logs
sudo cat /var/log/sudo/sudo.log
sudo cat /var/log/sudo/sudo.log | grep COMMAND

# View sudo input/output logs
ls /var/log/sudo/
sudo cat /var/log/sudo/00/00/01/log

# Count sudo commands
sudo journalctl _COMM=sudo | grep COMMAND | wc -l
```

### Sudo Commands

```bash
# Run command as root
sudo command

# Run command as another user
sudo -u username command

# Switch to root shell
sudo -i
sudo su -

# List sudo permissions
sudo -l
sudo -ll

# Update sudo timestamp
sudo -v

# Invalidate sudo timestamp
sudo -k
```

## AppArmor

### AppArmor Status

```bash
# Check if AppArmor is running
sudo systemctl status apparmor
sudo aa-status

# Number of profiles
sudo aa-status | grep profiles

# Enable/Disable AppArmor
sudo systemctl enable apparmor
sudo systemctl disable apparmor
```

### AppArmor Profiles

```bash
# List profiles
sudo aa-status

# Enforce mode
sudo aa-enforce /etc/apparmor.d/profile_name

# Complain mode
sudo aa-complain /etc/apparmor.d/profile_name

# Disable profile
sudo aa-disable /etc/apparmor.d/profile_name
```

## Services and Processes

### Systemctl

```bash
# List all services
sudo systemctl list-units --type=service
sudo systemctl list-units --type=service --state=running

# Check service status
sudo systemctl status service_name

# Start/Stop/Restart service
sudo systemctl start service_name
sudo systemctl stop service_name
sudo systemctl restart service_name

# Enable/Disable service at boot
sudo systemctl enable service_name
sudo systemctl disable service_name

# Check if service is enabled
sudo systemctl is-enabled service_name
sudo systemctl is-active service_name
```

### Process Management

```bash
# List processes
ps aux
ps -ef
top
htop

# Find process
ps aux | grep process_name
pgrep process_name
pidof process_name

# Kill process
kill PID
kill -9 PID  # Force kill
killall process_name
pkill process_name
```

## Cron

### Cron Jobs

```bash
# Edit crontab
crontab -e
sudo crontab -e  # Root's crontab

# List crontab
crontab -l
sudo crontab -l

# Remove crontab
crontab -r

# Cron log
sudo grep CRON /var/log/syslog
sudo journalctl -u cron
```

### Cron Syntax

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)

Examples:
*/10 * * * *  # Every 10 minutes
0 */2 * * *   # Every 2 hours
0 0 * * *     # Daily at midnight
0 0 * * 0     # Weekly on Sunday
```

## Package Management

### APT

```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade
sudo apt full-upgrade

# Install package
sudo apt install package_name

# Remove package
sudo apt remove package_name
sudo apt purge package_name  # Remove config files too
sudo apt autoremove  # Remove unused dependencies

# Search package
apt search keyword
apt-cache search keyword

# Show package info
apt show package_name
apt-cache show package_name

# List installed packages
apt list --installed
dpkg -l
```

### Aptitude

```bash
# Install aptitude
sudo apt install aptitude

# Same commands as apt
sudo aptitude update
sudo aptitude upgrade
sudo aptitude install package_name
sudo aptitude remove package_name
sudo aptitude search keyword
```

## Monitoring Script

### Script Commands

```bash
# Run monitoring script manually
sudo /usr/local/bin/monitoring.sh

# Check script content
cat /usr/local/bin/monitoring.sh

# Make script executable
sudo chmod +x /usr/local/bin/monitoring.sh

# Test script components
uname -a
free -m
df -h
top -bn1
who -b
```

### Wall Command

```bash
# Send message to all users
wall "Message"
echo "Message" | wall

# Disable terminal messages
mesg n

# Enable terminal messages
mesg y
```

## System Logs

### View Logs

```bash
# System log
sudo tail -f /var/log/syslog
sudo journalctl -f

# Auth log
sudo cat /var/log/auth.log
sudo tail -f /var/log/auth.log

# Sudo log
sudo cat /var/log/sudo/sudo.log

# Boot log
sudo journalctl -b

# Service-specific log
sudo journalctl -u service_name

# Last logins
last
lastlog
```

## Miscellaneous

### System

```bash
# Reboot
sudo reboot
sudo shutdown -r now

# Shutdown
sudo shutdown -h now
sudo poweroff

# Uptime
uptime
who -b

# Date and time
date
timedatectl
```

### Check if GUI is installed

```bash
# Should return nothing or very few results
ls /usr/bin/*session
dpkg -l | grep xorg
dpkg -l | grep x11
```

### Memory and CPU

```bash
# Memory
free -h
cat /proc/meminfo

# CPU
lscpu
cat /proc/cpuinfo
nproc  # Number of processors
```

## Keyboard Shortcuts

```
Ctrl + C  # Cancel current command
Ctrl + D  # Logout/Exit
Ctrl + L  # Clear screen
Ctrl + A  # Beginning of line
Ctrl + E  # End of line
Ctrl + R  # Search command history
Ctrl + Z  # Suspend process
Tab       # Auto-complete
```
