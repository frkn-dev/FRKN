## Base role for Ansible

### Prerequisites: 
    ⋅⋅* Ansible must be installed
    ⋅⋅* community.general collection must be installed
    ⋅⋅* `ansible-galaxy collection install community.general`

The **files** subfolder should contain the `authorized_keys` file which contains ssh keys to be copied to target host. The **inventory** subfolder should contain the `hosts` inventory file. There is an example `hosts` file in the repo. You need to edit it.

The `base-setup.yml` file in the root directory of this repo contains the playbook to run this role. You need to edit it and specify the user for connections.

**Usage**: `ansible-playbook base-setup.yml -i roles/base/inventory`