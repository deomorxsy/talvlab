### Playbooks Directory Structure:

- defaults: variables for the roles
- inventory:
    - group\_vars is for
    - host\_vars is for
- main.yml is for the k3s setup.
- roles: is for
    - prereq: prerequisites before bootstrapping
    - fetch: download from URI (remote repo, local dir, NFS server, etc)
    - airgap is for DMZ installs, WIP
- samba4 directory is for join hosts as samba4 domain members. As the playbook focus on ubuntu distros, there are points to take into account such as AppArmor LSM and how it affects tracing and default kernel features leveraged by OCI and CRI.


```
[user@user playbooks]$ tree -C
.
├── defaults
├── inventory
│   ├── group_vars
│   ├── hosts.ini
│   └── host_vars
│       ├── all.yml
│       ├── hostname1_ubuntu-2004.yml
│       └── hostname2_arch-636.yml
├── main.yml
├── README.md
├── roles
│   ├── airgap
│   │   └── tasks
│   │       └── main.yml
│   ├── fetch
│   │   └── tasks
│   │       └── main.yml
│   ├── k3s
│   ├── prereq
│   │   └── tasks
│   │       └── main.yml
│   └── samba4
└── samba4
    ├── 1604-ubuntu-amd64.yml
    ├── 1804-ubuntu-amd64.yml
    ├── 2004-ubuntu-amd64.yml
    └── main.yaml

```
