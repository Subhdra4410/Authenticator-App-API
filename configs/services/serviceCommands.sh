 #!/bin/bash

cd /opt/scripts/
service rsyslog restart
bash update_conf_log_path.sh
bash check_configuration_parameters.sh
bash make_file_updates.sh
bash update_configurations.sh
bash restart_services.sh
bash setup_database.sh

# Changes required, in-case the Host-VM is using Podman.
podman_deployment_env_var=${podman_deployment}

if [ ! -z "$podman_deployment_env_var" ]; then
    if [ $podman_deployment_env_var -eq 1 ]; then
        echo "podman_deployment environment variable is set to 1. Commenting the required files.";
        sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/' /etc/pam.d/cron /etc/pam.d/login
        service cron restart
    else
        echo "podman_deployment environment variable is not set to 1. No Actions are performed.";
    fi
else
    echo "podman_deployment environment variable is not set.";
fi