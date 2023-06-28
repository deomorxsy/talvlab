## kubeTalv

Quick k3s lab bootstrapping in single-host, multi-node or cloud environment using:

- provisioning stage
    - terraform
    - pulumi
    ```
    ; curl -fsSL https://get.pulumi.com | sh
    ;
    ; export PATH=$PATH:/home/asari/.pulumi/bin
    ;
    ; # command below should return options.
    ; pulumi

    ```

- dependency orchestration
    - Ansible

- runtime bootstrapping
    - Libvirt
    - Vagrant
    ```
    #single-host
    vagrant up singh

    #multi-node
    vagrant up multn
        ```
